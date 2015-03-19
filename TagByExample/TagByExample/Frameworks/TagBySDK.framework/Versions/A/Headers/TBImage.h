//
//  TBImage.h
//  TagByLauncher
//
//  Created by Alek on 08.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBWidget.h"

@interface TBImage : TBWidget

+ (TBImage *)parseFromJSON:(NSDictionary *)dictionary;

@property (nonatomic, strong, readonly) NSURL *imageUrl;

@end
