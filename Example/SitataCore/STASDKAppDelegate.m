//
//  STASDKAppDelegate.m
//  SitataCore
//
//  Created by Adam St. John on 12/20/2016.
//  Copyright (c) 2016 Adam St. John. All rights reserved.
//

#import "STASDKAppDelegate.h"
#import <SitataCore/STASDKController.h>

#import <SitataCore/STASDKGeo.h>
#import <SitataCore/STASDKUIStylesheet.h>



#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


@implementation STASDKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    // LOCAL
//    NSString *token = @"TKN UGFydG5lcjo6RXh0ZXJuYWxUcmF2ZWxsZXJ8NTkxOTAzNDNiODdkOTEyYzg3NTBlNTQ2fHRDeS00WXNfLW94ZFZ5S3VNNjE4";
    NSString *token = @"TKN UGFydG5lcjo6RXh0ZXJuYWxUcmF2ZWxsZXJ8NTlmOGFkODZjNDI2ZDkxMDhmNmJkYmQ0fG5ETS1TU3lad254eVN3cW5iMlBq";
    STASDKController *ctrl = [STASDKController sharedInstance];
    [ctrl setConfig:token apiEndpoint:@"https://staging.sitata.com"];
    ctrl.fixedTripDates = YES;
    ctrl.skipTBTypes = NO;
    ctrl.skipTBActivities = NO;

    // for testing purposes
    [ctrl destroyAllData];

    [ctrl sync];


    [self testStyles];
    [self testUnits];



    // app launched from a notification
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [self application:application didReceiveRemoteNotification:launchOptions fetchCompletionHandler:^(UIBackgroundFetchResult result) {
            // do nothing after handled
        }];
    }


    application.applicationIconBadgeNumber = 0;
    // Register for push notifications - ideally, you would want to do this after explaining to the
    // user why you're requesting them.
    if( SYSTEM_VERSION_LESS_THAN( @"10.0" ) ){
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
         {
             if( !error )
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[UIApplication sharedApplication] registerForRemoteNotifications];  // required to get the app to do anything at all about push notifications
                     NSLog( @"Push registration success." );
                 });
             }
             else
             {
                 NSLog( @"Push registration FAILED" );
                 NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
                 NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );  
             }  
         }];  
    }



    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[STASDKController sharedInstance] stop];
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
    [[STASDKController sharedInstance] start];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



#pragma mark - PUSH NOTIFICATIONS

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    // Extract token from data object
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Registered for remote notifications: %@", token);

    // Pass token to Sitata SDK Controller
    STASDKController *ctrl = [STASDKController sharedInstance];
    [ctrl setPushNotificationToken:token];
}

- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to register for remote notifications.");
}


// Called when push notification is received in foreground or background
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{



    // In all three states, pass notification to Sitata to download additional data.
    STASDKController *ctrl = [STASDKController sharedInstance];
    [ctrl receivePushNotification:userInfo onFinished:^(UIBackgroundFetchResult result) {
        completionHandler(result);
    }];


    if (application.applicationState == UIApplicationStateActive) {
        // app is currently active, can update badges or visuals here

    } else if (application.applicationState == UIApplicationStateBackground) {
        // app is in background

    } else if (application.applicationState == UIApplicationStateInactive) {
        // app is transitioning from background to foreground (user taps notification)

        // launch the screen for a particular push notification (when applicable)
        [ctrl launchPushNotificationScreen:userInfo];

    }



}




#pragma mark - SDK Functionality Tests
- (void) testStyles {
    // style tests
    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    styles.navigationBarFont = [UIFont systemFontOfSize:14 weight:5];
    styles.headingFont = [UIFont systemFontOfSize:28 weight:700];
    styles.subHeadingFont = [UIFont systemFontOfSize:26 weight:700];
    styles.bodyFont = [UIFont systemFontOfSize:14 weight:100];
    styles.rowTextFont = [UIFont systemFontOfSize:16 weight:10];
    styles.titleFont = [UIFont italicSystemFontOfSize:14];
    styles.rowSecondaryTextFont = [UIFont italicSystemFontOfSize:12];
    styles.buttonFont = [UIFont italicSystemFontOfSize:14];

    styles.alertsRowNormalFont = [UIFont systemFontOfSize:12];
    styles.alertsRowUnreadFont = [UIFont italicSystemFontOfSize:12];

    styles.headingTextColor = [UIColor blueColor];
    styles.subheadingTextColor = [UIColor yellowColor];
    styles.titleTextColor = [UIColor redColor];
    styles.bodyTextColor = [UIColor purpleColor];
    styles.tripTimelineColor = [UIColor greenColor];


    styles.hospitalAccredationLblColor = [UIColor greenColor];
    styles.hospitalEmergencyLblColor = [UIColor blueColor];
    styles.hospitalEmergencyLblFont = [UIFont italicSystemFontOfSize:15];
    styles.hospitalAccredationLblFont = [UIFont italicSystemFontOfSize:10];


}

- (void) testUnits {
//    [[STASDKController sharedInstance] setDistanceUnitsToImperial];
}


@end
