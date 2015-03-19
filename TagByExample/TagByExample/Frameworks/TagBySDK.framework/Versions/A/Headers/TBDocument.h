//
//  TBSchedule.h
//  TagByLauncher
//
//  Created by Alek on 06.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

@import Foundation;

@class TBBackground;
@class TBSettings;
@class TBSocialNetworks;
@class TBOffer;

@interface TBDocument : NSObject

@property (nonatomic, strong) TBBackground *background;
@property (nonatomic, strong) TBSettings *settings;
@property (nonatomic, strong) TBSocialNetworks *socialNetworks;
@property (nonatomic, strong) TBOffer *offer;
@property (nonatomic, strong) NSArray *widgets;

+ (NSArray *)parseFromJSON:(NSDictionary *)dictionary;

@end
