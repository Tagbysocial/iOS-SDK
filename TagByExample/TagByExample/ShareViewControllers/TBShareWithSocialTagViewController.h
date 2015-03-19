//
//  TBShareViewController.h
//  TagByLauncher
//
//  Created by Alek on 22.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

@import UIKit;

@class TBShareWithSocialTagViewController;
@class TBDocument;
@class TBSocialNetworksUser;

@protocol TBShareWithSocialTagViewControllerDelegate <NSObject>

- (void)didCloseViewController:(TBShareWithSocialTagViewController *)viewController userLogged:(TBSocialNetworksUser *)user;

@end

// This view controller is shown first when sharing on iPhone
// It allows either to scan the user barcode to log in on the social network or to move to select the social network (manual login)
@interface TBShareWithSocialTagViewController : UIViewController

@property (nonatomic, weak) id<TBShareWithSocialTagViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL returnOnUserLogin;
@property (nonatomic, assign) BOOL isAddingFriend;

@property (nonatomic, copy) NSString *applicationPackage;
@property (nonatomic, strong) TBDocument *document;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) UIImage *imageToShare;
@property (nonatomic, copy) NSString *sharingMessage;
@property (nonatomic, copy) NSString *sharedMessage;

- (void)setGradientStartColor:(UIColor *)startColor endColor:(UIColor *)endColor;

@end
