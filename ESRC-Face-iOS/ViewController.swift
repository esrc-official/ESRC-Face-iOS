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
    let ENABLE_DRAW: Bool = false;  // Whether visualize result or not.
    var property: ESRCProperty = ESRCProperty(
        enableMeasureEnv: true,  // Whether analyze measurement environment or not.
        enableFace: true,  // Whether detect face or not.
        enableFacialLandmark: true,  // Whether detect facial landmark or not. If enableFace is false, it is also automatically set to false.
        enableFacialActionUnit: true,  // Whether analyze facial action unit or not. If enableFace or enableFacialLandmark is false, it is also automatically set to false.
        enableBasicFacialExpression: true,  // Whether recognize basic facial expression or not. If enableFace is false, it is also automatically set to false.
        enableValenceFacialExpression: true)  // Whether recognize valence facial expression or not. If enableFace is false, it is also automatically set to false.
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
    var licenseTimer: Timer?
    
    // Layout variables
    @IBOutlet weak var facebox_image: UIImageView!
    @IBOutlet weak var info_container: UIView!
    @IBOutlet weak var upper_line_container: UIView!
    @IBOutlet weak var under_line_container: UIView!
    @IBOutlet weak var basic_facial_exp_container: UIView!
    @IBOutlet weak var valence_facial_exp_container: UIView!
    @IBOutlet weak var attention_container: UIView!
     
    @IBOutlet weak var basic_facial_exp_title_text: UITextField!
    @IBOutlet weak var basic_facial_exp_val_text: UITextView!

    @IBOutlet weak var valence_facial_exp_title_text: UITextField!
    @IBOutlet weak var valence_facial_exp_val_text: UITextView!

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
        basic_facial_exp_container.layer.cornerRadius = 10
        valence_facial_exp_container.layer.cornerRadius = 10
        attention_container.layer.cornerRadius = 10
        
        // Show coming soon text
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
        if (!ESRC.initWithApplicationId(appId: APP_ID, licenseHandler: self)) {
            print("ESRC init is failed.")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop timer
        self.timer?.invalidate()
        
        // Stop license timer
        self.licenseTimer?.invalidate()
        
        // Release ESRC
        if(!ESRC.stop()) {
            print("ESRC stop is failed.")
        }

        // Stop the session on the background thread
        self.captureSession.stopRunning()
    }
    
    func startApp() {
        print("Start App")
        // Start ESRC
        if (!ESRC.start(property: self.property, handler: self)) {
            print("ESRC start is failed.")
        }
        
        print("Start timer")
        // Start timer (10 fps)
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            // Feed ESRC
            if(self.frame != nil) {
                print("Feed ESRC")
                ESRC.feed(frame: self.frame!)
            }
        }
        
        print("Start license timer")
        // Start license timer (after 80s)
        self.licenseTimer = Timer.scheduledTimer(withTimeInterval: 80, repeats: false) { timer in
            // Show alert dialog
            let alert = UIAlertController(title: "Alert", message: "If you want to use the ESRC SDK, please visit the homepage: https://www.esrc.co.kr", preferredStyle: .alert)
            let alertPositiveButton = UIAlertAction(title: "OK", style: .default) { action in
                // Nothing
            }
            alert.addAction(alertPositiveButton)
            self.present(alert, animated: true, completion: nil)
            
            // Close app
            let closeTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { timer in
                exit(0)
            }
        }
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
        
        // Start App
        startApp()
    }
    
    func onInvalidatedLicense() {
        print("onInvalidatedLicense.")
    }
    
    func onAnalyzedMeasureEnv(measureEnv: ESRCMeasureEnv) {
        print("onAnalyzedMeasureEnv: " + measureEnv.toString())
    }
    
    func onDetectedFace(face: ESRCFace) {
        print("onDetectedFace: " + face.toString())
        
        // Whether face is detected or not
        if (face.getIsDetect()) {  // If face is detected
            self.face = face
            
            facebox_image.layer.borderWidth = 8
            facebox_image.layer.borderColor = UIColor(red: 0.92, green: 0.0, blue: 0.55, alpha: 1.0).cgColor
            
            basic_facial_exp_val_text.isHidden = false
            valence_facial_exp_val_text.isHidden = false
        } else {  // If face is not detected
            self.face = nil
            self.facialLandmark = nil
         
            facebox_image.layer.borderWidth = 4
            facebox_image.layer.borderColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0).cgColor
            
            basic_facial_exp_val_text.isHidden = true
            valence_facial_exp_val_text.isHidden = true
        }
    }
    
    func onDetectedFacialLandmark(facialLandmark: ESRCFacialLandmark) {
        print("onDetectedFacialLandmark: " + facialLandmark.toString())
        self.facialLandmark = facialLandmark
    }
   
    func onAnalyzedFacialActionUnit(facialActionUnit: ESRCFacialActionUnit) {
        print("onAnalyzedFacialActionUnit: " + facialActionUnit.toString())
    }
   
    func onRecognizedBasicFacialExpression(facialExpression: ESRCBasicFacialExpression) {
        print("onRecognizedBasicFacialExpression: " + facialExpression.toString())
        
        // Set basic facial expression
        basic_facial_exp_val_text.isHidden = false
        basic_facial_exp_val_text.text = String(facialExpression.getEmotionStr())
    }
    
    func onRecognizedValenceFacialExpression(facialExpression: ESRCValenceFacialExpression) {
        print("onRecognizedValenceFacialExpression: " + facialExpression.toString())
        
        // Set valence facial expression
        valence_facial_exp_val_text.isHidden = false
        valence_facial_exp_val_text.text = String(facialExpression.getEmotionStr())
    }
}
