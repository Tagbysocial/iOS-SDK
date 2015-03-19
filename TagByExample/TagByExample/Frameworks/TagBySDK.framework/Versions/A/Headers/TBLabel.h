//
//  TBLabel.h
//  TagByLauncher
//
//  Created by Alek on 09.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBWidget.h"

typedef NS_ENUM(NSUInteger, TBLabelTextAlignment) {
	TBLabelTextAlignmentLeft = 1,
	TBLabelTextAlignmentCenter = 2,
	TBLabelTextAlignmentRight = 3
};

@interface TBLabel : TBWidget

+ (TBLabel *)parseFromJSON:(NSDictionary *)dictionary;

@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, copy, readonly) NSString *fontName;
@property (nonatomic, assign, readonly) CGFloat fontSize;
@property (nonatomic, strong, readonly) UIColor *textColor;
@property (nonatomic, assign, readonly) TBLabelTextAlignment textAlignment;

@end
