//
//  STASDKLocationHandler.m
//  STACore
//
//  Created by Adam St. John on 2016-03-12.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//


#import "STASDKLocationHandler.h"
#import <CoreLocation/CoreLocation.h>



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

+ (void)currentCountry {
    
}

+ (CLLocation*)currentLocation {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        locationManager = [[CLLocationManager alloc] init];
        return [locationManager location];
    }
    return nil;
}



@end

