//
//  TBButtonController.h
//  TagByLauncher
//
//  Created by Alek on 19.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBWidgetController.h"

@class TBButtonController;

@protocol TBButtonControllerDelegate <NSObject>

- (void)didClickTBButton:(TBButtonController *)buttonController;

@end

@class TBButton;

@interface TBButtonController : TBWidgetController

@property (nonatomic, weak) id<TBButtonControllerDelegate> delegate;
@property (nonatomic, strong, readonly) UIButton *button;
@property (nonatomic, copy) NSString *text;

- (instancetype)initWithSuperview:(UIView *)superview tbButton:(TBButton *)tbButton;

@end
