//
//  STASDKController.m
//  STASDK
//
//  Created by Adam St. John on 2016-10-02.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//

#import "STASDKController.h"
#import "STASDKDataController.h"
#import "STASDKJobs.h"
#import "STASDKSync.h"
#import <Realm/Realm.h>

#import "STASDKPushHandler.h"
#import "STASDKApiTrip.h"
#import "STASDKMUserSettings.h"
#import "STASDKApiTraveller.h"
#import "STASDKApiMisc.h"
#import "STASDKLocationHandler.h"



#import "STASDKMEvent.h"
#import "STASDKDefines.h"

@import GooglePlaces;


@interface STASDKController()

@property STASDKLocationHandler *locHandler;

@end



@implementation STASDKController

@synthesize distanceUnits = _distanceUnits;
@synthesize apiEndpoint = _apiEndpoint;
@synthesize fixedTripDates = _fixedTripDates;
@synthesize skipTBTypes = _skipTBTypes;
@synthesize skipTBActivities = _skipTBActivities;

BOOL didFirstSync;



#pragma mark Singleton
+ (id)sharedInstance {
    static STASDKController *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    if (self = [super init]) {
//        someProperty = [[NSString alloc] initWithString:@"Default Property Value"];

        [[STASDKDataController sharedInstance] setupRealm];

        // default values
        _distanceUnits = Metric;
        _apiEndpoint = @"https://www.sitata.com";
        _fixedTripDates = NO;
        _skipTBActivities = NO;
        _skipTBTypes = NO;


        // Google Places
        NSString *key = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"GoogleApiKey"];
        if (key.length) {
            [GMSPlacesClient provideAPIKey:key];
        }

        self.locHandler = [[STASDKLocationHandler alloc] init];

        // Setup iOS built in caching
        NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
                                                             diskCapacity:100 * 1024 * 1024
                                                                 diskPath:nil];
        [NSURLCache setSharedURLCache:URLCache];

    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}



#pragma mark Instance Methods




- (void)start {
    // start location handling
    [self.locHandler fetchCurrentLocation];

    // start jobs
    [[STASDKJobs sharedInstance] start];

    [STASDKMEvent trackEvent:TrackAppStart name:EventAppStart];
}

- (void)stop {
    // stop location handling - i.e. only when app is open and in foreground
    [self.locHandler stop];

    [STASDKMEvent trackEvent:TrackAppDestroyed name:EventAppDestroyed];
    [[STASDKJobs sharedInstance] stop];
}

- (void)setConfig:(NSString*)token {
    self.apiToken = token;
}

- (void)setConfig:(NSString*)token apiEndpoint:(NSString*)apiEndpoint {
    self.apiToken = token;
    self.apiEndpoint = apiEndpoint;
}

- (void)setConfig:(NSString*)token apiEndpoint:(NSString*)apiEndpoint pushNotificationToken:(NSString*)pushNotificationToken {

    [self setConfig:token apiEndpoint:apiEndpoint];

    if (pushNotificationToken != NULL && [pushNotificationToken length] > 0) {
        [self setPushNotificationToken:pushNotificationToken];
    }

}

- (void)setDistanceUnitsToImperial {
    self.distanceUnits = Imperial;
}

- (CLLocation*)currentLocation {
    return self.locHandler.currentLocation;
}

- (void)setPushNotificationToken:(NSString*)token {
    // Create a persistent task to send the push notification token to Sitata
    [[STASDKJobs sharedInstance] addJob:JOB_SYNC_PUSH_TOKEN jobArgs:@{JOB_PARAM_PTOKEN: token}];
}


- (void)receivePushNotification:(NSDictionary *)userInfo onFinished:(void (^)(UIBackgroundFetchResult))callback {
    [STASDKPushHandler handlePushData:userInfo onFinished:callback];
}

- (void)launchPushNotificationScreen:(NSDictionary*)userInfo {
    [STASDKPushHandler launchPushScreen:userInfo];
}



- (UIViewController*)parentRootViewController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}


- (BOOL)destroyAllData {
    RLMRealm *realm = [[STASDKDataController sharedInstance] theRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];

    NSError *error;
    [realm commitWriteTransaction:&error];
    return (error != NULL);
}

- (void)sync {
    [[STASDKJobs sharedInstance] addJob:JOB_FULL_SYNC];
}

- (RLMRealm*)theRealm {
    return [[STASDKDataController sharedInstance] theRealm];
}






@end
