//
//  TBExampleSettings.h
//  TagByExample
//
//  Created by Alek on 05.11.2014.
//  Copyright (c) 2014 Alek. All rights reserved.
//

@import Foundation;

@interface TBExampleSettings : NSObject

// This information is all you need to be able to use the Tag'by system from your application (document schedule, social networks posting)
@property (nonatomic, copy) NSString *deviceGuid;
@property (nonatomic, copy) NSString *appGuid;
@property (nonatomic, copy) NSString *appSecret;
@property (nonatomic, copy) NSString *appPackage;

// Singleton
+ (TBExampleSettings *)sharedInstance;

@end
