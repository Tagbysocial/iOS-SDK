//
//  UIViewController+OrientationFix.m
//  TagByLauncher
//
//  Created by Alek on 09.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

@import UIKit;
#import "UINavigationController+OrientationFix.h"

@implementation UINavigationController (OrientationFix)

- (BOOL)shouldAutorotate
{
	return self.topViewController.shouldAutorotate;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return self.topViewController.supportedInterfaceOrientations;
}

@end
