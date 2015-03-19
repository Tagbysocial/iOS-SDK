//
//  TBAddFriendViewController.m
//  TagByLauncher
//
//  Created by Alek on 25.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBSelectShareNetworkViewController.h"
#import "TBFinalShareViewController_iPhone.h"
#import "TBFinalShareViewController.h"
#import <TagBySDK/TagBySDK.h>
#import "TBExampleSettings.h"
#import "SVProgressHUD.h"

static NSString * const kEventShareAddUserShown = @"select_share_network";
static NSString * const kFinalShareSegue = @"finalShareSegue";

@interface TBSelectShareNetworkViewController () <UIWebViewDelegate, TBFinalShareViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UIButton *scanTagButton;
@property (nonatomic, weak) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *facebookButtonHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twitterButtonTopSpacing;
@property (nonatomic, weak) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twitterButtonHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailButtonTopSpacing;
@property (nonatomic, weak) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailButtonHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonTopSpacing;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeight;

@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, strong) UIColor *endColor;

@property (nonatomic, strong) TBSocialNetworksUser *user;

@end

@implementation TBSelectShareNetworkViewController

- (void)dealloc
{
  self.webView.delegate = nil;
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
    
    if(SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        self.viewX.constant += 8.;
    }
    
    // Do any additional setup after loading the view.
    
    // Create the background backend based on the provided color
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
    self.facebookButton.layer.cornerRadius = 4.;
    self.facebookButton.layer.borderWidth = 2.;
    self.facebookButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.facebookButton.hidden = !self.document.socialNetworks.usesFacebook;
    if(!self.document.socialNetworks.usesFacebook) {
        self.facebookButtonHeight.constant = 0.;
        self.twitterButtonTopSpacing.constant = 0.;
    }
    self.twitterButton.layer.cornerRadius = 4.;
    self.twitterButton.layer.borderWidth = 2.;
    self.twitterButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.twitterButton.hidden = !self.document.socialNetworks.usesTwitter;
    if(!self.document.socialNetworks.usesTwitter) {
        self.twitterButtonHeight.constant = 0.;
        self.emailButtonTopSpacing.constant = 0.;
    }
    self.emailButton.layer.cornerRadius = 4.;
    self.emailButton.layer.borderWidth = 2.;
    self.emailButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.emailButton.hidden = !self.document.socialNetworks.usesEmail;
    if(!self.document.socialNetworks.usesEmail) {
        self.emailButtonHeight.constant = 0.;
        self.cancelButtonTopSpacing.constant = 0.;
    }
    self.cancelButton.layer.cornerRadius = 4.;
    self.cancelButton.layer.borderWidth = 2.;
    self.cancelButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.webView.hidden = YES;
    self.webView.delegate = self;

    // Useful for analytics
    [self postAnalyticsMessage];
}

- (void)postAnalyticsMessage
{
    TBExampleSettings *settings = TBExampleSettings.sharedInstance;
    NSString *guid = settings.appGuid;
    NSString *secret = settings.appSecret;
    NSString *deviceGuid = settings.deviceGuid;
    [TBSocialNetworksManager postAnalyticsEventWithApplicationGuid:guid applicationSecret:secret deviceGuid:deviceGuid offerGuid:self.document.offer.guid event:kEventShareAddUserShown value:nil userId:nil];
}

#pragma mark - Log to social networks
- (IBAction)didClickShareOnFacebook:(id)sender
{
    TBExampleSettings *settings = TBExampleSettings.sharedInstance;
    NSString *deviceGuid = settings.deviceGuid;
    NSURL *url = [TBSocialNetworksManager registrationUrlWithDeviceGuid:deviceGuid offerGuid:self.document.offer.guid socialNetwork:TBSocialNetworkFacebook userTag:nil];
    [self showWebView:url];
}

- (IBAction)didClickShareOnTwitter:(id)sender
{
    TBExampleSettings *settings = TBExampleSettings.sharedInstance;
    NSString *deviceGuid = settings.deviceGuid;
    NSURL *url = [TBSocialNetworksManager registrationUrlWithDeviceGuid:deviceGuid offerGuid:self.document.offer.guid socialNetwork:TBSocialNetworkTwitter userTag:nil];
    [self showWebView:url];
}

- (IBAction)didClickShareOnEmail:(id)sender
{
    TBExampleSettings *settings = TBExampleSettings.sharedInstance;
    NSString *deviceGuid = settings.deviceGuid;
    NSURL *url = [TBSocialNetworksManager registrationUrlWithDeviceGuid:deviceGuid offerGuid:self.document.offer.guid socialNetwork:TBSocialNetworkEmail userTag:nil];
    [self showWebView:url];
}

- (IBAction)didClickCancelButton:(id)sender
{
    if([self.delegate respondsToSelector:@selector(didCloseViewController:userLogged:cancelled:)]) {
        [self.delegate didCloseViewController:self userLogged:nil cancelled:YES];
    }
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

- (void)hideWebView
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
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *scheme = [self.applicationPackage stringByReplacingOccurrencesOfString:@"." withString:@""];
    if([request.URL.scheme hasPrefix:scheme]) {
        [self hideWebView];
        self.user = [self parseWebViewResponse:request.URL];
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if(!strongSelf) {
                return;
            }
            
            /*if(!strongSelf.user) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"LoginError", nil)];
            }
            else {*/
            if(strongSelf.user) {
                if(strongSelf.isAddingFriend || strongSelf.returnOnUserLogin) {
                    [strongSelf dismissWithLoggedUser:strongSelf.user cancelled:NO];
                }
                else {
                    [strongSelf performSegueWithIdentifier:kFinalShareSegue sender:strongSelf];
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
    // Move to the final share screen
    if([segue.identifier isEqualToString:kFinalShareSegue]) {
        TBFinalShareViewController_iPhone *shareVC = segue.destinationViewController;
        shareVC.delegate = self;
        shareVC.applicationPackage = self.applicationPackage;
        shareVC.imageToShare = self.imageToShare;
        shareVC.document = self.document;
        [shareVC setGradientStartColor:self.startColor endColor:self.endColor];
        // Friend that logged in
        shareVC.user = self.user;
        shareVC.message = self.message;
        shareVC.sharingMessage = self.sharingMessage;
        shareVC.sharedMessage = self.sharedMessage;
        // Let's hide ourselves (semi-transparency management)
        self.view.hidden = YES;
        
        // Semi-transparency
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

#pragma mark - Go to main offer view
- (IBAction)didClickCloseButton:(id)sender
{
    [self dismissWithLoggedUser:nil cancelled:NO];
}

#pragma mark - TBFinalShareViewControllerDelegate implementation
- (void)didCloseViewController:(id)viewController
{
    [self dismissWithLoggedUser:nil cancelled:NO];
}

- (void)dismissWithLoggedUser:(TBSocialNetworksUser *)user cancelled:(BOOL)cancelled
{
    if([self.delegate respondsToSelector:@selector(didCloseViewController:userLogged:cancelled:)]) {
        [self.delegate didCloseViewController:self userLogged:user cancelled:cancelled];
    }
}

@end
