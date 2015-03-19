//
//  TBAddFriendViewController.m
//  TagByLauncher
//
//  Created by Alek on 25.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBAddFriendViewController.h"
#import <TagBySDK/TagBySDK.h>
#import "TBExampleSettings.h"
#import "SVProgressHUD.h"

static NSString * const kEventShareAddUserShown = @"share_add_user_shown";

@interface TBAddFriendViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
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

@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, strong) UIColor *endColor;

@property (nonatomic, strong) TBSocialNetworksUser *user;

@end

@implementation TBAddFriendViewController

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
    
    // Do any additional setup after loading the view.
    
    // Background gradient based on provided background colors
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

// Manual login (web view) to a social network
- (void)logToSocialNetwork:(TBSocialNetwork)socialNetwork
{
    TBExampleSettings *settings = TBExampleSettings.sharedInstance;
    NSString *deviceGuid = settings.deviceGuid;
    NSURL *url = [TBSocialNetworksManager registrationUrlWithDeviceGuid:deviceGuid offerGuid:self.document.offer.guid socialNetwork:socialNetwork userTag:nil];
    [self showWebView:url];
}

- (IBAction)didClickCancelButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    
    if([self.delegate respondsToSelector:@selector(didCancelLoggingSocialUser:)]) {
        [self.delegate didCancelLoggingSocialUser:self];
    }
}

#pragma mark - UIWebView management
- (void)showWebView:(NSURL *)url
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    self.webView.hidden = NO;
    self.facebookButton.hidden = YES;
    self.twitterButton.hidden = YES;
    self.emailButton.hidden = YES;
    self.cancelButton.hidden = YES;
}

- (void)hideWebView
{
    self.webView.hidden = YES;
    if(self.document.socialNetworks.usesFacebook) {
        self.facebookButton.hidden = NO;
    }
    if(self.document.socialNetworks.usesTwitter) {
        self.twitterButton.hidden = NO;
    }
    if(self.document.socialNetworks.usesEmail) {
        self.emailButton.hidden = NO;
    }
    self.cancelButton.hidden = NO;
    
    [self.webView stopLoading];
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
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

            [strongSelf hideWebView];

            /*if(!user) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"LoginError", nil)];
            }
            else {*/
            if(user) {
                if([strongSelf.delegate respondsToSelector:@selector(didLogSocialUser:)]) {
                    [strongSelf dismissViewControllerAnimated:YES completion:^{
                    }];
                    [strongSelf.delegate didLogSocialUser:user];
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

#pragma mark - Hide status bar
- (BOOL)prefersStatusBarHidden
{
    return YES;
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
