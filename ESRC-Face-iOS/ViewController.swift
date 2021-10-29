//
//  ViewController.swift
//  ESRC-Face-iOS
//
//  Created by Hyunwoo Lee on 25/10/2021.
//  Copyright © 2021 ESRC. All rights reserved.
//

import UIKit
import AVFoundation
import ESRC_Face_SDK_iOS

class ViewController:  UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    // ESRC variables
    let APP_ID: String = ""  // Applocation ID.
    let ENABLE_DRAW: Bool = true;  // Enablement of visualization.
    var frame: UIImage? = nil
    var face: ESRCFace? = nil
    var facialLandmark: ESRCFacialLandmark? = nil
    
    // Camera variables
    @IBOutlet weak var preview: UIImageView!
    var captureSession: AVCaptureSession!
    var videoOutput: AVCaptureVideoDataOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var overlayLayer: CAShapeLayer!
    
    // Timer variables
    var timer: Timer?
    
    // Layout variables
    @IBOutlet weak var facebox_image: UIImageView!
    @IBOutlet weak var info_container: UIView!
    @IBOutlet weak var upper_line_container: UIView!
    @IBOutlet weak var under_line_container: UIView!
    @IBOutlet weak var facial_exp_container: UIView!
    @IBOutlet weak var head_pose_container: UIView!
    @IBOutlet weak var attention_container: UIView!
     
    @IBOutlet weak var facial_exp_title_text: UITextField!
    @IBOutlet weak var facial_exp_val_text: UITextView!

    @IBOutlet weak var head_pose_title_text: UITextField!
    @IBOutlet weak var head_pose_val_text: UITextView!
    
    @IBOutlet weak var attention_title_text: UITextField!
    @IBOutlet weak var attention_val_text: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Always screen on
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Initialize face box
        facebox_image.layer.borderWidth = 4
        facebox_image.layer.borderColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0).cgColor
        
        // Initialize container
        info_container.backgroundColor = UIColor(white: 1, alpha: 0.0)
        under_line_container.backgroundColor = UIColor(white: 1, alpha: 0.0)
        facial_exp_container.layer.cornerRadius = 10
        head_pose_container.layer.cornerRadius = 10
        attention_container.layer.cornerRadius = 10
        
        // Show coming soon text
        head_pose_val_text.isHidden = false
        attention_val_text.isHidden = false
    }
    
    func drawImage(size: CGSize, image: UIImage, width: Double, height: Double) -> UIImage {
        UIGraphicsBeginImageContext(size)
        image.draw(at: CGPoint.zero)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        context.setLineWidth(1.0)
        context.setStrokeColor(UIColor.red.cgColor)
        context.addRect(CGRect(x:0, y:0, width: width, height: height))
        context.strokePath()

        guard let resultImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        UIGraphicsEndImageContext()
        return resultImage
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Setup session
        captureSession = AVCaptureSession()
        
        // Select input device
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            else {
                fatalError("Unable to access front caemra.")
        }

        do {
            // Prepare the input
            let captureInput = try AVCaptureDeviceInput(device: device)
            
            // Configure the output
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) :
                                            NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.frame.processing.queue"))
       
            // Attach the input and output
            if captureSession.canAddInput(captureInput) && captureSession.canAddOutput(videoOutput) {
                captureSession.addInput(captureInput)
                captureSession.addOutput(videoOutput)
                
                // Configure the output connection
                if let connection = self.videoOutput.connection(with: AVMediaType.video),
                   connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                    connection.isVideoMirrored = true
                }

                // Setup the preview
                setupPreview()
            }
        }
        catch _ {
            fatalError("Error Unable to initialize front camera.")
        }
        
        // Initialize ESRC
        if(!ESRC.initWithApplicationId(appId: APP_ID, licenseHandler: self)) {
            print("ESRC init is failed.")
        } else {
            // Start ESRC
            if(!ESRC.start(handler: self)) {
                print("ESRC start is failed.")
            }
            
            // Start timer (10 fps)
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                // Feed ESRC
                if(self.frame != nil) {
                    ESRC.feed(frame: self.frame!)
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop timer
        self.timer?.invalidate()
        
        // Release ESRC
        if(!ESRC.stop()) {
            print("ESRC stop is failed.")
        }

        // Stop the session on the background thread
        self.captureSession.stopRunning()
    }
    
    func setupPreview() {
        // Configure the preview
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspect
        previewLayer.connection?.videoOrientation = .portrait
        preview.layer.addSublayer(previewLayer)
        
        // Configure the overlay
        overlayLayer = CAShapeLayer()
        preview.layer.addSublayer(overlayLayer)

        // Start the session on the background thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()

            // Size the preview layer to fit the preview
            DispatchQueue.main.async {
                self.previewLayer.frame = self.preview.bounds
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let videoBuffer = CMSampleBufferGetImageBuffer(sampleBuffer), let _ = CMSampleBufferGetFormatDescription(sampleBuffer) else {return}
        let captureImage = CIImage(cvImageBuffer: videoBuffer)
        let context: CIContext = CIContext.init(options: nil)
        let cgImage = context.createCGImage(captureImage, from: captureImage.extent)!
        let image = UIImage(cgImage: cgImage)
        
        // Set frame
        self.frame = image
        
        // Draw
        if (ENABLE_DRAW) {
            DispatchQueue.main.async {
                self.draw(image: image)
            }
        }
    }
    
    func draw(image: UIImage) {
        if (self.face != nil) {
            let wRatio: CGFloat = self.preview.frame.size.width / image.size.width
            let hRatio : CGFloat = self.preview.frame.size.height / image.size.height
            self.overlayLayer.path = UIBezierPath(roundedRect: CGRect(x: (CGFloat)(self.face!.getX()) * wRatio, y: (CGFloat)(self.face!.getY()) * hRatio, width: (CGFloat)(self.face!.getW()) * wRatio, height: (CGFloat)(self.face!.getH()) * hRatio), cornerRadius: 0).cgPath
            self.overlayLayer.strokeColor = UIColor.red.cgColor
            self.overlayLayer.lineWidth = 3
            self.overlayLayer.fillColor = UIColor.clear.cgColor
        } else {
            self.overlayLayer.path = nil
        }
    }
}

extension ViewController: ESRCLicenseHandler, ESRCHandler {
    
    func onValidatedLicense() {
        print("onValidatedLicense.")
    }
    
    func onInvalidatedLicense() {
        print("onInvalidatedLicense.")
    }
    
    func onDetectedFace(face: ESRCFace) {
        print("onDetectedFace: " + face.toString())
        self.face = face
        
        facebox_image.layer.borderWidth = 8
        facebox_image.layer.borderColor = UIColor(red: 0.92, green: 0.0, blue: 0.55, alpha: 1.0).cgColor
        
        facial_exp_val_text.isHidden = false
    }
    
    func onNotDetectedFace() {
        print("onNotDetectedFace")
        self.face = nil
        self.facialLandmark = nil
     
        facebox_image.layer.borderWidth = 4
        facebox_image.layer.borderColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0).cgColor
        
        facial_exp_val_text.isHidden = true
    }
    
    func onDetectedFacialLandmark(facialLandmark: ESRCFacialLandmark) {
        print("onDetectedFacialLandmark: " + facialLandmark.toString())
        self.facialLandmark = facialLandmark
    }
   
    func onAnalyzedFacialActionUnit(facialActionUnit: ESRCFacialActionUnit) {
        print("onAnalyzedFacialActionUnit: " + facialActionUnit.toString())
    }
   
    func onRecognizedFacialExpression(facialExpression: ESRCFacialExpression) {
        print("onRecognizedFacialExpression: " + facialExpression.toString())
        
        //facial_exp_image_view.isHidden = false
        facial_exp_val_text.isHidden = false
        facial_exp_val_text.text = String(facialExpression.getEmotionStr())
    }
}
