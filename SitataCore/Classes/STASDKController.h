//
//  STASDKController.h
//  STASDK
//
//  Created by Adam St. John on 2016-10-02.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>





@class NSManagedObjectContext;
@class RLMRealm;
@class CLLocation;


typedef NS_ENUM(int, DistanceUnitsType) {
    Metric = 0,
    Imperial = 1
};


@interface STASDKController : NSObject 


// For traveller to access Sitata API
@property (retain) NSString *apiToken;

// Specify an endpoint to use for the API
@property (retain) NSString *apiEndpoint;

// allows unit to be set for distance
@property (assign) DistanceUnitsType distanceUnits;

// ensures that start and finish dates can not be changed during the trip builder process
// useful if you want full control and set a fixed time period over when sitata's services may be used
// by the end user.
@property (assign) bool fixedTripDates;

// When true, trip builder will skip the screen which allows a user to select the trip type.
@property (assign) bool skipTBTypes;

// When true, trip builder will skip the screen which allows a user to select trip activities.
@property (assign) bool skipTBActivities;




/**
 Shared instance singleton

 @return Shared instance
 */
+ (STASDKController*)sharedInstance;





// Performs startup process for the SDK. This must be called from the Application Delegate in 'applicationDidBecomeActive'.
- (void)start;

// Configure the SDK with the end user's token.
- (void)setConfig:(NSString*)token;

// Configure the SDK with the end user's token and the api endpoint to use.
- (void)setConfig:(NSString*)token apiEndpoint:(NSString*)apiEndpoint;

// Configure the SDK with the end user's token, the api endpoint to use, and the apple push notification token.
- (void)setConfig:(NSString*)token apiEndpoint:(NSString*)apiEndpoint pushNotificationToken:(NSString*)pushNotificationToken;

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

// User's current position if permissions granted
- (CLLocation*)currentLocation;

// Remove all data from the device.
- (BOOL)destroyAllData;

// Sync all data from server.
- (void)sync;

// Convenience method to access the SDK's Realm
- (RLMRealm*)theRealm;



// Returns the parent app's root view controller
- (UIViewController*)parentRootViewController;

@end
