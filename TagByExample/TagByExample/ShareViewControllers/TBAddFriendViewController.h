//
//  TBAddFriendViewController.h
//  TagByLauncher
//
//  Created by Alek on 25.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

@import UIKit;

@class TBAddFriendViewController;
@class TBSocialNetworksUser;

@protocol TBAddFriendViewControllerDelegate <NSObject>

- (void)didLogSocialUser:(TBSocialNetworksUser *)user;
- (void)didCancelLoggingSocialUser:(TBAddFriendViewController *)viewController;
- (void)didCloseViewController:(TBAddFriendViewController *)viewController;

@end

@class TBDocument;

// This view controller is used to add friends to share on iPad
@interface TBAddFriendViewController : UIViewController

@property (nonatomic, weak) id<TBAddFriendViewControllerDelegate> delegate;

@property (nonatomic, copy) NSString *applicationPackage;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) TBDocument *document;

- (void)setGradientStartColor:(UIColor *)startColor endColor:(UIColor *)endColor;

@end
