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

@interface EsrcSDK_MeasureEnv_Wrapper : NSObject

+ (bool) EsrcSDK_MeasureEnv_InitBrightnessAnalysisTask;
+ (bool) EsrcSDK_MeasureEnv_ReleaseBrightnessAnalysisTask;
+ (void) EsrcSDK_MeasureEnv_FeedBrightnessAnalysisTask: (UIImage *) frame param2: (int *) brightness;

@end

#endif /* EsrcSDK_MeasureEnv_Wrapper_h */
