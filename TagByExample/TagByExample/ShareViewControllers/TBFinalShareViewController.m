//
//  TBFinalShareViewController.m
//  TagByLauncher
//
//  Created by Alek on 23.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBFinalShareViewController.h"
#import <TagBySDK/TBBarcodePreviewController.h>
#import <TagBySDK/TBBarcodePreview.h>
#import <TagBySDK/TagBySDK.h>
#import "SVProgressHUD.h"
#import "TBPreviewImageCollectionViewCell.h"
#import "TBAddFriendViewController.h"
#import "UIViewController+TBUtilities.h"
#import "TBExampleSettings.h"

static NSString * const kAddFriendSegue = @"addFriendSegue";
static NSString * const kEventShareUsersShown = @"share_users_shown";

@interface TBFinalShareViewController () <TBBarcodePreviewDelegate, UIWebViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TBAddFriendViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *usersCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, weak) IBOutlet UIButton *addFriendButton;
@property (nonatomic, strong) TBBarcodePreviewController *barcodeController;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, strong) UIColor *endColor;

@property (nonatomic, strong) NSMutableArray *postingUsers;

@end

@implementation TBFinalShareViewController

- (void)dealloc
{
  self.webView.delegate = nil;
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
    
    self.shareLabel.text = NSLocalizedString(@"YourFriendCanShare", nil);
    
    self.messageLabel.text = self.message;
    self.shareButton.layer.cornerRadius = 4.;
    self.shareButton.layer.borderWidth = 2.;
    self.shareButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.addFriendButton.layer.cornerRadius = 4.;
    self.addFriendButton.layer.borderWidth = 2.;
    self.addFriendButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.webView.hidden = YES;
    self.webView.delegate = self;
    
    TBBarcodePreview *tbBarcodePreview = [[TBBarcodePreview alloc] init];
    tbBarcodePreview.frame = CGRectMake(437., 536., 150., 150.);
    tbBarcodePreview.source = TBCameraSourceBackFront;
    self.barcodeController = [[TBBarcodePreviewController alloc] initWithSuperview:self.backgroundView tbBarcodePreview:tbBarcodePreview];
    self.barcodeController.cameraSide = TBCameraSideFront;
    self.barcodeController.delegate = self;
    [self.barcodeController startReadingBarcodes];
    
    self.postingUsers = [NSMutableArray arrayWithObject:self.user];
    
    UINib *nib = [UINib nibWithNibName:@"TBPreviewImageCollectionViewCell" bundle: nil];
    [self.usersCollectionView registerNib:nib forCellWithReuseIdentifier:@"tbPreviewCell"];
    self.usersCollectionView.dataSource = self;
    self.usersCollectionView.delegate = self;
    
    [self postAnalyticsMessage:self.user];
}

#pragma mark - Collection view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.postingUsers.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TBPreviewImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tbPreviewCell" forIndexPath:indexPath];
    TBSocialNetworksUser *user = self.postingUsers[indexPath.section];
    [cell showImage:user.facebookPictureUrl backgroundColor:[UIColor clearColor] socialNetwork:TBSocialNetworkFacebook];
    
    return cell;
}

#pragma mark - Collection view flow delegate
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat cellSpacing = ((UICollectionViewFlowLayout *)collectionViewLayout).minimumLineSpacing;
    CGFloat cellWidth = ((UICollectionViewFlowLayout *)collectionViewLayout).itemSize.width;
    NSInteger cellCount = collectionView.numberOfSections;
    CGFloat inset = (collectionView.bounds.size.width - (cellCount * cellWidth + (cellCount - 1) * cellSpacing * 2)) / 2;
    inset = MAX(inset, cellSpacing);
    if(section == 0) {
        return UIEdgeInsetsMake(0., inset, 0., cellSpacing);
    }
    else if(section == cellCount - 1) {
        return UIEdgeInsetsMake(0., cellSpacing, 0., inset);
    }
    else {
        return UIEdgeInsetsMake(0., cellSpacing, 0., cellSpacing);
    }
}

- (IBAction)didClickSwitchBarcodeCamera:(id)sender
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(!strongSelf) {
            return;
        }
        
        TBCameraSide currentCameraSide = strongSelf.barcodeController.cameraSide;
        if(currentCameraSide == TBCameraSideFront) {
            strongSelf.barcodeController.cameraSide = TBCameraSourceBack;
        }
        else {
            strongSelf.barcodeController.cameraSide = TBCameraSourceFront;
        }
    });
}

- (IBAction)didClickShareNow:(id)sender
{
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if(!strongSelf) {
            return;
        }
        
        [strongSelf.barcodeController stopReadingBarcodes];
        
        TBExampleSettings *settings = TBExampleSettings.sharedInstance;
        NSString *guid = settings.appGuid;
        NSString *secret = settings.appSecret;
        NSString *deviceGuid = settings.deviceGuid;

        TBSocialNetworksPost *post = [TBSocialNetworksPost new];
        post.image = strongSelf.imageToShare;
        
        NSString *sharingMessage = strongSelf.sharingMessage ?: NSLocalizedString(@"Publishing", nil);
        NSString *sharedMessage = strongSelf.sharedMessage ?: NSLocalizedString(@"MessagePublished", nil);
        
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
                    [strongSelf2.barcodeController startReadingBarcodes];
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
    [self.barcodeController stopReadingBarcodes];
    [self performSegueWithIdentifier:kAddFriendSegue sender:self];
}

- (void)addPostingUser:(TBSocialNetworksUser *)user
{
    BOOL skip = NO;
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
    if([segue.identifier isEqualToString:kAddFriendSegue]) {
        TBAddFriendViewController *addFriendVC = segue.destinationViewController;
        addFriendVC.delegate = self;
        addFriendVC.document = self.document;
        addFriendVC.applicationPackage = self.applicationPackage;
        [addFriendVC setGradientStartColor:self.startColor endColor:self.endColor];
        addFriendVC.message = NSLocalizedString(@"AddFriend", nil);
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

#pragma mark - TBAddFriendViewControllerDelegate
- (void)didLogSocialUser:(TBSocialNetworksUser *)user
{
    self.view.hidden = NO;
    [self addPostingUser:user];
    [self.barcodeController startReadingBarcodes];
}

- (void)didCancelLoggingSocialUser:(TBAddFriendViewController *)viewController
{
    self.view.hidden = NO;
    [self.barcodeController startReadingBarcodes];
}

- (void)didCloseViewController:(TBAddFriendViewController *)viewController
{
    [self didClickCloseButton:self];
}

#pragma mark - TBBarcodePreviewDelegate
- (void)didReadBarcode:(NSString *)barcode
{
    [self playBipSound];
    [self.barcodeController stopReadingBarcodes];
    
    TBExampleSettings *settings = TBExampleSettings.sharedInstance;
    NSString *guid = settings.appGuid;
    NSString *secret = settings.appSecret;
    NSString *deviceGuid = settings.deviceGuid;
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"CheckingTag", nil) maskType:SVProgressHUDMaskTypeBlack];
    __weak __typeof(self) weakSelf = self;
    [TBSocialNetworksManager checkUserStatusWithApplicationGuid:guid applicationSecret:secret deviceGuid:deviceGuid offerGuid:self.document.offer.guid userTag:barcode block:^(TBSocialNetworksUser *user, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if(!strongSelf) {
            [SVProgressHUD dismiss];
            return;
        }
        
        if(error || (!user.isFacebookTokenValid && !user.isTwitterTokenValid)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong __typeof(weakSelf) strongSelf2 = weakSelf;
                if(!strongSelf2) {
                    [SVProgressHUD dismiss];
                    return;
                }
                
                if(error.code == kTBNoNetworkError) {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NetworkProblem", nil)];
                    [strongSelf2.barcodeController startReadingBarcodes];
                }
                else {
                    [SVProgressHUD dismiss];
                    NSURL *url = [TBSocialNetworksManager registrationUrlWithDeviceGuid:deviceGuid offerGuid:strongSelf2.document.offer.guid userTag:barcode];
                    [strongSelf2 showWebView:url];
                }
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong __typeof(weakSelf) strongSelf2 = weakSelf;
                if(!strongSelf2) {
                    [SVProgressHUD dismiss];
                    return;
                }
                
                [SVProgressHUD dismiss];
                [strongSelf2 addPostingUser:user];
                [strongSelf2.barcodeController startReadingBarcodes];
            });
        }
    }];
}

#pragma mark - UIWebView management
- (void)showWebView:(NSURL *)url
{
    [self.barcodeController stopReadingBarcodes];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    self.webView.hidden = NO;
}

- (void)hideWebView:(BOOL)activateBarcodeReading
{
    self.webView.hidden = YES;
    [self.webView stopLoading];
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(activateBarcodeReading) {
        [self.barcodeController startReadingBarcodes];
    }
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *scheme = [self.applicationPackage stringByReplacingOccurrencesOfString:@"." withString:@""];
    if([request.URL.scheme hasPrefix:scheme]) {
        TBSocialNetworksUser *user = [self parseWebViewResponse:request.URL];
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if(!strongSelf) {
                return;
            }
            
            [strongSelf hideWebView:!user];

            /*if(!user) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"LoginError", nil)];
             }
             else {*/
            if(user) {
                [strongSelf addPostingUser:user];
            }
        });
        
        return NO;
    }
    
    return YES;
}

- (TBSocialNetworksUser *)parseWebViewResponse:(NSURL *)response
{
    NSString *stringToDecode = [response absoluteString];
    NSRange beginning = [stringToDecode rangeOfString:@"#"];
    if(beginning.location == NSNotFound) {
        return nil;
    }
    stringToDecode = [stringToDecode substringFromIndex:(beginning.location + 1)];
    NSString *decodedString = [stringToDecode stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [decodedString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if (!jsonDict) {
        return nil;
    }
    
    return [TBSocialNetworksUser parseFromJSON:jsonDict];
}

#pragma mark - Hide status bar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Go to take picture view
- (IBAction)didClickCloseButton:(id)sender
{
    [self.barcodeController stopReadingBarcodes];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if([self.delegate respondsToSelector:@selector(didCloseViewController:)]) {
            [self.delegate didCloseViewController:self];
        }
    }];
}

@end
