//
//  TBCameraRelatedWidget.h
//  TagByLauncher
//
//  Created by Alek on 09.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBWidget.h"

typedef NS_ENUM(NSUInteger, TBCameraSource) {
	TBCameraSourceFront = 1,
	TBCameraSourceBack = 2,
	TBCameraSourceFrontBack = 3,
	TBCameraSourceBackFront = 4
};

@interface TBCameraRelatedWidget : TBWidget

@property (nonatomic, assign) TBCameraSource source;

@end
