//
//  TBButton.h
//  TagByLauncher
//
//  Created by Alek on 09.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBWidget.h"

@interface TBButton : TBWidget

+ (TBButton *)parseFromJSON:(NSDictionary *)dictionary;

@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSURL *imageUrl;

@property (nonatomic, copy, readonly) NSString *fontName;
@property (nonatomic, assign, readonly) CGFloat fontSize;
@property (nonatomic, strong, readonly) UIColor *textColor;

@end
