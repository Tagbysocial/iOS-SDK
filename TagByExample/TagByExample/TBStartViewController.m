//
//  TBStartViewController.m
//  TagByExample
//
//  Created by Alek on 06.12.2014.
//  Copyright (c) 2014 Alek. All rights reserved.
//

#import "TBStartViewController.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"

static NSString * const kOffersSegue = @"offersSegue";

@interface TBStartViewController ()

@end

@implementation TBStartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadedAppInfoNotification:) name:(NSString *)kTBLoadedAppInfoNotification object:nil];
    
    // Let's wait for the notification informing us that we have received application info from Tag'by Launcher
    [SVProgressHUD showWithStatus:NSLocalizedString(@"CheckingApplication", nil) maskType:SVProgressHUDMaskTypeBlack];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:(NSString *)kTBLoadedAppInfoNotification object:nil];
}

#pragma mark - Notification management
- (void)loadedAppInfoNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:(NSString *)kTBLoadedAppInfoNotification]) {
        NSNumber *success = notification.userInfo[kTBAppInfoKey];
        BOOL ok = [success boolValue];
        
        if(ok) {
            // OK, we can show the offers view controller
            [SVProgressHUD dismiss];
            [self performSegueWithIdentifier:kOffersSegue sender:self];
        }
        else {
            // Error (application not authorized, etc.), just show the error message 
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"ApplicationProblem", nil)];
        }
    }
}

@end
