//
//  TBSocialNetworks.h
//  TagByLauncher
//
//  Created by Alek on 08.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

@import Foundation;

@interface TBSocialNetworks : NSObject

@property (nonatomic, assign) BOOL usesFacebook;
@property (nonatomic, assign) BOOL usesTwitter;
@property (nonatomic, assign) BOOL usesEmail;

+ (TBSocialNetworks *)parseFromJSON:(NSDictionary *)dictionary;

@end
