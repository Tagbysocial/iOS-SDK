//
//  TBApplicationsInfo.h
//  TagBySDK
//
//  Created by Alek on 25.09.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

@import Foundation;

@interface TBApplicationInfo : NSObject

@property (nonatomic, copy) NSString *appDescription;
@property (nonatomic, copy) NSString *disabledLogoUrl;
@property (nonatomic, copy) NSString *keyGuid;
@property (nonatomic, copy) NSString *privatePart;
@property (nonatomic, copy) NSString *publicPart;
@property (nonatomic, copy) NSString *launcherBackgroundUrl;
@property (nonatomic, copy) NSString *logoUrl;
@property (nonatomic, copy) NSArray *imageUrls;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *packageName;
@property (nonatomic, assign) NSUInteger versionCode;
@property (nonatomic, copy) NSString *versionName;

+ (NSArray *)parseFromJSON:(NSDictionary *)dictionary;

@end
