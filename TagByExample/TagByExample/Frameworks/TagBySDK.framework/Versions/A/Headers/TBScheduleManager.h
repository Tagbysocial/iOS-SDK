//
//  TBScheduleManager.h
//  TagByLauncher
//
//  Created by Alek on 07.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

@import Foundation;

@class TBDocument;
typedef void (^TBScheduleOperationBlock)(NSArray *documents, NSError *error);

@interface TBScheduleManager : NSObject

+ (void)applicationScheduleWithDeviceGuid:(NSString *)deviceGuid applicationGuid:(NSString *)appGuid secret:(NSString *)appSecret block:(TBScheduleOperationBlock)block;

@end
