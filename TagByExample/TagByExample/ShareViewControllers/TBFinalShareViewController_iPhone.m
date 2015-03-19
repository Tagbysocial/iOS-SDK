//
//  TBFinalShareViewController.m
//  TagByLauncher
//
//  Created by Alek on 23.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBFinalShareViewController_iPhone.h"
#import "TBFinalShareViewController.h"
#import "TBShareWithSocialTagViewController.h"
#import <TagBySDK/TagBySDK.h>
#import "SVProgressHUD.h"
#import "TBPreviewImageCollectionViewCell.h"
#import "TBAddFriendViewController.h"
#import "UIViewController+TBUtilities.h"
#import "TBUICollectionViewAddFriendCellCollectionViewCell.h"
#import "TBExampleSettings.h"

static NSString * const kAddFriendSegue = @"addFriendSegue";
static NSString * const kEventShareUsersShown = @"share_users_shown";

@interface TBFinalShareViewController_iPhone () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TBShareWithSocialTagViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *usersCollectionView;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;

@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, strong) UIColor *endColor;

@property (nonatomic, strong) NSMutableArray *postingUsers;

@end

@implementation TBFinalShareViewController_iPhone

- (void)dealloc
{
  self.usersCollectionView.dataSource = nil;
  self.usersCollectionView.delegate = nil;
}

#pragma mark - View initialization
- (void)setGradientStartColor:(UIColor *)startColor endColor:(UIColor *)endColor
{
    self.startColor = startColor;
    self.endColor = endColor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    // Background gradient from provided background colors
    CGSize size = self.view.frame.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t gradientNumberOfLocations = 2;
    CGFloat gradientLocations[2] = { 0.0, 1.0 };
    CGFloat startRed, startGreen, startBlue, startAlpha, endRed, endGreen, endBlue, endAlpha;
    [self.startColor getRed:&startRed green:&startGreen blue:&startBlue alpha:&startAlpha];
    [self.endColor getRed:&endRed green:&endGreen blue:&endBlue alpha:&endAlpha];
    CGFloat gradientComponents[8] = { startRed, startGreen, startBlue, startAlpha, endRed, endGreen, endBlue, endAlpha};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, gradientComponents, gradientLocations, gradientNumberOfLocations);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, size.height), 0);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    self.backgroundView.alpha = 1.;
    self.backgroundView.backgroundColor = [UIColor clearColor];
    
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.text = self.message;
    self.shareButton.layer.cornerRadius = 4.;
    self.shareButton.layer.borderWidth = 2.;
    self.shareButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    //Users that have logged in (principal user + friends)
    self.postingUsers = [NSMutableArray arrayWithObject:self.user];
    
    UINib *nib = [UINib nibWithNibName:@"TBPreviewImageCollectionViewCell" bundle: nil];
    [self.usersCollectionView registerNib:nib forCellWithReuseIdentifier:@"tbPreviewCell"];
    self.usersCollectionView.dataSource = self;
    self.usersCollectionView.delegate = self;
    
    UITapGestureRecognizer *userCellTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapUsersCollectionView:)];
    userCellTapRecognizer.numberOfTapsRequired = 1;
    [self.usersCollectionView addGestureRecognizer:userCellTapRecognizer];
    [self.usersCollectionView registerClass:TBUICollectionViewAddFriendCellCollectionViewCell.class forCellWithReuseIdentifier:@"tbAddFriendCell"];

    // Useful for analytics
    [self postAnalyticsMessage:self.user];
}

#pragma mark - Collection view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if((self.postingUsers.count + 1) % 2 == 0) {
        return (self.postingUsers.count + 1) / 2;
    }
    
    return (self.postingUsers.count + 1) / 2 + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if((self.postingUsers.count + 1) % 2 == 0) {
        return 2;
    }

    if(section < (NSInteger)self.postingUsers.count / 2) {
        return 2;
    }

    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = indexPath.section * 2 + indexPath.row;
    if(index < self.postingUsers.count) {
        TBPreviewImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tbPreviewCell" forIndexPath:indexPath];
        TBSocialNetworksUser *user = self.postingUsers[index];
        [cell showImage:user.facebookPictureUrl backgroundColor:[UIColor clearColor] socialNetwork:TBSocialNetworkFacebook];
        return cell;
    }
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tbAddFriendCell" forIndexPath:indexPath];
    return cell;
}

- (void)didTapUsersCollectionView:(UITapGestureRecognizer *)sender
{
    CGPoint currentTouchPosition = [sender locationInView:self.usersCollectionView];
    NSIndexPath *indexPath = [self.usersCollectionView indexPathForItemAtPoint: currentTouchPosition];
    NSUInteger index = indexPath.section * 2 + indexPath.row;
    if(index == self.postingUsers.count) {
        [self performSegueWithIdentifier:kAddFriendSegue sender:self];
    }
}

#pragma mark - Collection view flow delegate
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat lineSpacing = ((UICollectionViewFlowLayout *)collectionViewLayout).minimumLineSpacing;
    CGFloat itemSpacing = ((UICollectionViewFlowLayout *)collectionViewLayout).minimumInteritemSpacing;
    if((self.postingUsers.count + 1) % 2 == 0 || section < (NSInteger)((self.postingUsers.count + 1) / 2)) {
        if(section == 0) {
            return UIEdgeInsetsMake(0., 0., itemSpacing / 2, 0.);
        }

        return UIEdgeInsetsMake(itemSpacing / 2, 0., itemSpacing / 2, 0.);
    }
    
    CGFloat largeItemSpacing = (self.usersCollectionView.bounds.size.width - 80.) / 2;
    return UIEdgeInsetsMake(lineSpacing / 2, largeItemSpacing, 0., largeItemSpacing);
}

- (IBAction)didClickShareNow:(id)sender
{
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if(!strongSelf) {
            return;
        }
        
        // Application info received from the Launcher
        TBExampleSettings *settings = TBExampleSettings.sharedInstance;
        NSString *guid = settings.appGuid;
        NSString *secret = settings.appSecret;
        NSString *deviceGuid = settings.deviceGuid;

        // Post (image)
        TBSocialNetworksPost *post = [TBSocialNetworksPost new];
        post.image = strongSelf.imageToShare;
        
        NSString *sharingMessage = strongSelf.sharingMessage ?: NSLocalizedString(@"Publishing", nil);
        NSString *sharedMessage = strongSelf.sharedMessage ?: NSLocalizedString(@"MessagePublished", nil);
        
        // Post on the social network
        [SVProgressHUD showWithStatus:sharingMessage maskType:SVProgressHUDMaskTypeBlack];
        [TBSocialNetworksManager postMessageApplicationGuid:guid applicationSecret:secret deviceGuid:deviceGuid offerGuid:strongSelf.document.offer.guid users:strongSelf.postingUsers post:post onSocialNetworks:strongSelf.document.socialNetworks block:^(NSError *error) {
            __strong __typeof(weakSelf) strongSelf2 = weakSelf;
            if(!strongSelf2) {
                [SVProgressHUD dismiss];
                return;
            }

            if(error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(error.code == kTBNoNetworkError) {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NetworkProblem", nil)];
                    }
                    else {
                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    }
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showSuccessWithStatus:sharedMessage];
                    [strongSelf2 didClickCloseButton:nil];
                });
            }
        }];
    });
}

- (IBAction)didClickAddFriend:(id)sender
{
    [self performSegueWithIdentifier:kAddFriendSegue sender:self];
}

- (void)addPostingUser:(TBSocialNetworksUser *)user
{
    BOOL skip = NO;
    // Let's check if the user is already in the users array
    for(TBSocialNetworksUser *postingUser in self.postingUsers) {
        if((self.document.socialNetworks.usesFacebook && [user.facebookId isEqualToString:postingUser.facebookId] ) ||
           (self.document.socialNetworks.usesTwitter && [user.twitterId isEqualToString:postingUser.twitterId]) ||
           (self.document.socialNetworks.usesEmail && [user.emailEmail isEqualToString:postingUser.emailEmail])) {
            skip = YES;
        }
    }
    
    if(!skip) {
        [self.postingUsers addObject:user];
        [self.usersCollectionView reloadData];
        [self postAnalyticsMessage:user];
    }
}

- (void)postAnalyticsMessage:(TBSocialNetworksUser *)user
{
    TBExampleSettings *settings = TBExampleSettings.sharedInstance;
    NSString *guid = settings.appGuid;
    NSString *secret = settings.appSecret;
    NSString *deviceGuid = settings.deviceGuid;
    NSString *userId = user ? [NSString stringWithFormat:@"%lu", (unsigned long)user.facebookUserId] : nil;
    [TBSocialNetworksManager postAnalyticsEventWithApplicationGuid:guid applicationSecret:secret deviceGuid:deviceGuid offerGuid:self.document.offer.guid event:kEventShareUsersShown value:nil userId:userId];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Move to AddFriend controller
    if([segue.identifier isEqualToString:kAddFriendSegue]) {
        TBShareWithSocialTagViewController *addFriendVC = segue.destinationViewController;
        addFriendVC.delegate = self;
        addFriendVC.document = self.document;
        addFriendVC.applicationPackage = self.applicationPackage;
        [addFriendVC setGradientStartColor:self.startColor endColor:self.endColor];
        addFriendVC.message = NSLocalizedString(@"AddFriend", nil);
        addFriendVC.isAddingFriend = YES;
        self.view.hidden = YES;
        
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            self.providesPresentationContextTransitionStyle = YES;
            self.definesPresentationContext = YES;
            addFriendVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        else {
            self.modalPresentationStyle = UIModalPresentationCurrentContext;
        }
    }
}

#pragma mark - Hide status bar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - TBAddFriendViewControllerDelegate
- (void)didLogSocialUser:(TBSocialNetworksUser *)user
{
    self.view.hidden = NO;
    [self addPostingUser:user];
}

- (void)didCancelLoggingSocialUser:(TBAddFriendViewController *)viewController
{
    self.view.hidden = NO;
}

- (void)didCloseViewController:(TBAddFriendViewController *)viewController
{
    [self didClickCloseButton:self];
}

#pragma mark - TBSelectShareNetworkViewControllerDelegate
- (void)didCloseViewController:(TBShareWithSocialTagViewController *)viewController userLogged:(TBSocialNetworksUser *)user
{
    self.view.hidden = NO;
    [viewController dismissViewControllerAnimated:YES completion:^{
    }];
    
    if(user) {
        [self addPostingUser:user];
    }
}

#pragma mark - Go to take picture view
- (IBAction)didClickCloseButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if([self.delegate respondsToSelector:@selector(didCloseViewController:)]) {
            [self.delegate didCloseViewController:self];
        }
    }];
}

@end
