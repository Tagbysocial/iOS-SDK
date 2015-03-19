//
//  TBPromoMainOfferViewController.m
//  TagByLauncher
//
//  Created by Alek on 27.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBExampleMainOfferViewController.h"
#import <TagBySDK/TagBySDK.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "TBShareViewController.h"
#import "TBShareWithSocialTagViewController.h"
#import "TBOfferRefresher.h"
#import "TBExampleSettings.h"

// Graphic elements names, they will need to be checked on the backend
static NSString * const kInfoLabelSlug = @"info-label";
static NSString * const kImageSlug = @"custom-image";
static NSString * const kLogoSlug = @"logo-image";
static NSString * const kShareButtonSlug = @"share-button";
static NSString * const kExampleShareSegue = @"exampleShareSegue";

@interface TBExampleMainOfferViewController () <TBShareViewControllerDelegate, TBShareWithSocialTagViewControllerDelegate, TBButtonControllerDelegate, TBOfferRefresherDelegate>

@property (weak, nonatomic) IBOutlet UIButton *shareNowButton;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, assign) TBDeviceOrientation orientation;
@property (nonatomic, assign) BOOL blockScreenLocking;

// Widget controllers corresponding to elements from the document/template
@property (nonatomic, strong) TBLabelController *infoLabelController;
@property (nonatomic, strong) TBImageController *logoImageController;
@property (nonatomic, strong) TBImageController *customImageController;
@property (nonatomic, strong) TBButtonController *shareButtonController;

// Final image that will be shared
@property (nonatomic, strong) UIImage *imageToShare;

// We refresh the offers whenever the application is idle
@property (nonatomic, strong) TBOfferRefresher *offerRefresher;

@end

@implementation TBExampleMainOfferViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *promoPackage = TBExampleSettings.sharedInstance.appPackage;
    self.offerRefresher = [[TBOfferRefresher alloc] initWithApplicationPackage:promoPackage];
    self.offerRefresher.delegate = self;
    
    // Do any additional setup after loading the view.
    
    // We set the screen orientation and block the lock screen according to the selected offer document settings
    self.orientation = self.document.settings.orientation;
    self.blockScreenLocking = self.document.settings.blockScreenLocking;
    
    // Loading the background image (either a remote image or basend on the background color from the document)
    if(self.document.background.imageUrl) {
        __weak __typeof(self) weakSelf = self;
        [self.backgroundImageView sd_setImageWithURL:self.document.background.imageUrl placeholderImage:nil options:SDWebImageRefreshCached progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if(!strongSelf) {
                return;
            }
            
            strongSelf.backgroundImage = image;
        }];
    }
    else {
        CGSize imageSize = self.backgroundImageView.frame.size;
        UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.document.background.color setFill];
        CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
        self.backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.backgroundImageView.image = self.backgroundImage;
    }
    
    // Let's create the share button, but hide it
    self.shareNowButton.hidden = YES;
    self.shareNowButton.layer.borderWidth = 3.;
    self.shareNowButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.shareNowButton.backgroundColor = [UIColor colorWithRed:1. green:1. blue:1. alpha:.05];

    // Widgets are laid out in the Z order (the ones on the bottom first)

    // Info label
    for(TBWidget *widget in self.document.widgets) {
        if(widget.type == TBWidgetTypeLabel && [widget.name isEqualToString:kInfoLabelSlug]) {
            self.infoLabelController = [[TBLabelController alloc] initWithSuperview:self.view tbLabel:(TBLabel *)widget];
        }
    }
    
    // Logo image
    for(TBWidget *widget in self.document.widgets) {
        if(widget.type == TBWidgetTypeLogoImage && [widget.name isEqualToString:kLogoSlug]) {
            self.logoImageController = [[TBImageController alloc] initWithSuperview:self.view tbImage:(TBImage *)widget];
        }
    }

    // Custom image
    for(TBWidget *widget in self.document.widgets) {
        if(widget.type == TBWidgetTypeImage && [widget.name isEqualToString:kImageSlug]) {
            self.customImageController = [[TBImageController alloc] initWithSuperview:self.view tbImage:(TBImage *)widget];
        }
    }

    // Share button
    for(TBWidget *widget in self.document.widgets) {
        if(widget.type == TBWidgetTypeButton && [widget.name isEqualToString:kShareButtonSlug]) {
            self.shareButtonController = [[TBButtonController alloc] initWithSuperview:self.view tbButton:(TBButton *)widget];
            self.shareButtonController.delegate = self;
        }
    }

    // Put the buttons (share now, back) on top
    NSMutableArray *buttonViewConstraints = [NSMutableArray array];
    for(NSLayoutConstraint *constraint in self.view.constraints) {
        if(constraint.firstItem == self.backButton || constraint.secondItem == self.backButton) {
            [buttonViewConstraints addObject:constraint];
        }
    }
    [self.backButton removeFromSuperview];
    [self.view addSubview:self.backButton];
    [self.view addConstraints:buttonViewConstraints];
    
    buttonViewConstraints = [NSMutableArray array];
    for(NSLayoutConstraint *constraint in self.view.constraints) {
        if(constraint.firstItem == self.shareNowButton || constraint.secondItem == self.shareNowButton) {
            [buttonViewConstraints addObject:constraint];
        }
    }
    [self.shareNowButton removeFromSuperview];
    [self.view addSubview:self.shareNowButton];
    [self.view addConstraints:buttonViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.blockScreenLocking) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
    
    [self.offerRefresher startRefreshingOffersWithPopup:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.offerRefresher stopRefreshingOffers];

    if(self.blockScreenLocking) {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
    
    [super viewWillDisappear:animated];
}

- (void)didClickTBButton:(TBButtonController *)buttonController
{
    // When the share button is pressed, let's prepare the image to share and move to the share screens
    if(buttonController == self.shareButtonController) {
        [self createImageToShare];
        [self setControlsForSharingImage];
        [self performSegueWithIdentifier:kExampleShareSegue sender:self];
    }
}

#pragma mark - Controls state management
- (void)setControlsForSharingImage
{
    self.backgroundImageView.image = self.imageToShare;
    self.infoLabelController.hidden = NO;
    self.logoImageController.hidden = NO;
    self.shareButtonController.hidden = YES;
}

- (void)setControlsToInitialState
{
    self.backgroundImageView.image = self.backgroundImage;
    self.infoLabelController.hidden = NO;
    self.logoImageController.hidden = NO;
    self.shareButtonController.hidden = NO;
}

- (void)createImageToShare
{
    if(self.imageToShare) {
        return;
    }
    
    // Let's create the image to share by merging the elements (anything can be nil/not present) except for the backgroung image that will always be present
    UIImage *firstImage = [self.backgroundImageView.image mergeInRect:self.view.bounds withImage:[self.infoLabelController.label image] imageRect:self.infoLabelController.frame];
    UIImage *secondImage = [firstImage mergeInRect:self.view.bounds withImage:self.logoImageController.image imageRect:self.logoImageController.frame];
    self.imageToShare = [secondImage mergeInRect:self.view.bounds withImage:self.customImageController.image imageRect:self.customImageController.frame];
}

#pragma mark - Share view delegate
- (void)didCloseViewController:(id)viewController userLogged:(TBSocialNetworksUser *)user
{
    if(IS_IPHONE) {
        [viewController dismissViewControllerAnimated:YES completion:^{
        }];
    }

    [self setControlsToInitialState];
    [self.offerRefresher startRefreshingOffersWithPopup:NO];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Moving to the share screens
    if([segue.identifier isEqualToString:kExampleShareSegue]) {
        [self.offerRefresher stopRefreshingOffers];

        UIViewController *destinationVC = segue.destinationViewController;

        if(IS_IPAD) {
            TBShareViewController *shareVC = (TBShareViewController *)destinationVC;
            shareVC.delegate = self;
            // We need to pass the application package to the share screen
            shareVC.applicationPackage = TBExampleSettings.sharedInstance.appPackage;
            // The current offer document
            shareVC.document = self.document;
            // Select your own color
            [shareVC setGradientStartColor:[UIColor colorWithRed:250./255 green:217./255 blue:97./255 alpha:.95] endColor:[UIColor colorWithRed:247./255 green:107./255 blue:28./255 alpha:.89]];
            // Prepare your own share message
            shareVC.message = NSLocalizedString(@"ShareExample", nil);
            // Image to share
            shareVC.imageToShare = self.imageToShare;
            // Message used when posting the message
            shareVC.sharingMessage = self.document.settings.sharingMessage;
            // Message used when posted the message
            shareVC.sharedMessage = self.document.settings.sharedMessage;
        }
        else {
            TBShareWithSocialTagViewController *shareVC = (TBShareWithSocialTagViewController *)destinationVC;
            shareVC.delegate = self;
            // We need to pass the application package to the share screen
            shareVC.applicationPackage = TBExampleSettings.sharedInstance.appPackage;
            // The current offer document
            shareVC.document = self.document;
            // Select your own color
            [shareVC setGradientStartColor:[UIColor colorWithRed:250./255 green:217./255 blue:97./255 alpha:.95] endColor:[UIColor colorWithRed:247./255 green:107./255 blue:28./255 alpha:.89]];
            // Prepare your own share message
            shareVC.message = NSLocalizedString(@"ShareExample", nil);
            // Image to share
            shareVC.imageToShare = self.imageToShare;
            // Message used when posting the message
            shareVC.sharingMessage = self.document.settings.sharingMessage;
            // Message used when posted the message
            shareVC.sharedMessage = self.document.settings.sharedMessage;
        }
        
        // Sem-transparency management
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            self.providesPresentationContextTransitionStyle = YES;
            self.definesPresentationContext = YES;
            destinationVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        else {
            self.modalPresentationStyle = UIModalPresentationCurrentContext;
        }
    }
}

#pragma mark - Refresh offers
- (void)didRefreshOffers:(NSArray *)documents
{
    BOOL goBack = YES;
    for(TBDocument *document in documents) {
        if([document.offer.guid isEqualToString:self.document.offer.guid]) {
            goBack = NO;
            break;
        }
    }
    
    if(goBack) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didClickBack:self.backButton];
        });
    }
}

#pragma mark - Hide status bar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Go to offers view
- (IBAction)didClickBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - Rotation management
- (BOOL)shouldAutorotate
{
    return (self.orientation != TBDeviceOrientationUnknown);
}

- (NSUInteger)supportedInterfaceOrientations
{
    if(self.orientation == TBDeviceOrientationUnknown) {
        if(IS_IPAD) {
            return UIInterfaceOrientationMaskLandscape;
        }
        else {
            return UIInterfaceOrientationMaskPortrait;
        }
    }
    
    if(self.orientation == TBDeviceOrientationPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    return UIInterfaceOrientationMaskLandscape;
}

@end
