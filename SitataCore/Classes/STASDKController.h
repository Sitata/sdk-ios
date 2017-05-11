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
@property NSString *apiToken;


// allows unit to be set for distance
@property DistanceUnitsType distanceUnits;




/**
 Shared instance singleton

 @return Shared instance
 */
+ (STASDKController*)sharedInstance;





// Performs startup process for the SDK. This must be called from the Application Delegate in 'applicationDidBecomeActive'.
- (void)start;

// Configure the SDK. This must be called from the Application Delegate in 'didFinishLaunchingWithOptions'.
- (void)setConfig:(NSString*)token;

// Perform shutdown actions for the SDK. This must be called from the Application Delegate in 'applicationWillResignActive'.
- (void)stop;

// Sets push notification token for Sitata services.
- (void)setPushNotificationToken:(NSString*)token;


// Change the distance units displayed to Imperial
- (void)setDistanceUnitsToImperial;

// Remove all data from the device.
- (BOOL)destroyAllData;

// Resync all data from server.
- (void)resync;


// Returns the parent app's root view controller
- (UIViewController*)parentRootViewController;

@end
