//
//  STASDKController.h
//  STASDK
//
//  Created by Adam St. John on 2016-10-02.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <EDQueue/EDQueue.h>



@class NSManagedObjectContext;



typedef NS_ENUM(int, DistanceUnitsType) {
    Metric = 0,
    Imperial = 1
};


@interface STASDKController : NSObject <EDQueueDelegate>


// For traveller to access Sitata API
@property (retain) NSString *apiToken;

// Specify an endpoint to use for the API
@property (retain) NSString *apiEndpoint;

// The key name stored in your Info.plist that references the Google API Key value
@property (retain) NSString *googleApiKeyPListKey;

// allows unit to be set for distance
@property (assign) DistanceUnitsType distanceUnits;




/**
 Shared instance singleton

 @return Shared instance
 */
+ (STASDKController*)sharedInstance;





// Performs startup process for the SDK. This must be called from the Application Delegate in 'applicationDidBecomeActive'.
- (void)start;

// Configure the SDK with the end user's token. This must be called from the Application Delegate in 'didFinishLaunchingWithOptions'.
- (void)setConfig:(NSString*)token;

// Configure the SDK with the end user's token and the api endpoint to use. This must be called from the Application Delegate in 'didFinishLaunchingWithOptions'.
- (void)setConfig:(NSString*)token apiEndpoint:(NSString*)apiEndpoint;

// Perform shutdown actions for the SDK. This must be called from the Application Delegate in 'applicationWillResignActive'.
- (void)stop;

// Sets push notification token for Sitata services.
- (void)setPushNotificationToken:(NSString*)token;

// Receive push notifications from client and react accordingly.
- (void)receivePushNotification:(NSDictionary *)userInfo onFinished:(void (^)(UIBackgroundFetchResult))callback;

// Launches the correct user interface screen for the incoming push notification.
- (void)launchPushNotificationScreen:(NSDictionary*)userInfo;


// Change the distance units displayed to Imperial
- (void)setDistanceUnitsToImperial;

// Remove all data from the device.
- (BOOL)destroyAllData;

// Resync all data from server.
- (void)resync;


// Returns the parent app's root view controller
- (UIViewController*)parentRootViewController;

@end
