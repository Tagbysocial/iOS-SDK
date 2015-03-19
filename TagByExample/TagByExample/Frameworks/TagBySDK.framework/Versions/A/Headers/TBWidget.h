//
//  TBWidget.h
//  TagByLauncher
//
//  Created by Alek on 08.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

@import Foundation;
@import UIKit;

typedef NS_ENUM(NSUInteger, TBWidgetType) {
	TBWidgetTypeView = 1,
	TBWidgetTypeLabel = 2,
	TBWidgetTypeCameraPreview = 3,
	TBWidgetTypeButton = 4,
	TBWidgetTypeImage = 5,
	TBWidgetTypeLogoImage = 6,
	TBWidgetTypeBarcodePreview = 7,
	TBWidgetTypeYouTube = 8
};

@interface TBWidget : NSObject

+ (TBWidget *)parseFromJSON:(NSDictionary *)dictionary;

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, strong, readonly) UIColor *backgroundColor;
@property (nonatomic, assign, readonly) TBWidgetType type;
@property (nonatomic, copy, readonly) NSString *name;

@end
