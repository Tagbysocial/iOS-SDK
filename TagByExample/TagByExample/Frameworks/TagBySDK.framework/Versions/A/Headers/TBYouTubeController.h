//
//  TBYouTubeController.h
//  TagByLauncher
//
//  Created by Alek on 19.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBWidgetController.h"

@class TBYouTubeController;

@protocol TBYouTubeControllerDelegate <NSObject>

- (void)didReceiveVideoInformation:(TBYouTubeController *)controller;

@end;

@interface TBYouTubeController : TBWidgetController

@property (nonatomic, readonly) UIImage *thumbnailImage;

- (instancetype)initWithSuperview:(UIView *)superview frame:(CGRect)frame videoId:(NSString *)videoId delegate:(id<TBYouTubeControllerDelegate>)delegate;

- (void)play;
- (void)pause;
- (void)stop;

@end
