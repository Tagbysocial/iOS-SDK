//
//  TBAddFriendViewController.h
//  TagByLauncher
//
//  Created by Alek on 25.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

@import UIKit;

@class TBSelectShareNetworkViewController;
@class TBSocialNetworksUser;
@class TBDocument;

@protocol TBSelectShareNetworkViewControllerDelegate <NSObject>

- (void)didCloseViewController:(TBSelectShareNetworkViewController *)viewController userLogged:(TBSocialNetworksUser *)user cancelled:(BOOL)cancelled;

@end

// This view controller is shown when sharing on iPhone (manual login)
// It allows selecting the social network to use (based on the allowed share networks in the selected offer document)
@interface TBSelectShareNetworkViewController : UIViewController

@property (nonatomic, weak) id<TBSelectShareNetworkViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL returnOnUserLogin;
@property (nonatomic, assign) BOOL isAddingFriend;

@property (nonatomic, copy) NSString *applicationPackage;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) UIImage *imageToShare;
@property (nonatomic, strong) TBDocument *document;
@property (nonatomic, copy) NSString *sharingMessage;
@property (nonatomic, copy) NSString *sharedMessage;

- (void)setGradientStartColor:(UIColor *)startColor endColor:(UIColor *)endColor;

@end
