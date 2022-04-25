//
//  EsrcSDK_MeasureEnv_Wrapper.h
//  ESRC-Face-SDK-iOS
//
//  Created by Hyunwoo Lee on 04/11/2021.
//  Copyright © 2021 ESRC. All rights reserved.
//

#ifndef EsrcSDK_MeasureEnv_Wrapper_h
#define EsrcSDK_MeasureEnv_Wrapper_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 ESRC MeasureEnv wrapper class.
 */
@interface EsrcSDK_MeasureEnv_Wrapper : NSObject

/**
 * Initializes brightness analysis task.
 *
 * @return Returns true if the initialization succeeded. Otherwise, false.
 */
+ (bool) EsrcSDK_MeasureEnv_InitBrightnessAnalysisTask;

/**
 * Releases brightness analysis task.
 *
 * @return Returns true if the release succeeded. Otherwise, false.
 */
+ (bool) EsrcSDK_MeasureEnv_ReleaseBrightnessAnalysisTask;

/**
 * Analyze brightess from frame data.
 *
 * @param frame Frame data.
 * @param brightness Analyzed brightess.
 */
+ (void) EsrcSDK_MeasureEnv_FeedBrightnessAnalysisTask: (UIImage *) frame param2: (int *) brightness;

@end

#endif /* EsrcSDK_MeasureEnv_Wrapper_h */
