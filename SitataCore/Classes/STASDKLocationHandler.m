//
//  STASDKLocationHandler.m
//  STACore
//
//  Created by Adam St. John on 2016-03-12.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//


#import "STASDKLocationHandler.h"
#import <CoreLocation/CoreLocation.h>


@interface STASDKLocationHandler() <CLLocationManagerDelegate>

@property CLLocationManager *locManager;
@property bool deferringUpdates;

@end


@implementation STASDKLocationHandler

// locationManager HAS to be a class/static level variable. Otherwise,
// the manager will be released at the end of the method, resulting in
// the request dialog box disappearing almost immediately.
static CLLocationManager *locationManager;


+ (void)requestPermissionsWhenNecessary {
    locationManager = [[CLLocationManager alloc] init];

    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

    // restricted == user has location services turned off, don't request for this sdk
    // denied == user tapped 'no' to request previously, don't re-request for this sdk
    // authorized == user tapped 'yes' on iOS 7 and lower
    // authorizedAlways == user authorized background use
    // authorizedWhenInUse == user authorized when app is in foreground (what this sdk currently asks for)
    // notDetermined == user hasn't been asked yet
    if (status == kCLAuthorizationStatusNotDetermined) {

        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        }
    }
}

-(void)fetchCurrentLocation {
    // only fetch location when granted by user
    if (![STASDKLocationHandler grantedPermissions]) {
        return;
    }
    [self setup];
    [self.locManager requestLocation];
}


-(void)start {
    // only fetch location when granted by user
    if (![STASDKLocationHandler grantedPermissions]) {
        return;
    }
    self.deferringUpdates = NO;
    [self setup];
    [self.locManager startUpdatingLocation];
}

-(void)setup {
    if (self.locManager == NULL) {
        self.locManager = [[CLLocationManager alloc] init];
        self.locManager.delegate = self;
        self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locManager.distanceFilter = 100; // meters
        self.locManager.pausesLocationUpdatesAutomatically = YES;
        self.locManager.activityType = CLActivityTypeFitness;
    }
}

-(void)stop {
    [self.locManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {

    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];

    // throws away any events that are more than fifteen seconds old under
    // the assumption that events up to that age are likely to be good enough.
    if (fabs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        self.currentLocation = location;
    }

    // Defer updates until the user moves a certain distance
    // or when a certain amount of time has passed.
    if (!self.deferringUpdates) {
        CLLocationDistance distance = 100.0; // meters
        NSTimeInterval time = 300.0; // seconds
        [self.locManager allowDeferredLocationUpdatesUntilTraveled:distance
                                                           timeout:time];
        self.deferringUpdates = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
    self.deferringUpdates = NO;
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    self.deferringUpdates = NO;
}







+(bool)grantedPermissions {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    return [CLLocationManager locationServicesEnabled] &&
    (status == kCLAuthorizationStatusAuthorizedAlways ||
     status == kCLAuthorizationStatusAuthorizedWhenInUse);
}



@end

