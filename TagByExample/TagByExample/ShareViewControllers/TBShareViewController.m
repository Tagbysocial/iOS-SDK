//
//  TBShareViewController.m
//  TagByLauncher
//
//  Created by Alek on 22.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBShareViewController.h"
#import <TagBySDK/TBBarcodePreviewController.h>
#import <TagBySDK/TBBarcodePreview.h>
#import <TagBySDK/TagBySDK.h>
#import "TBExampleSettings.h"
#import "SVProgressHUD.h"
#import "TBFinalShareViewController.h"
#import "UIViewController+TBUtilities.h"

static NSString * const kFinalShareSegue = @"finalShareSegue";
static NSString * const kEventShareNoUserShown = @"share_no_user_shown";

@interface TBShareViewController () <TBBarcodePreviewDelegate, UIWebViewDelegate, TBFinalShareViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) TBBarcodePreviewController *barcodeController;
@property (nonatomic, weak) IBOutlet UIButton *facebookButton;
@property (nonatomic, weak) IBOutlet UIButton *twitterButton;
@property (nonatomic, weak) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, strong) UIColor *endColor;

@property (nonatomic, strong) TBSocialNetworksUser *user;

@end

@implementation TBShareViewController

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
    
    // Do any additional setup after loading the view.
    
    // Background gradient based on provided gradient colors
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
    
    self.messageLabel.text = self.message;
    self.facebookButton.layer.cornerRadius = 4.;
    self.facebookButton.layer.borderWidth = 2.;
    self.facebookButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.facebookButton.hidden = !self.document.socialNetworks.usesFacebook;
    self.twitterButton.layer.cornerRadius = 4.;
    self.twitterButton.layer.borderWidth = 2.;
    self.twitterButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.twitterButton.hidden = !self.document.socialNetworks.usesTwitter;
    self.emailButton.layer.cornerRadius = 4.;
    self.emailButton.layer.borderWidth = 2.;
    self.emailButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.emailButton.hidden = !self.document.socialNetworks.usesEmail;
    self.webView.hidden = YES;
    self.webView.delegate = self;
    
    TBBarcodePreview *tbBarcodePreview = [[TBBarcodePreview alloc] init];
    tbBarcodePreview.frame = CGRectMake(198., 333., 150., 150.);
    tbBarcodePreview.source = TBCameraSourceBackFront;
    self.barcodeController = [[TBBarcodePreviewController alloc] initWithSuperview:self.backgroundView tbBarcodePreview:tbBarcodePreview];
    self.barcodeController.delegate = self;
    self.barcodeController.cameraSide = TBCameraSideFront;
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
    // Changing the camera face for reading user barcodes
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

    // Checking the user on the backend
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
                
                // Network error
                if(error.code == kTBNoNetworkError) {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NetworkProblem", nil)];
                    [strongSelf2.barcodeController startReadingBarcodes];
                }
                // Other error (for instance, no user account associated to this barcode) => let's move to manual login (the user barcode will be associated to the account)
                else {
                    [SVProgressHUD dismiss];
                    NSURL *url = [TBSocialNetworksManager registrationUrlWithDeviceGuid:deviceGuid offerGuid:strongSelf2.document.offer.guid userTag:barcode];
                    [strongSelf2 showWebView:url];
                }
            });
        }
        else {
            // OK, user logged in
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                strongSelf.user = user;
                
                if(!self.returnOnUserLogin) {
                    [strongSelf performSegueWithIdentifier:kFinalShareSegue sender:self];
                }
                else {
                    [strongSelf didClickCloseButton:nil];
                }
            });
        }
    }];
}

#pragma mark - Log to social networks
- (IBAction)didClickShareOnFacebook:(id)sender
{
    [self logToSocialNetwork:TBSocialNetworkFacebook];
}

- (IBAction)didClickShareOnTwitter:(id)sender
{
    [self logToSocialNetwork:TBSocialNetworkTwitter];
}

- (IBAction)didClickShareOnEmail:(id)sender
{
    [self logToSocialNetwork:TBSocialNetworkEmail];
}

// Manual login via web view
- (void)logToSocialNetwork:(TBSocialNetwork)socialNetwork
{
    TBExampleSettings *settings = TBExampleSettings.sharedInstance;
    NSString *deviceGuid = settings.deviceGuid;
    NSURL *url = [TBSocialNetworksManager registrationUrlWithDeviceGuid:deviceGuid offerGuid:self.document.offer.guid socialNetwork:socialNetwork userTag:nil];
    [self showWebView:url];
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
        self.user = [self parseWebViewResponse:request.URL];
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if(!strongSelf) {
                return;
            }

            [strongSelf hideWebView:!strongSelf.user];

            /*if(!strongSelf.user) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"LoginError", nil)];
            }
            else {*/
            if(strongSelf.user) {
                if(!strongSelf.returnOnUserLogin) {
                    [strongSelf performSegueWithIdentifier:kFinalShareSegue sender:strongSelf];
                }
                else {
                    [strongSelf didClickCloseButton:nil];
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
    // Moving to the final share screen
    if([segue.identifier isEqualToString:kFinalShareSegue]) {
        TBFinalShareViewController *shareVC = segue.destinationViewController;
        shareVC.delegate = self;
        shareVC.applicationPackage = self.applicationPackage;
        shareVC.imageToShare = self.imageToShare;
        shareVC.document = self.document;
        [shareVC setGradientStartColor:self.startColor endColor:self.endColor];
        shareVC.message = self.message;
        shareVC.sharingMessage = self.sharingMessage;
        shareVC.sharedMessage = self.sharedMessage;
        shareVC.user = self.user;
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
    [self didClickCloseButton:nil];
}

#pragma mark - Go to take picture view
- (IBAction)didClickCloseButton:(id)sender
{
    [self.barcodeController stopReadingBarcodes];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if([self.delegate respondsToSelector:@selector(didCloseViewController:userLogged:)]) {
            [self.delegate didCloseViewController:self userLogged:self.user];
        }
    }];
}

@end
