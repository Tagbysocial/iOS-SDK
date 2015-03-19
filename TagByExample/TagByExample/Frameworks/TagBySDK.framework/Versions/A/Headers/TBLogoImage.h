//
//  TBLogoImage.h
//  TagByLauncher
//
//  Created by Alek on 08.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBWidget.h"

@interface TBLogoImage : TBWidget

+ (TBLogoImage *)parseFromJSON:(NSDictionary *)dictionary;

@property (nonatomic, strong, readonly) NSURL *imageUrl;

@end
