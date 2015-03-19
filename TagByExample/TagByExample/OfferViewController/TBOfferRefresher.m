//
//  TBOfferRefresher.m
//  TagByLauncher
//
//  Created by Alek on 03.11.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBOfferRefresher.h"
#import <TagBySDK/PARDispatchQueue.h>
#import <TagBySDK/TagBySDK.h>
#import "SVProgressHUD.h"
#import "TBExampleSettings.h"

static NSString *const kTBOfferRefresherQueueLabel = @"TBOfferRefresherQueueLabel";
static NSString *const kTBOfferRefresherQueueLabelTimerName = @"TBOfferRefresherQueueLabelTimerName";
static const NSTimeInterval kRefreshOffersInterval = 60.;

@interface TBOfferRefresher ()

@property (nonatomic, copy) NSString *deviceGuid;
@property (nonatomic, copy) NSString *appGuid;
@property (nonatomic, copy) NSString *appSecret;

@property (nonatomic, strong) PARDispatchQueue *parQueue;

@end

@implementation TBOfferRefresher

#pragma mark - Initializer
- (instancetype)initWithApplicationPackage:(NSString *)applicationPackage
{
    if((self = [super init])) {
        _deviceGuid = TBExampleSettings.sharedInstance.deviceGuid;
        _appGuid = TBExampleSettings.sharedInstance.appGuid;
        _appSecret = TBExampleSettings.sharedInstance.appSecret;
        
        _parQueue = [PARDispatchQueue dispatchQueueWithLabel:kTBOfferRefresherQueueLabel];
    }
    
    return self;
}

#pragma mark - Offer refresh management
- (void)startRefreshingOffersWithPopup:(BOOL)showPopup
{
    if(showPopup) {
        dispatch_async(dispatch_get_main_queue(), ^{
           [SVProgressHUD showWithStatus:NSLocalizedString(@"LoadingCampaigns", nil) maskType:SVProgressHUDMaskTypeBlack];
        });
    }
    
    __weak __typeof(self) weakSelf = self;
    [TBScheduleManager applicationScheduleWithDeviceGuid:TBExampleSettings.sharedInstance.deviceGuid applicationGuid:self.appGuid secret:self.appSecret block:^(NSArray *documents, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if(!strongSelf) {
            return;
        }
        
        if(error) {
            if([strongSelf.delegate respondsToSelector:@selector(didGetRefreshOffersError:)]) {
                [strongSelf.delegate didGetRefreshOffersError:error];
            }
        }
        else {
            if(showPopup) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
            }
            
            if([strongSelf.delegate respondsToSelector:@selector(didRefreshOffers:)]) {
                [strongSelf.delegate didRefreshOffers:documents];
            }
        }
    }];
    
    [self.parQueue scheduleTimerWithName:kTBOfferRefresherQueueLabelTimerName timeInterval:kRefreshOffersInterval behavior:PARTimerBehaviorCoalesce block:^{
        [self startRefreshingOffersWithPopup:showPopup];
    }];
}

- (void)stopRefreshingOffers
{
    [self.parQueue cancelTimerWithName:kTBOfferRefresherQueueLabelTimerName];
}

@end
