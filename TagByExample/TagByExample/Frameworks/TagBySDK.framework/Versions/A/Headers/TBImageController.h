//
//  TBImageController.h
//  TagByLauncher
//
//  Created by Alek on 19.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBWidgetController.h"

@class TBImageController;

@protocol TBImageControllerDelegate <NSObject>

- (void)didClickTBImage:(TBImageController *)tbImageController;

@optional
- (void)didLoadRemoteImage:(UIImage *)image inTBImage:(TBImageController *)tbImageController;

@end

@class TBWidget;
@class TBImage;

@interface TBImageController : TBWidgetController

@property (nonatomic, weak) id<TBImageControllerDelegate> delegate;
@property (nonatomic, strong) UIImage *image;

- (instancetype)initWithSuperview:(UIView *)superview tbImage:(TBImage *)tbImage;
- (instancetype)initWithSuperview:(UIView *)superview tbWidget:(TBWidget *)tbWidget image:(UIImage *)image;

@end
