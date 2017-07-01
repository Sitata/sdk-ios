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



#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


@implementation STASDKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // STAGING
    NSString *token = @"TKN UGFydG5lcjo6RXh0ZXJuYWxUcmF2ZWxsZXJ8NTkwMTVkOTBhZGVlOGQ5MDE3ODQzYTNmfHNjYXlpUWJURE1WekFWVFY4dlhi";

    // LOCAL
    //NSString *token = @"TKN UGFydG5lcjo6RXh0ZXJuYWxUcmF2ZWxsZXJ8NTkwMTA4ZDI0NjEyNDAxOTkwODBhOWMzfDJERmJOdVhvaHF4bTE1NHNTTkg5";
    STASDKController *ctrl = [STASDKController sharedInstance];
    [ctrl setConfig:token apiEndpoint:@"https://staging.sitata.com"];



//    [[STASDKController sharedInstance] setDistanceUnitsToImperial];


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
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound |    UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
         {
             if( !error )
             {
                 [[UIApplication sharedApplication] registerForRemoteNotifications];  // required to get the app to do anything at all about push notifications
                 NSLog( @"Push registration success." );
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
    [ctrl receivePushNotification:userInfo];


    if (application.applicationState == UIApplicationStateActive) {
        // app is currently active, can update badges or visuals here

    } else if (application.applicationState == UIApplicationStateBackground) {
        // app is in background, can download additional info here if need be

    } else if (application.applicationState == UIApplicationStateInactive) {
        // app is transitioning from background to foreground (user taps notification)

        // launch the screen for a particular push notification (when applicable)
        [ctrl launchPushNotificationScreen:userInfo];

    }

    completionHandler(UIBackgroundFetchResultNewData);

}


@end
