//
//  EsrcCV_Face_Wrapper.h
//  ESRC-Face-SDK-iOS
//
//  Created by Hyunwoo Lee on 27/05/2021.
//  Copyright © 2021 ESRC. All rights reserved.
//

#ifndef EsrcSDK_Face_Wrapper_h
#define EsrcSDK_Face_Wrapper_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EsrcSDK_Face_Wrapper : NSObject

+ (bool) EsrcSDK_Face_InitFaceDetectionTask: (NSString *) protoPath param2: (NSString *) caffePath;
+ (bool) EsrcSDK_Face_ReleaseFaceDetectionTask;
+ (void) EsrcSDK_Face_FeedFaceDetectionTask: (UIImage *) frame param2: (UIImage **) faceFrame param3: (int *) face param4: (UIImage **) squareFrame param5: (int *) square param6: (bool *) isDetect param7: (double *) conf;

+ (bool) EsrcSDK_Face_InitFacialLandmarkDetectionTask: (NSString *) tflitePath;
+ (bool) EsrcSDK_Face_ReleaseFacialLandmarkDetectionTask;
+ (void) EsrcSDK_Face_FeedFacialLandmarkDetectionTask: (UIImage *) face param2: (float *) facialLandmark;

+ (bool) EsrcSDK_Face_InitBasicFacialExpressionRecognitionTask: (NSString *) tflitePath;
+ (bool) EsrcSDK_Face_ReleaseBasicFacialExpressionRecognitionTask;
+ (void) EsrcSDK_Face_FeedBasicFacialExpressionRecognitionTask: (UIImage *) face param2: (float *) emotionProbs param3: (int *) emotion;

+ (bool) EsrcSDK_Face_InitValenceFacialExpressionRecognitionTask: (NSString *) tflitePath;
+ (bool) EsrcSDK_Face_ReleaseValenceFacialExpressionRecognitionTask;
+ (void) EsrcSDK_Face_FeedValenceFacialExpressionRecognitionTask: (UIImage *) face param2: (float *) emotionProbs param3: (int *) emotion;


@end

#endif /* EsrcSDK_Face_Wrapper_h */
