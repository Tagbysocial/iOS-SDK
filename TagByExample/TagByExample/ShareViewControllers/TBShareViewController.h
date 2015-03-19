//
//  TBShareViewController.h
//  TagByLauncher
//
//  Created by Alek on 22.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

@import UIKit;

@class TBShareViewController;
@class TBDocument;
@class TBSocialNetworksUser;

@protocol TBShareViewControllerDelegate <NSObject>

- (void)didCloseViewController:(TBShareViewController *)viewController userLogged:(TBSocialNetworksUser *)user;

@end

// This view controller is first shown when sharing on iPad
@interface TBShareViewController : UIViewController

@property (nonatomic, weak) id<TBShareViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL returnOnUserLogin;

@property (nonatomic, copy) NSString *applicationPackage;
@property (nonatomic, strong) TBDocument *document;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) UIImage *imageToShare;
@property (nonatomic, copy) NSString *sharingMessage;
@property (nonatomic, copy) NSString *sharedMessage;

- (void)setGradientStartColor:(UIColor *)startColor endColor:(UIColor *)endColor;

@end
