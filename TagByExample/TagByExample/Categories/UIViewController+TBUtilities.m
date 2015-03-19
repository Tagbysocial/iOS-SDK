//
//  UIViewController+TBUtilities.m
//  TagByLauncher
//
//  Created by Alek on 30.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "UIViewController+TBUtilities.h"
@import ObjectiveC.runtime;
@import AVFoundation;

static const NSString *kUIViewControllerTBUtilitiesPlayerKey = @"UIViewControllerTBUtilitiesSpinSoundKey";


@implementation UIViewController (TBUtilities)

- (void)playBipSound
{
    [self playSound:@"bip" extension:@"wav"];
}

- (void)playSound:(NSString *)filename extension:(NSString *)extension
{
    AVPlayer *player = objc_getAssociatedObject(self, (__bridge void *)kUIViewControllerTBUtilitiesPlayerKey);
    if(player) {
        [player pause];
        objc_setAssociatedObject(self, (__bridge void *)kUIViewControllerTBUtilitiesPlayerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    player = [[AVPlayer alloc] initWithURL:[[NSBundle mainBundle] URLForResource:filename withExtension:extension]];
    objc_setAssociatedObject(self, (__bridge void *)kUIViewControllerTBUtilitiesPlayerKey, player, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [player play];
}

@end
