//
//  TBFinalShareViewController.h
//  TagByLauncher
//
//  Created by Alek on 23.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

@import UIKit;

@protocol TBFinalShareViewControllerDelegate;

@class TBDocument;
@class TBSocialNetworksUser;

// This view controller is shown on iPhone (final share stage, including posting)
@interface TBFinalShareViewController_iPhone : UIViewController

@property (nonatomic, weak) id<TBFinalShareViewControllerDelegate> delegate;

@property (nonatomic, copy) NSString *applicationPackage;
@property (nonatomic, strong) TBDocument *document;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) UIImage *imageToShare;
@property (nonatomic, strong) TBSocialNetworksUser *user;
@property (nonatomic, copy) NSString *sharingMessage;
@property (nonatomic, copy) NSString *sharedMessage;

- (void)setGradientStartColor:(UIColor *)startColor endColor:(UIColor *)endColor;

@end
