//
//  TBVideoController.h
//  AVTest
//
//  Created by Stephane JAIS on 9/28/12.
//  Copyright (c) 2012 Stephane JAIS. All rights reserved.
//

#import "TBWidgetController.h"

typedef NS_ENUM(NSUInteger, TBCameraSide) {
	TBCameraSideFront = 1,
	TBCameraSideBack = 2,
};

@class TBCameraPreview;
@class TBImage;

@interface TBCameraPreviewController : TBWidgetController

@property (nonatomic, assign) TBCameraSide cameraSide;

- (instancetype)initWithSuperview:(UIView *)superview tbCameraPreview:(TBCameraPreview *)tbCameraPreview;

- (void)startPreviewing;
- (void)stopPreviewing;

- (void)takePicture:(void(^)(UIImage *picture, NSError *error))completionBlock;

@end
