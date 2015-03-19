//
//  TBOffer.h
//  TagByLauncher
//
//  Created by Alek on 08.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

@import Foundation;

@interface TBOffer : NSObject

@property (nonatomic, copy) NSString *guid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSURL *previewUrl;


+ (TBOffer *)parseFromJSON:(NSDictionary *)dictionary;

@end
