//
//  TBBackground.h
//  TagByLauncher
//
//  Created by Alek on 07.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface TBBackground : NSObject

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSURL *imageUrl;

+ (TBBackground *)parseFromJSON:(NSDictionary *)dictionary;

@end
