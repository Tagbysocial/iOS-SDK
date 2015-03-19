//
//  AppDelegate.m
//  TagByExample
//
//  Created by Alek on 05.11.2014.
//  Copyright (c) 2014 Alek. All rights reserved.
//

#import "AppDelegate.h"
#import "TBExampleSettings.h"
#import <TagBySDK/TagBySDK.h>
#import <TagBySDK/AFNetworkActivityLogger.h>
#import "UINavigationController+OrientationFix.h"
#import "UIViewController+TBUtilities.h"

// Notification sent when we get the application information
const NSString *kTBLoadedAppInfoNotification = @"TBLoadedAppInfoNotification";
const NSString *kTBAppInfoKey = @"TBAppInfoKey";


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    // The URL format for getting application information from TagBy Launcher is the following: "tagby://ApplicationURLScheme/getappinfo"
    // The application scheme must be the same as set in the plist file as TagBy Launcher will use it to go back to the application
    NSURL *appUrl = [NSURL URLWithString:@"tagby://tagbyexample/getappinfo"];
    [[UIApplication sharedApplication] openURL:appUrl];
    
    return YES;
}

#pragma mark - Handling response from TagBy Launcher
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *urlToParse = [NSString stringWithFormat:@"%@%@", url.host, url.path];
    NSArray *urlComponents = [urlToParse componentsSeparatedByString:@"/"];

    BOOL success = NO;
    // Not found: urlComponents array count == 1
    // Found: urlComponents array count == 3 (device guid, application guid, application secret)
    if(urlComponents.count == 3) {
        TBExampleSettings.sharedInstance.appPackage = [[NSBundle mainBundle] bundleIdentifier];
        TBExampleSettings.sharedInstance.deviceGuid = urlComponents[0];
        TBExampleSettings.sharedInstance.appGuid = urlComponents[1];
        TBExampleSettings.sharedInstance.appSecret = urlComponents[2];
        
        success = YES;
    }
    
    // Sent notification to unblock the initial view controller
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:(NSString *)kTBLoadedAppInfoNotification object:nil userInfo:@{ kTBAppInfoKey : [NSNumber numberWithBool:success]}];

    return YES;
}

// This is important for iPad/iPhone orientation support
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
