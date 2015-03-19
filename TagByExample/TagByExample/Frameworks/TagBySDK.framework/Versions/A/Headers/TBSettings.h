//
//  TBSettings.h
//  TagByLauncher
//
//  Created by Alek on 07.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSUInteger, TBDeviceOrientation) {
	TBDeviceOrientationUnknown = 0,
	TBDeviceOrientationPortrait = 1,
	TBDeviceOrientationLandscape = 2
};

@interface TBSettings : NSObject

@property (nonatomic, assign) TBDeviceOrientation orientation;
@property (nonatomic, assign) BOOL blockScreenLocking;
@property (nonatomic, assign) BOOL enableNfc;
@property (nonatomic, copy) NSString *sharingMessage;
@property (nonatomic, copy) NSString *sharedMessage;
@property (nonatomic, copy) NSString *congratsMessage;
@property (nonatomic, copy) NSString *thanksMessage;
@property (nonatomic, copy) NSString *tryLaterMessage;
@property (nonatomic, copy) NSString *tryAgainButtonTitle;
@property (nonatomic, assign) NSUInteger numberOfAttempts;
@property (nonatomic, assign) NSUInteger chanceOfWinning;

+ (TBSettings *)parseFromJSON:(NSDictionary *)dictionary;

@end
