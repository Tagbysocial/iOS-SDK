//
//  TBController.h
//  TagByLauncher
//
//  Created by Alek on 19.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface TBWidgetController : NSObject

@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign, readonly) CGRect frame;

- (instancetype)initWithSuperview:(UIView *)superview frame:(CGRect)frame;
- (void)removeView;

- (UIInterfaceOrientation)orientation;

@end
