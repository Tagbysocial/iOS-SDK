//
//  TBOfferRefresher.h
//  TagByLauncher
//
//  Created by Alek on 03.11.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

@import Foundation;
#import "TagBYSDK/TagBySDK.h"

// Refreshed offers (in form of TBDocument)
@protocol TBOfferRefresherDelegate <NSObject>

- (void)didRefreshOffers:(NSArray *)documents;

@optional
- (void)didGetRefreshOffersError:(NSError *)error;

@end

// This class is used to automatically refresh offers available to the application
@interface TBOfferRefresher : NSObject

@property (nonatomic, weak) id<TBOfferRefresherDelegate> delegate;

- (instancetype)initWithApplicationPackage:(NSString *)applicationPackage;

- (void)startRefreshingOffersWithPopup:(BOOL)showPopup;
- (void)stopRefreshingOffers;

@end
