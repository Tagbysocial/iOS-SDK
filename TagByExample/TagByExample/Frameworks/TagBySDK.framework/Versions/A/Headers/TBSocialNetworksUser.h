//
//  TBSocialNetworksUser.h
//  TagByLauncher
//
//  Created by Alek on 22.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

@import Foundation;

@interface TBSocialNetworksUser : NSObject

@property (nonatomic, copy) NSString *facebookEmail;
@property (nonatomic, copy) NSString *facebookName;
@property (nonatomic, copy) NSString *facebookId;
@property (nonatomic, strong) NSURL *facebookPictureUrl;
@property (nonatomic, assign) BOOL isFacebookTokenValid;
@property (nonatomic, copy) NSString *facebookUsedTag;
@property (nonatomic, assign) NSUInteger facebookUserId;

@property (nonatomic, copy) NSString *twitterEmail;
@property (nonatomic, copy) NSString *twitterName;
@property (nonatomic, copy) NSString *twitterId;
@property (nonatomic, strong) NSURL *twitterPictureUrl;
@property (nonatomic, assign) BOOL isTwitterTokenValid;
@property (nonatomic, copy) NSString *twitterUsedTag;
@property (nonatomic, assign) NSUInteger twitterUserId;

@property (nonatomic, copy) NSString *emailEmail;
@property (nonatomic, copy) NSString *emailName;
@property (nonatomic, copy) NSString *emailUsedTag;
@property (nonatomic, assign) NSUInteger emailUserId;

+ (TBSocialNetworksUser *)parseFromJSON:(NSDictionary *)dictionary;

@end
