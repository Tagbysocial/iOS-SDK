//
//  TBPromoOffersViewController.m
//  TagByLauncher
//
//  Created by Alek on 27.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBExampleOffersViewController.h"
#import "TBPreviewImageCollectionViewCell.h"
#import <TagBySDK/TagBySDK.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "SVProgressHUD.h"
#import "TBExampleMainOfferViewController.h"
#import "TBOfferRefresher.h"
#import "TBExampleSettings.h"

static NSString * const kExampleMainOfferSegue = @"exampleMainOfferSegue";

@interface TBExampleOffersViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TBOfferRefresherDelegate>

@property (weak, nonatomic) IBOutlet UILabel *chooseOfferLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *offersCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offersCollectionViewX;
@property (nonatomic, strong) NSArray *documents;
@property (nonatomic, assign) NSUInteger selectedDocumentIndex;

@property (weak, nonatomic) IBOutlet UIImageView *noOffersImageView;
@property (weak, nonatomic) IBOutlet UILabel *noOffersLabel;

@property (nonatomic, assign) BOOL loadOneOfferAutomatically;

@property (nonatomic, strong) TBOfferRefresher *offerRefresher;

@end

@implementation TBExampleOffersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(IS_IPHONE) {
        if(SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            self.offersCollectionViewX.constant += 8.;
        }
    }
    
    // Do any additional setup after loading the view.
    UINib *nib = [UINib nibWithNibName:@"TBPreviewImageCollectionViewCell" bundle: nil];
    [self.offersCollectionView registerNib:nib forCellWithReuseIdentifier:@"tbPreviewCell"];
    self.offersCollectionView.dataSource = self;
    self.offersCollectionView.delegate = self;
    
    self.noOffersImageView.hidden = YES;
    self.noOffersLabel.hidden = YES;
    
    self.loadOneOfferAutomatically = YES;
    
    NSString *appPackage = TBExampleSettings.sharedInstance.appPackage;
    self.offerRefresher = [[TBOfferRefresher alloc] initWithApplicationPackage:appPackage];
    self.offerRefresher.delegate = self;
}

#pragma mark - Lock screen and offer refresh management
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    // Start refreshing the offers
    [self.offerRefresher startRefreshingOffersWithPopup:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Stop refreshing the offers
    [self.offerRefresher stopRefreshingOffers];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [super viewWillDisappear:animated];
}

#pragma mark - Collection view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if(IS_IPHONE) {
        return 1;
    }
    else {
        return 2;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(IS_IPHONE) {
        return self.documents.count;
    }
    else {
        if(self.documents.count % 2 == 0) {
            return self.documents.count / 2;
        }
        else {
            if(section == 0) {
                return self.documents.count / 2 + 1;
            }
            else {
                return self.documents.count / 2;
            }
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TBPreviewImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tbPreviewCell" forIndexPath:indexPath];
    NSUInteger index = [self calculateIndexFromIndexPath:indexPath];
    [cell showImage:((TBDocument *)self.documents[index]).offer.previewUrl backgroundColor:[UIColor colorWithRed:49/255. green:55/255. blue:61/255. alpha:1.]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(IS_IPHONE) {
        return CGSizeMake(232., 414.);
    }
    else {
        return CGSizeMake(320., 240.);
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Moving to show the selected offer
    if([segue.identifier isEqualToString:kExampleMainOfferSegue]) {
        TBExampleMainOfferViewController *mainOfferVC = segue.destinationViewController;
        mainOfferVC.document = self.documents[self.selectedDocumentIndex];
    }
}

#pragma mark - Collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedDocumentIndex = [self calculateIndexFromIndexPath:indexPath];
    [self performSegueWithIdentifier:kExampleMainOfferSegue sender:self];
}

- (NSUInteger)calculateIndexFromIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index;
    
    if(IS_IPHONE) {
        index = indexPath.row;
    }
    else {
        if(self.documents.count % 2 == 0) {
            index = (indexPath.section * self.documents.count / 2) + indexPath.row;
        }
        else {
            index = (indexPath.section * (self.documents.count / 2 + 1)) + indexPath.row;
        }
    }
    
    return index;
}

#pragma mark - Refresh offers
- (void)didGetRefreshOffersError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(error.code == kTBNoNetworkError) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NetworkProblem", nil)];
        }
        else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    });
}

- (void)didRefreshOffers:(NSArray *)documents
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // More than one offer or just one, but not loading it automatically
        if(documents.count > 1 || (documents.count == 1 && !self.loadOneOfferAutomatically)) {
            self.noOffersImageView.hidden = YES;
            self.noOffersLabel.hidden = YES;
            self.chooseOfferLabel.hidden = NO;
            self.offersCollectionView.hidden = NO;
            self.documents = documents;
            [self.offersCollectionView reloadData];
        }
        // If we have just one offer, show it automatically
        else if(documents.count == 1 && self.loadOneOfferAutomatically) {
            self.loadOneOfferAutomatically = NO;
            self.selectedDocumentIndex = 0;
            self.documents = documents;
            [self performSegueWithIdentifier:kExampleMainOfferSegue sender:self];
        }
        // No offers, set the GUI state
        else {
            self.chooseOfferLabel.hidden = YES;
            self.offersCollectionView.hidden = YES;
            self.noOffersImageView.hidden = NO;
            self.noOffersLabel.hidden = NO;
        }
    });
}

#pragma mark - Rotation fixed
- (BOOL)shouldAutorotate
{
    if(IS_IPAD) {
        return YES;
    }
    else {
        return NO;
    }
}

// On iPad we work in landscape orientations, on iPhone in portrait one
- (NSUInteger)supportedInterfaceOrientations
{
    if(IS_IPAD) {
        return UIInterfaceOrientationMaskLandscape;
    }
    else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
