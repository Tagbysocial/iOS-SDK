//
//  TBSocialNetworksManager.h
//  TagByLauncher
//
//  Created by Alek on 22.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

@import Foundation;
@import UIKit;

extern const NSInteger kTBNoNetworkError;

typedef NS_ENUM(NSUInteger, TBSocialNetwork) {
    TBSocialNetworkFacebook = 1,
    TBSocialNetworkTwitter = 2,
    TBSocialNetworkEmail = 3
};

@class TBSocialNetworksUser;
@class TBSocialNetworksPost;
@class TBSocialNetworks;

typedef void (^TBSocialNetworksOperationBlock)(NSError *error);
typedef void (^TBSocialNetworksUserStatusOperationBlock)(TBSocialNetworksUser *user, NSError *error);

@interface TBSocialNetworksManager : NSObject

// Useful for a web view
+ (NSURL *)registrationUrlWithDeviceGuid:(NSString *)deviceGuid offerGuid:(NSString *)offerGuid userTag:(NSString*)userTag;
+ (NSURL *)registrationUrlWithDeviceGuid:(NSString *)deviceGuid offerGuid:(NSString *)offerGuid socialNetwork:(TBSocialNetwork)socialNetwork userTag:(NSString*)userTag;

+ (void)checkUserStatusWithApplicationGuid:(NSString *)guid applicationSecret:(NSString *)secret deviceGuid:(NSString *)deviceGuid offerGuid:(NSString *)offerGuid userTag:(NSString *)userTag block:(TBSocialNetworksUserStatusOperationBlock)block;

+ (void)postMessageApplicationGuid:(NSString *)guid applicationSecret:(NSString *)secret deviceGuid:(NSString *)deviceGuid offerGuid:(NSString *)offerGuid users:(NSArray *)users post:(TBSocialNetworksPost *)post onSocialNetworks:(TBSocialNetworks *)networks block:(TBSocialNetworksOperationBlock)block;

+ (void)postAnalyticsEventWithApplicationGuid:(NSString *)guid applicationSecret:(NSString *)secret deviceGuid:(NSString *)deviceGuid offerGuid:(NSString *)offerGuid event:(NSString *)event value:(NSString *)value userId:(NSString *)userId;

@end
