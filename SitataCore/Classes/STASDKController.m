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
#import <EDQueue/EDQueue.h>
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
    
    [[EDQueue sharedInstance] setDelegate:self];
    // One downside to EDQueue is that the retry limit is applied to ALL jobs and not
    // one specific job. We need to keep a high retry limit becasue the push notification token
    // job MUST send the token to the server.
    // TODO: adjust this when EDQueue does - probably not anytime soon
    [[EDQueue sharedInstance] setRetryLimit:99];
    [[EDQueue sharedInstance] start];

    [STASDKMEvent trackEvent:TrackAppStart name:EventAppStart];
}

- (void)stop {
    // stop location handling - i.e. only when app is open and in foreground
    [self.locHandler stop];

    [STASDKMEvent trackEvent:TrackAppDestroyed name:EventAppDestroyed];
    [[EDQueue sharedInstance] stop];
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
    [[EDQueue sharedInstance] enqueueWithData:@{JOB_PARAM_PTOKEN: token} forTask:JOB_SYNC_PUSH_TOKEN];
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
    [[EDQueue sharedInstance] enqueueWithData:nil forTask:JOB_FULL_SYNC];
}

- (RLMRealm*)theRealm {
    return [[STASDKDataController sharedInstance] theRealm];
}



- (void)queue:(EDQueue *)queue processJob:(NSDictionary *)job completion:(void (^)(EDQueueResult))block
{

    @try {

        // SYNC EVERYTHING
        if ([[job objectForKey:@"task"] isEqualToString:JOB_FULL_SYNC]) {

            [STASDKSync fullSync:^(NSError *err) {
                if (err != nil) {
                    block(EDQueueResultFail);
                } else {
                    block(EDQueueResultSuccess);
                }
            }];

        // SYNC COUNTRY
        } else if ([[job objectForKey:@"task"] isEqualToString:JOB_SYNC_COUNTRY]) {


            NSDictionary *data = [job objectForKey:@"data"];
            if (data == nil) {
                block(EDQueueResultCritical);
                return;
            }
            NSString *countryId = [data objectForKey:JOB_PARAM_CID];
            if (countryId == nil) {
                block(EDQueueResultCritical);
                return;
            }
            [STASDKSync syncCountry:countryId callback:^(NSError *err) {
                if (err != nil) {
                    block(EDQueueResultFail);
                } else {
                    block(EDQueueResultSuccess);
                }
            }];


        // SYNC DISEASE
        } else if ([[job objectForKey:@"task"] isEqualToString:JOB_SYNC_DISEASE]) {


            NSDictionary *data = [job objectForKey:@"data"];
            if (data == nil) {
                block(EDQueueResultCritical);
                return;
            }
            NSString *diseaseId = [data objectForKey:JOB_PARAM_DID];
            if (diseaseId == nil) {
                block(EDQueueResultCritical);
                return;
            }
            [STASDKSync syncDisease:diseaseId callback:^(NSError *err) {
                if (err != nil) {
                    block(EDQueueResultFail);
                } else {
                    block(EDQueueResultSuccess);
                }
            }];


        // SYNC TRIP ALERTS
        } else if ([[job objectForKey:@"task"] isEqualToString:JOB_SYNC_TRIP_ALERTS]) {

            NSDictionary *data = [job objectForKey:@"data"];
            if (data == nil) {
                block(EDQueueResultCritical);
                return;
            }
            NSString *tripId = [data objectForKey:JOB_PARAM_TRIPID];
            if (tripId == nil) {
                block(EDQueueResultCritical);
                return;
            }
            [STASDKSync syncTripAlerts:tripId callback:^(NSError *err) {
                if (err != nil) {
                    block(EDQueueResultFail);
                } else {
                    block(EDQueueResultSuccess);
                }
            }];


        // SYNC TRIP ADVISORIES
        } else if ([[job objectForKey:@"task"] isEqualToString:JOB_SYNC_TRIP_ADVISORIES]) {

            NSDictionary *data = [job objectForKey:@"data"];
            if (data == nil) {
                block(EDQueueResultCritical);
                return;
            }
            NSString *tripId = [data objectForKey:JOB_PARAM_TRIPID];
            if (tripId == nil) {
                block(EDQueueResultCritical);
                return;
            }
            [STASDKSync syncTripAdvisories:tripId callback:^(NSError *err) {
                if (err != nil) {
                    block(EDQueueResultFail);
                } else {
                    block(EDQueueResultSuccess);
                }
            }];

        // SYNC TRIP HOSPITALS
        } else if ([[job objectForKey:@"task"] isEqualToString:JOB_SYNC_TRIP_HOSPITALS]) {

            NSDictionary *data = [job objectForKey:@"data"];
            if (data == nil) {
                block(EDQueueResultCritical);
                return;
            }
            NSString *tripId = [data objectForKey:JOB_PARAM_TRIPID];
            if (tripId == nil) {
                block(EDQueueResultCritical);
                return;
            }
            [STASDKSync syncTripHospitals:tripId callback:^(NSError *err) {
                if (err != nil) {
                    block(EDQueueResultFail);
                } else {
                    block(EDQueueResultSuccess);
                }
            }];

        // MARK ALERT AS READ
        } else if ([[job objectForKey:@"task"] isEqualToString:JOB_ALERT_MARK_READ]) {
            NSDictionary *data = [job objectForKey:@"data"];
            if (data == nil) {
                block(EDQueueResultCritical);
                return;
            }
            NSString *alertId = [data objectForKey:JOB_PARAM_AID];
            if (alertId == nil) {
                block(EDQueueResultCritical);
                return;
            }
            [STASDKSync syncAlertMarkRead:alertId callback:^(NSError *err) {
                if (err != nil) {
                    block(EDQueueResultFail);
                } else {
                    block(EDQueueResultSuccess);
                }
            }];

        // SYNC PUSH TOKEN
        } else if ([[job objectForKey:@"task"] isEqualToString:JOB_SYNC_PUSH_TOKEN]) {
            NSDictionary *data = [job objectForKey:@"data"];
            if (data == nil) {
                block(EDQueueResultCritical);
                return;
            }
            NSString *token = [data objectForKey:JOB_PARAM_PTOKEN];
            if (token == nil) {
                block(EDQueueResultCritical);
                return;
            }
            [STASDKSync syncPushToken:token callback:^(NSError *err) {
                if (err != nil) {
                    block(EDQueueResultFail); // retry
                } else {
                    block(EDQueueResultSuccess);
                }
            }];

        // SYNC SINGULAR ALERT (PUSH NOTIFICATION)
        } else if ([[job objectForKey:@"task"] isEqualToString:JOB_SYNC_ALERT]) {
            NSDictionary *data = [job objectForKey:@"data"];
            if (data == nil) {
                block(EDQueueResultCritical);
                return;
            }
            NSString *alertId = [data objectForKey:JOB_PARAM_AID];
            if (alertId == nil) {
                block(EDQueueResultCritical);
                return;
            }
            [STASDKSync syncAlert:alertId callback:^(NSError *err) {
                if (err != nil) {
                    block(EDQueueResultFail);
                } else {
                    block(EDQueueResultSuccess);
                }
            }];

        // TRIP SETTINGS
        } else if ([[job objectForKey:@"task"] isEqualToString:JOB_CHANGE_TRIP_SETTINGS]) {
            NSDictionary *data = [job objectForKey:@"data"];
            if (data == nil) {
                block(EDQueueResultCritical);
                return;
            }
            NSString *tripId = [data objectForKey:JOB_PARAM_TRIPID];
            NSDictionary *settings = [data objectForKey:JOB_PARAM_SETTINGS];
            if (tripId == nil) {
                block(EDQueueResultCritical);
                return;
            }
            [STASDKApiTrip changeTripSettings:tripId settings:settings onFinished:^(NSURLSessionTask *task, NSError *error) {
                if (error != nil) {
                    block(EDQueueResultFail);
                } else {
                    block(EDQueueResultSuccess);
                }
            }];
        } else if ([[job objectForKey:@"task"] isEqualToString:JOB_UPDATE_USER_SETTINGS]) {
            NSDictionary *data = [job objectForKey:@"data"];
            if (data == nil) {
                block(EDQueueResultCritical);
                return;
            }
            NSString *settingsId = [data objectForKey:JOB_PARAM_SETTINGS];
            if (settingsId == nil) {
                block(EDQueueResultCritical);
                return;
            }
            STASDKMUserSettings *settings = [STASDKMUserSettings findBy:settingsId];
            if (settings == nil) {
                block(EDQueueResultCritical);
                return;
            }
            STASDKMTraveller *user = (STASDKMTraveller*) settings.travellers.firstObject;
            if (user == nil) {
                block(EDQueueResultCritical);
                return;
            }
            [STASDKApiTraveller update:user onFinished:^(STASDKMTraveller *user, NSURLSessionDataTask *task, NSError *error) {
                if (error != nil) {
                    block(EDQueueResultFail);
                } else {
                    block(EDQueueResultSuccess);
                }
            }];
        } else if ([[job objectForKey:@"task"] isEqualToString:JOB_SEND_EVENT]) {
            // analytics event
            NSDictionary *data = [job objectForKey:@"data"];
            if (data == nil) {
                block(EDQueueResultCritical);
                return;
            }
            NSString *eventId = [data objectForKey:JOB_PARAM_EID];
            if (eventId == nil) {
                block(EDQueueResultCritical);
                return;
            }
            STASDKMEvent *event = [STASDKMEvent findBy:eventId];
            NSString *identifier = event.identifier;
            [STASDKApiMisc sendEvent:event onFinished:^(NSURLSessionDataTask *task, NSError *error) {
                if (error != nil) {
                    block(EDQueueResultFail);
                } else {
                    // remove event from local database
                    [STASDKMEvent destroy:identifier];
                    block(EDQueueResultSuccess);
                }
            }];

        } else if ([[job objectForKey:@"task"] isEqualToString:@"fail"]) {
            block(EDQueueResultFail);
        } else {
            block(EDQueueResultCritical);
        }
    }
    @catch (NSException *exception) {
        block(EDQueueResultCritical);
    }
}


@end
