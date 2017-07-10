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

@implementation STASDKController

@synthesize distanceUnits = _distanceUnits;
@synthesize apiEndpoint = _apiEndpoint;
@synthesize googleApiKeyPListKey = _googleApiKeyPListKey;
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

        [self setupRealm];

        // default values
        _distanceUnits = Metric;

        _apiEndpoint = @"https://www.sitata.com";

        if (!_googleApiKeyPListKey) {
            _googleApiKeyPListKey = @"GoogleApiKey";
        }

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
    [[EDQueue sharedInstance] setDelegate:self];
    // One downside to EDQueue is that the retry limit is applied to ALL jobs and not
    // one specific job. We need to keep a high retry limit becasue the push notification token
    // job MUST send the token to the server.
    // TODO: adjust this when EDQueue does - probably not anytime soon
    [[EDQueue sharedInstance] setRetryLimit:99];
    [[EDQueue sharedInstance] start];


    // Full sync if we havne't queued already and we have an apiToken. Necessary
    // because this start method could be called multiple times during the app's
    // running lifetime.
    if (!didFirstSync && self.apiToken && [self.apiToken length] > 0) {
        didFirstSync = true;

        // HACK ALERT! => It was necessary to wait a set amount of time to allow the queue manager stuff
        //                from EDQueue to start running. Otherwise, the delegate method was called more
        //                that once. This is a known bug that has been open since 2013.
        //                https://github.com/thisandagain/queue/issues/10
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

            [[EDQueue sharedInstance] enqueueWithData:nil forTask:JOB_FULL_SYNC];

        });


    }
}

- (void)stop {
    [[EDQueue sharedInstance] stop];
}

- (void)setConfig:(NSString*)token {
    self.apiToken = token;
}

- (void)setConfig:(NSString*)token apiEndpoint:(NSString*)apiEndpoint {
    self.apiToken = token;
    self.apiEndpoint = apiEndpoint;
}

- (void)setDistanceUnitsToImperial {
    self.distanceUnits = Imperial;
}

- (void)setPushNotificationToken:(NSString*)token {
    // Create a persistent task to send the push notification token to Sitata
    [[EDQueue sharedInstance] enqueueWithData:@{JOB_PARAM_PTOKEN: token} forTask:JOB_SYNC_PUSH_TOKEN];
}


- (void)receivePushNotification:(NSDictionary *)userInfo {
    [STASDKPushHandler handlePushData:userInfo];
}

- (void)launchPushNotificationScreen:(NSDictionary*)userInfo {
    [STASDKPushHandler launchPushScreen:userInfo];
}



- (UIViewController*)parentRootViewController {
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}


- (void)setupRealm {
    RLMRealm *realm = [RLMRealm defaultRealm];

    // Get our Realm file's parent directory
    NSString *folderPath = realm.configuration.fileURL.URLByDeletingLastPathComponent.path;

    // Disable file protection for this directory - otherwise, we will not be able to access
    // the Realm database in the background on iOS 8 and above 
    [[NSFileManager defaultManager] setAttributes:@{NSFileProtectionKey: NSFileProtectionNone}
                                     ofItemAtPath:folderPath error:nil];
    

}

- (BOOL)destroyAllData {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];

    NSError *error;
    [realm commitWriteTransaction:&error];
    if (error != NULL) {
        return NO;
    } else {
        return YES;
    }
}

- (void)resync {
    [[EDQueue sharedInstance] enqueueWithData:nil forTask:JOB_FULL_SYNC];
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
            if (data == nil) {return;}
            NSString *countryId = [data objectForKey:JOB_PARAM_CID];
            if (countryId == nil) {return;}
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
            if (data == nil) {return;}
            NSString *diseaseId = [data objectForKey:JOB_PARAM_DID];
            if (diseaseId == nil) {return;}
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
            if (data == nil) {return;}
            NSString *tripId = [data objectForKey:JOB_PARAM_TRIPID];
            if (tripId == nil) {return;}
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
            if (data == nil) {return;}
            NSString *tripId = [data objectForKey:JOB_PARAM_TRIPID];
            if (tripId == nil) {return;}
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
            if (data == nil) {return;}
            NSString *tripId = [data objectForKey:JOB_PARAM_TRIPID];
            if (tripId == nil) {return;}
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
            if (data == nil) {return;}
            NSString *alertId = [data objectForKey:JOB_PARAM_AID];
            if (alertId == nil) {return;}
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
            if (data == nil) {return;}
            NSString *token = [data objectForKey:JOB_PARAM_PTOKEN];
            if (token == nil) {return;}
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
            if (data == nil) {return;}
            NSString *alertId = [data objectForKey:JOB_PARAM_AID];
            if (alertId == nil) {return;}
            [STASDKSync syncAlert:alertId callback:^(NSError *err) {
                if (err != nil) {
                    block(EDQueueResultFail);
                } else {
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
