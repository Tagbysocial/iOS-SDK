//
//  TBLabelController.h
//  TagByLauncher
//
//  Created by Alek on 19.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBWidgetController.h"

@class TBLabel;

@interface TBLabelController : TBWidgetController

@property (nonatomic, strong) UILabel *label;

- (instancetype)initWithSuperview:(UIView *)superview tbLabel:(TBLabel *)tbLabel;

@end
