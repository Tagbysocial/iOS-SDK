//
//  TBYouTube.h
//  TagByLauncher
//
//  Created by Alek on 09.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBWidget.h"

@interface TBYouTube : TBWidget

+ (TBYouTube *)parseFromJSON:(NSDictionary *)dictionary;

@property (nonatomic, copy, readonly) NSString *videoId;

@end
