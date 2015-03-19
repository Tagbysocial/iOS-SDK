//
//  TBShareViewController.m
//  TagByLauncher
//
//  Created by Alek on 22.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBShareWithSocialTagViewController.h"
#import <TagBySDK/TBBarcodePreviewController.h>
#import <TagBySDK/TBBarcodePreview.h>
#import <TagBySDK/TagBySDK.h>
#import "TBExampleSettings.h"
#import "SVProgressHUD.h"
#import "TBSelectShareNetworkViewController.h"
#import "TBFinalShareViewController_iPhone.h"
#import "TBFinalShareViewController.h"
#import "UIViewController+TBUtilities.h"

static NSString * const kShareWithNoSocialTagSegue = @"shareWithNoSocialTagSegue";
static NSString * const kFinalShareSegueiPhone = @"finalShareSegue2";
static NSString * const kEventShareNoUserShown = @"share_no_user_shown";

@interface TBShareWithSocialTagViewController () <TBBarcodePreviewDelegate, TBSelectShareNetworkViewControllerDelegate, TBFinalShareViewControllerDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) TBBarcodePreviewController *barcodeController;
@property (nonatomic, weak) IBOutlet UIButton *notTagButton;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeButtonX;

@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, strong) UIColor *endColor;

@property (nonatomic, strong) TBSocialNetworksUser *user;

@end

@implementation TBShareWithSocialTagViewController

- (void)dealloc
{
  self.webView.delegate = nil;
}

- (void)setGradientStartColor:(UIColor *)startColor endColor:(UIColor *)endColor
{
    self.startColor = startColor;
    self.endColor = endColor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    if(SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        self.viewX.constant += 8.;
        self.closeButtonX.constant -= 8.;
    }

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

    self.notTagButton.layer.cornerRadius = 4.;
    self.notTagButton.layer.borderWidth = 2.;
    self.notTagButton.layer.borderColor = [UIColor whiteColor].CGColor;

    self.messageLabel.numberOfLines = 0;
    self.messageLabel.text = self.message;
    self.webView.hidden = YES;
    self.webView.delegate = self;
    
    TBBarcodePreview *tbBarcodePreview = [[TBBarcodePreview alloc] init];
    tbBarcodePreview.frame = CGRectMake(85., 207., 150., 150.);
    tbBarcodePreview.source = TBCameraSourceBackFront;
    self.barcodeController = [[TBBarcodePreviewController alloc] initWithSuperview:self.backgroundView tbBarcodePreview:tbBarcodePreview];
    self.barcodeController.delegate = self;
    self.barcodeController.cameraSide = TBCameraSideBack;
    [self.barcodeController startReadingBarcodes];
    
    // Useful for analytics
    [self postAnalyticsMessage];
}

- (void)postAnalyticsMessage
{
    TBExampleSettings *settings = TBExampleSettings.sharedInstance;
    NSString *guid = settings.appGuid;
    NSString *secret = settings.appSecret;
    NSString *deviceGuid = settings.deviceGuid;
    [TBSocialNetworksManager postAnalyticsEventWithApplicationGuid:guid applicationSecret:secret deviceGuid:deviceGuid offerGuid:self.document.offer.guid event:kEventShareNoUserShown value:nil userId:nil];
}

- (IBAction)didClickSwitchBarcodeCamera:(id)sender
{
    // Changing the camera used to read user barcodes
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
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

#pragma mark - TBBarcodePreviewDelegate
- (void)didReadBarcode:(NSString *)barcode
{
    // User barcode read
    [self playBipSound];
    [self.barcodeController stopReadingBarcodes];
    
    TBExampleSettings *settings = TBExampleSettings.sharedInstance;
    NSString *guid = settings.appGuid;
    NSString *secret = settings.appSecret;
    NSString *deviceGuid = settings.deviceGuid;

    // Getting the user ID based on the read barcode
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
                
                // No network
                if(error.code == kTBNoNetworkError) {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NetworkProblem", nil)];
                    [strongSelf2.barcodeController startReadingBarcodes];
                }
                // Other error (for instance, no user account associated to the barcode
                // Let's move to manual login (to associate the account to the barcode)
                else {
                    [SVProgressHUD dismiss];
                    NSURL *url = [TBSocialNetworksManager registrationUrlWithDeviceGuid:deviceGuid offerGuid:strongSelf2.document.offer.guid userTag:barcode];
                    [strongSelf2 showWebView:url];
                }
            });
        }
        // Everything went fine (user logged in)
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                strongSelf.user = user;
                
                if(strongSelf.isAddingFriend || strongSelf.returnOnUserLogin) {
                    [strongSelf dismissWithLoggedUser:strongSelf.user];
                }
                else {
                    [strongSelf performSegueWithIdentifier:kFinalShareSegueiPhone sender:strongSelf];
                }
            });
        }
    }];
}

// Manual login selected
- (IBAction)didClickNoTagButton:(id)sender
{
    [self performSegueWithIdentifier:kShareWithNoSocialTagSegue sender:self];
}

#pragma mark - UIWebView management
- (void)showWebView:(NSURL *)url
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    self.webView.hidden = NO;
    if(IS_IPHONE_4) {
        self.viewHeight.constant = 480.;
    }
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
    
    if(IS_IPHONE_4) {
        self.viewHeight.constant = 568.;
    }

    if(activateBarcodeReading) {
        [self.barcodeController startReadingBarcodes];
    }
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *scheme = [self.applicationPackage stringByReplacingOccurrencesOfString:@"." withString:@""];
    if([request.URL.scheme hasPrefix:scheme]) {
        self.user = [self parseWebViewResponse:request.URL];
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if(!strongSelf) {
                return;
            }
            
            [strongSelf hideWebView:!strongSelf.user];
            
            // Error, the user did not log in
            /*if(!strongSelf.user) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"LoginError", nil)];
            }
            else {*/
            if(strongSelf.user) {
                // User logged in
                if(strongSelf.isAddingFriend || strongSelf.returnOnUserLogin) {
                    [strongSelf dismissWithLoggedUser:strongSelf.user];
                }
                else {
                    [strongSelf performSegueWithIdentifier:kFinalShareSegueiPhone sender:strongSelf];
                }
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

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Move to manual login
    if([segue.identifier isEqualToString:kShareWithNoSocialTagSegue]) {
        [self.barcodeController stopReadingBarcodes];
        
        TBSelectShareNetworkViewController *shareVC = segue.destinationViewController;
        shareVC.delegate = self;
        shareVC.applicationPackage = self.applicationPackage;
        shareVC.imageToShare = self.imageToShare;
        shareVC.document = self.document;
        [shareVC setGradientStartColor:self.startColor endColor:self.endColor];
        shareVC.message = self.message;
        shareVC.sharingMessage = self.sharingMessage;
        shareVC.sharedMessage = self.sharedMessage;
        shareVC.returnOnUserLogin = self.returnOnUserLogin;
        shareVC.isAddingFriend = self.isAddingFriend;
        self.view.hidden = YES;
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            self.providesPresentationContextTransitionStyle = YES;
            self.definesPresentationContext = YES;
            shareVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        else {
            self.modalPresentationStyle = UIModalPresentationCurrentContext;
        }
    }
    // Move to the final share screen
    else if([segue.identifier isEqualToString:kFinalShareSegueiPhone]) {
        [self.barcodeController stopReadingBarcodes];
        
        TBFinalShareViewController_iPhone *shareVC = segue.destinationViewController;
        shareVC.delegate = self;
        shareVC.applicationPackage = self.applicationPackage;
        shareVC.imageToShare = self.imageToShare;
        shareVC.document = self.document;
        [shareVC setGradientStartColor:self.startColor endColor:self.endColor];
        shareVC.user = self.user;
        shareVC.message = self.message;
        shareVC.sharingMessage = self.sharingMessage;
        shareVC.sharedMessage = self.sharedMessage;
        self.view.hidden = YES;
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            self.providesPresentationContextTransitionStyle = YES;
            self.definesPresentationContext = YES;
            shareVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
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

#pragma mark - TBFinalShareViewControllerDelegate
- (void)didCloseViewController:(id)viewController
{
    [self dismissWithLoggedUser:nil];
}

- (void)didCloseViewController:(TBSelectShareNetworkViewController *)viewController userLogged:(TBSocialNetworksUser *)user cancelled:(BOOL)cancelled
{
    if(!cancelled && (!self.isAddingFriend || user)) {
        [viewController dismissViewControllerAnimated:YES completion:^{
        }];
        [self dismissWithLoggedUser:user];
    }
    else {
        self.view.hidden = NO;
        [viewController dismissViewControllerAnimated:YES completion:^{
        }];
        [self.barcodeController startReadingBarcodes];
    }
}

#pragma mark - Go to main offer view
- (IBAction)didClickCloseButton:(id)sender
{
    [self.barcodeController stopReadingBarcodes];

    [self dismissWithLoggedUser:nil];
}

- (void)dismissWithLoggedUser:(TBSocialNetworksUser *)user
{
    if([self.delegate respondsToSelector:@selector(didCloseViewController:userLogged:)]) {
        [self.delegate didCloseViewController:self userLogged:user];
    }
}

@end
