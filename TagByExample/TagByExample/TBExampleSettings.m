//
//  TBExampleSettings.m
//  TagByExample
//
//  Created by Alek on 05.11.2014.
//  Copyright (c) 2014 Alek. All rights reserved.
//

#import "TBExampleSettings.h"

@implementation TBExampleSettings

#pragma mark - Singleton
+ (TBExampleSettings *)sharedInstance
{
    static dispatch_once_t once;
    static TBExampleSettings *instance;
    
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    
    return instance;
}

@end
