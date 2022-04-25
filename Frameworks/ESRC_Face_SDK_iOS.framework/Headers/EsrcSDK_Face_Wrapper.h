//
//  EsrcSDK_Face_Wrapper.h
//  ESRC-Face-SDK-iOS
//
//  Created by Hyunwoo Lee on 27/05/2021.
//  Copyright © 2021 ESRC. All rights reserved.
//

#ifndef EsrcSDK_Face_Wrapper_h
#define EsrcSDK_Face_Wrapper_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * ESRC Face wrapper class.
 */
@interface EsrcSDK_Face_Wrapper : NSObject

/**
 * Initializes face detection task.
 *
 * @param protoPath Path of prototxt.
 * @param caffePath Path of caffemodel.
 * @return Returns true if the initialization succeeded. Otherwise, false.
 */
+ (bool) EsrcSDK_Face_InitFaceDetectionTask: (NSString *) protoPath param2: (NSString *) caffePath;

/**
 * Releases face detection task.
 *
 * @return Returns true if the release succeeded. Otherwise, false.
 */
+ (bool) EsrcSDK_Face_ReleaseFaceDetectionTask;

/**
 * Detects face from frame image.
 *
 * @param frame Frame data.
 * @param isDetect Whether face is detected or not.
 * @param bboxArray Bounding box array of detected face.
 * @param bboxFrame Frame data for bounding box of detected face.
 * @param sboxArray Square box array of detected face.
 * @param sboxFrame Frame data for square box of detected face.
 * @param conf Confidence level of detected face.
 */
+ (void) EsrcSDK_Face_FeedFaceDetectionTask: (UIImage *) frame param2: (bool *) isDetect param3: (int *) bboxArray param4: (UIImage **) bboxFrame param5: (int *) sboxArray param6: (UIImage **) sboxFrame param7: (double *) conf;

/**
 * Initializes facial landmark detection task.
 *
 * @param tflitePath Path of TfLite.
 * @return Returns true if the initialization is succeeded. Otherwise, false.
 */
+ (bool) EsrcSDK_Face_InitFacialLandmarkDetectionTask: (NSString *) tflitePath;

/**
 * Release facial landmark detection task.
 *
 * @return Returns true if the release is succeeded. Otherwise, false.
 */
+ (bool) EsrcSDK_Face_ReleaseFacialLandmarkDetectionTask;

/**
 * Detects facial landmark from face image.
 *
 * @param bboxFrame Frame data for bounding box of detected face.
 * @param facialLandmarkArray Array of detected facial landmark
 */
+ (void) EsrcSDK_Face_FeedFacialLandmarkDetectionTask: (UIImage *) bboxFrame param2: (float *) facialLandmarkArray;

/**
 * Initializes basic facial expression recognition task.
 *
 * @param tflitePath Path of TfLite.
 * @return Returns true if the initialization succeeded. Otherwise, false.
 */
+ (bool) EsrcSDK_Face_InitBasicFacialExpressionRecognitionTask: (NSString *) tflitePath;

/**
 * Releases basic facial expression recognition task.
 *
 * @return Returns true if the release succeeded. Otherwise, false.
 */
+ (bool) EsrcSDK_Face_ReleaseBasicFacialExpressionRecognitionTask;

/**
 * Recognizes basic facial expression from face image.
 *
 * @param bboxFrame Frame data for bounding box of detected face.
 * @param emotionProbs Probabilities of basic facial expressions.
 * @param emotion Emotion of basic facial expression.
 */
+ (void) EsrcSDK_Face_FeedBasicFacialExpressionRecognitionTask: (UIImage *) bboxFrame param2: (float *) emotionProbs param3: (int *) emotion;

/**
 * Initializes valence facial expression recognition task.
 *
 * @param tflitePath Path of TfLite.
 * @return Returns true if the initialization succeeded. Otherwise, false.
 */
+ (bool) EsrcSDK_Face_InitValenceFacialExpressionRecognitionTask: (NSString *) tflitePath;

/**
 * Releases valence facial expression recognition task.
 *
 * @return Returns true if the release succeeded. Otherwise, false.
 */
+ (bool) EsrcSDK_Face_ReleaseValenceFacialExpressionRecognitionTask;

/**
 * Recognizes valence facial expression from face image.
 *
 * @param bboxFrame Frame data for bounding box of detected face.
 * @param emotionProbs Probabilities of valence facial expressions.
 * @param emotion Emotion of valence facial expression.
 */
+ (void) EsrcSDK_Face_FeedValenceFacialExpressionRecognitionTask: (UIImage *) bboxFrame param2: (float *) emotionProbs param3: (int *) emotion;


@end

#endif /* EsrcSDK_Face_Wrapper_h */
