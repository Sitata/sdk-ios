//
//  STASDKSync.m
//  STASDK
//
//  Created by Adam St. John on 2016-12-19.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//

#import "STASDKSync.h"
#import "STASDKJobs.h"
#import "STASDKDataController.h"
#import "STASDKApiUtils.h"
#import "STASDKApiTrip.h"
#import "STASDKApiCountry.h"
#import "STASDKApiHealth.h"
#import "STASDKApiAlert.h"
#import "STASDKApiPlaces.h"

#import "STASDKController.h"
#import "STASDKApiMisc.h"

#import "STASDKMCountry.h"
#import "STASDKMHospital.h"
#import "STASDKMDisease.h"
#import "STASDKMMedication.h"
#import "STASDKMVaccination.h"
#import "STASDKMTrip.h"
#import "STASDKMDestination.h"
#import "STASDKMAlert.h"
#import "STASDKMAdvisory.h"

#import <Realm/Realm.h>
#import <EDQueue/EDQueue.h>




@implementation STASDKSync




+ (void)fullSync:(void (^)(NSError*))syncCompleted {

    // Using a dispatch group here to be notified when all tasks have completed.
    // Basically a latch.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

        __block NSError *error;
        dispatch_group_t taskGroup = dispatch_group_create();

        // Sync short list of countries
        dispatch_group_enter(taskGroup);
        [STASDKSync syncCountries:^(NSError *_error) {
            if (_error) {
                error = _error;
            }
            dispatch_group_leave(taskGroup);
        }];

        // Sync list of diseases
        dispatch_group_enter(taskGroup);
        [STASDKSync syncDiseases:^(NSError *_error) {
            if (_error) {
                error = _error;
            }
            dispatch_group_leave(taskGroup);
        }];

        // Sync list of medications
        dispatch_group_enter(taskGroup);
        [STASDKSync syncMedications:^(NSError *_error) {
            if (_error) {
                error = _error;
            }
            dispatch_group_leave(taskGroup);
        }];

        // Sync list of vaccinations
        dispatch_group_enter(taskGroup);
        [STASDKSync syncVaccinations:^(NSError *_error) {
            if (_error) {
                error = _error;
            }
            dispatch_group_leave(taskGroup);
        }];


        // Tasks to perform in full sync
        dispatch_group_enter(taskGroup);
        [STASDKSync syncCurrentTrip:^(NSError *_error) {
            if (_error) {
                error = _error;
            }
            dispatch_group_leave(taskGroup);
        }];

        // wait for group of tasks to finish
        dispatch_group_wait(taskGroup, DISPATCH_TIME_FOREVER);

        // Callback on main thread when finished
        dispatch_async(dispatch_get_main_queue(), ^{
            if (syncCompleted) {
                syncCompleted(error);
            }
        });
    });
}




+ (void)syncCurrentTrip:(void (^)(NSError*))callback {

    [STASDKApiTrip getCurrentTrip:^(STASDKMTrip *trip, NSURLSessionDataTask *task, NSError *error) {

        if (error != nil) {
            NSLog(@"Failed to fetch current trip - error: %@", [error localizedDescription]);
            [self catchCommonHttp:task error:error callback:callback];
            return;
        }

        NSError *writeError;
        [trip resave:&writeError];

        if (writeError != nil) {
            NSLog(@"Failed to save trip - error: %@", [writeError localizedDescription]);
            callback(writeError);
            return;
        } else {
            [self syncExtrasFor:trip];
            NSLog(@"Finshed saving trip.");
            callback(NULL);
        }

    }];

}

+ (void)syncAllTrips:(void (^)(NSError*))callback {

    // do api call here
    [STASDKApiTrip getTrips:^(NSArray *trips, NSURLSessionDataTask *task, NSError *error) {
        if (error != nil) {
            NSLog(@"Failed to fetch trips - error: %@", [error localizedDescription]);
            [self catchCommonHttp:task error:error callback:callback];
            return;
        }

        NSError *writeError;
        // Sync extra associated models and other things for each trip
        for (STASDKMTrip *trip in trips) {
            [trip resave:&writeError];
            if (writeError != nil) {
                // TODO: If there are errors, what happens to related object syncs?
                NSLog(@"Failed to save trips - error: %@", [writeError localizedDescription]);
                callback(writeError);
                return;
            }

            [self syncExtrasFor:trip];
        }

        NSLog(@"Finshed saving trips.");
        callback(NULL);


    }];

}



// TODO: - Unfortunately, the Queue manager does not have a check for existing, identical jobs
//         which means we will have to depend on iOS's caching layer to do its job to prevent
//         unnecessary fetch requests on repeated jobs. e.g. if a specific disease is fetched twice
+ (void) syncExtrasFor:(STASDKMTrip*)trip {

    // for each destination, sync the country
    RLMArray<STASDKMDestination*> *destinations = [trip destinations];

    for (STASDKMDestination* dest in destinations) {
        [[EDQueue sharedInstance] enqueueWithData:@{JOB_PARAM_CID: [dest countryId]} forTask:JOB_SYNC_COUNTRY];

        // TODO: SYNC COUNTRY MAP DURING COUNTRY SYNC JOB
    }

    [[EDQueue sharedInstance] enqueueWithData:@{JOB_PARAM_TRIPID: [trip identifier]} forTask:JOB_SYNC_TRIP_ALERTS];
    [[EDQueue sharedInstance] enqueueWithData:@{JOB_PARAM_TRIPID: [trip identifier]} forTask:JOB_SYNC_TRIP_ADVISORIES];
    [[EDQueue sharedInstance] enqueueWithData:@{JOB_PARAM_TRIPID: [trip identifier]} forTask:JOB_SYNC_TRIP_HOSPITALS];

}


// Sync a short list of countries from the server
+ (void) syncCountries:(void (^)(NSError*))callback {
    [STASDKApiCountry getAllShortForm:^(NSArray<STASDKMCountry *> *countries, NSURLSessionDataTask *task, NSError *error) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        if (error != nil) {
            NSLog(@"Failed to fetch countries short form - error: %@", [error localizedDescription]);
            [self catchCommonHttp:task error:error callback:callback];
            return;
        }

        [realm beginWriteTransaction];
        for (STASDKMCountry *country in countries) {
            [realm addOrUpdateObject:country];
            // TODO: Download country flag????
        }

        NSError *writeError;
        [realm commitWriteTransaction:&writeError];

        if (writeError != nil) {
            NSLog(@"Failed to save countries - error: %@", [writeError localizedDescription]);
            callback(writeError);
        } else {
            NSLog(@"Finshed saving countries.");
            callback(NULL);
        }

    }];
}



// Sync a country from the server based on the given ID
+ (void) syncCountry:(NSString*)countryId callback:(void (^)(NSError*))callback {
    [STASDKApiCountry getById:countryId onFinished:^(STASDKMCountry *country, NSURLSessionDataTask *task, NSError *error) {
        RLMRealm *realm = [RLMRealm defaultRealm];

        if (error != nil) {
            NSLog(@"Failed to fetch country - error: %@", [error localizedDescription]);
            [self catchCommonHttp:task error:error callback:callback];
            return;
        }

        NSError *writeError;
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:country];
        [realm commitWriteTransaction:&writeError];


        if (writeError != nil) {
            NSLog(@"Failed to save country - error: %@", [writeError localizedDescription]);
            callback(writeError);
        } else {
            NSLog(@"Finshed saving country.");
            callback(NULL);
        }

    }];
}



// Sync full list of diseases
+ (void) syncDiseases:(void (^)(NSError*))callback {

    [STASDKApiDisease getAll:^(NSArray<STASDKMDisease*> *diseases, NSURLSessionDataTask *task, NSError *error) {
        RLMRealm *realm = [RLMRealm defaultRealm];

        if (error != nil) {
            NSLog(@"Failed to fetch diseases - error: %@", [error localizedDescription]);
            [self catchCommonHttp:task error:error callback:callback];
            return;
        }

        [realm beginWriteTransaction];
        for (STASDKMDisease *disease in diseases) {
            [realm addOrUpdateObject:disease];
        }

        NSError *writeError;
        [realm commitWriteTransaction:&writeError];

        if (writeError != nil) {
            NSLog(@"Failed to save diseases - error: %@", [writeError localizedDescription]);
            callback(writeError);
        } else {
            NSLog(@"Finshed saving diseases.");
            callback(NULL);
        }
    }];

}


// Sync a disease from the server based on the given ID
+ (void) syncDisease:(NSString*)diseaseId callback:(void (^)(NSError*))callback {

    [STASDKApiDisease getById:diseaseId onFinished:^(STASDKMDisease *disease, NSURLSessionDataTask *task, NSError *error) {

        RLMRealm *realm = [RLMRealm defaultRealm];

        if (error != nil) {
            NSLog(@"Failed to fetch disease - error: %@", [error localizedDescription]);
            [self catchCommonHttp:task error:error callback:callback];
            return;
        }

        NSError *writeError;
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:disease];
        [realm commitWriteTransaction:&writeError];


        if (writeError != nil) {
            NSLog(@"Failed to save disease - error: %@", [writeError localizedDescription]);
            callback(writeError);
        } else {
            NSLog(@"Finshed saving disease.");
            callback(NULL);
        }

    }];
        

}


+ (void) syncMedications:(void (^)(NSError*))callback {

    [STASDKApiMedication getAll:^(NSArray<STASDKMMedication*> *medications, NSURLSessionDataTask *task, NSError *error) {
        RLMRealm *realm = [RLMRealm defaultRealm];

        if (error != nil) {
            NSLog(@"Failed to fetch medications - error: %@", [error localizedDescription]);
            [self catchCommonHttp:task error:error callback:callback];
            return;
        }

        [realm beginWriteTransaction];
        for (STASDKMMedication *medication in medications) {
            [realm addOrUpdateObject:medication];
        }

        NSError *writeError;
        [realm commitWriteTransaction:&writeError];

        if (writeError != nil) {
            NSLog(@"Failed to save medications - error: %@", [writeError localizedDescription]);
            callback(writeError);
        } else {
            NSLog(@"Finshed saving medications.");
            callback(NULL);
        }
    }];
        

}


+ (void) syncVaccinations:(void (^)(NSError*))callback {

    [STASDKApiVaccination getAll:^(NSArray<STASDKMVaccination*> *vaccinations, NSURLSessionDataTask *task, NSError *error) {
        RLMRealm *realm = [RLMRealm defaultRealm];

        if (error != nil) {
            NSLog(@"Failed to fetch vaccinations - error: %@", [error localizedDescription]);
            [self catchCommonHttp:task error:error callback:callback];
            return;
        }


        [realm beginWriteTransaction];
        for (STASDKMVaccination *vaccination in vaccinations) {
            [realm addOrUpdateObject:vaccination];
        }

        NSError *writeError;
        [realm commitWriteTransaction:&writeError];

        if (writeError != nil) {
            NSLog(@"Failed to save vaccinations - error: %@", [writeError localizedDescription]);
            callback(writeError);
        } else {
            NSLog(@"Finshed saving vaccinations.");
            callback(NULL);
        }

    }];

}

+ (void) syncTripAlerts:(NSString*)tripId callback:(void (^)(NSError*))callback {

    [STASDKApiAlert getTripAlerts:tripId onFinished:^(NSArray<STASDKMAlert*> *alerts, NSURLSessionDataTask *task, NSError *error) {
        RLMRealm *realm = [RLMRealm defaultRealm];

        if (error != nil) {
            NSLog(@"Failed to fetch trip alerts - error: %@", [error localizedDescription]);
            [self catchCommonHttp:task error:error callback:callback];
            return;
        }

        // Find the trip for associations
        STASDKMTrip *trip = [STASDKMTrip findBy:tripId];

        if (trip == nil) {
            NSString *msg = @"Failed to fetch trip for associated alerts.";
            NSLog(@"%@", msg);
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(msg, nil)};
            NSError *error = [NSError errorWithDomain:@"SitataCore" code:-99 userInfo:userInfo];
            callback(error);
            return;
        }


        [realm beginWriteTransaction];
        for (STASDKMAlert *alert in alerts) {
            [realm addOrUpdateObject:alert];
            NSUInteger index = [trip.alerts indexOfObject:alert];
            if (index == NSNotFound) {
                [trip.alerts addObject:alert];
            }
        }

        NSError *writeError;
        [realm commitWriteTransaction:&writeError];

        if (writeError != nil) {
            NSLog(@"Failed to save trip alerts - error: %@", [writeError localizedDescription]);
            callback(writeError);
        } else {
            NSLog(@"Finshed saving trip alerts.");
            callback(NULL);
        }

        
    }];
}

+ (void) syncTripAdvisories:(NSString*)tripId callback:(void (^)(NSError*))callback {

    [STASDKApiAlert getTripAdvisories:tripId onFinished:^(NSArray<STASDKMAdvisory*> *advisories, NSURLSessionDataTask *task, NSError *error) {
        RLMRealm *realm = [RLMRealm defaultRealm];

        if (error != nil) {
            NSLog(@"Failed to fetch trip advisories - error: %@", [error localizedDescription]);
            [self catchCommonHttp:task error:error callback:callback];
            return;
        }

        // Find the trip for associations
        STASDKMTrip *trip = [STASDKMTrip findBy:tripId];

        if (trip == nil) {
            NSString *msg = @"Failed to fetch trip for associated advisories.";
            NSLog(@"%@", msg);
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(msg, nil)};
            NSError *error = [NSError errorWithDomain:@"SitataCore" code:-99 userInfo:userInfo];
            callback(error);
            return;
        }


        [realm beginWriteTransaction];
        for (STASDKMAdvisory *advisory in advisories) {
            [realm addOrUpdateObject:advisory];
            NSUInteger index = [trip.advisories indexOfObject:advisory];
            if (index == NSNotFound) {
                [trip.advisories addObject:advisory];
            }
        }


        NSError *writeError;
        [realm commitWriteTransaction:&writeError];

        if (writeError != nil) {
            NSLog(@"Failed to save trip advisories - error: %@", [writeError localizedDescription]);
            callback(writeError);
        } else {
            NSLog(@"Finshed saving trip advisories.");
            callback(NULL);
        }
    }];

}

+ (void) syncTripHospitals:(NSString*)tripId callback:(void (^)(NSError*))callback {


    [STASDKApiPlaces getHospitalsForTrip:tripId onFinished:^(NSArray<STASDKMHospital*> *hospitals, NSURLSessionDataTask *task, NSError *error) {

        RLMRealm *realm = [RLMRealm defaultRealm];

        if (error != nil) {
            NSLog(@"Failed to fetch trip hospitals - error: %@", [error localizedDescription]);
            [self catchCommonHttp:task error:error callback:callback];
            return;
        }

        [realm beginWriteTransaction];
        for (STASDKMHospital *hospital in hospitals) {
            
            [realm addOrUpdateObject:hospital];

            // associate to country
            STASDKMCountry *country = [STASDKMCountry findBy:[hospital countryId]];
            NSUInteger index = [country.hospitals indexOfObject:hospital];
            if (country != NULL && index == NSNotFound) {
                [country.hospitals addObject:hospital];
            }
        }

        NSError *writeError;
        [realm commitWriteTransaction:&writeError];

        if (writeError != nil) {
            NSLog(@"Failed to save trip hospitals - error: %@", [writeError localizedDescription]);
            callback(writeError);
        } else {
            NSLog(@"Finshed saving trip hospitals.");
            callback(NULL);
        }

    }];
}


+ (void) syncAlertMarkRead:(NSString*)alertId callback:(void (^)(NSError*))callback {
    [STASDKApiAlert markRead:alertId onFinished:^(NSURLSessionDataTask *task, NSError *error) {
        if (error != nil) {
            NSLog(@"Failed to mark alert as read - error: %@", [error localizedDescription]);
            [self catchCommonHttp:task error:error callback:callback];
            return;
        }

        NSLog(@"Finshed saving marking alert as read.");
        callback(NULL);
    }];
}




+ (void) syncPushToken:(NSString*)token callback:(void (^)(NSError*))callback {
    // we need to have the push token and the user's JWT, otherwise the request is not
    // worth sending.
    if (token == NULL || [[STASDKController sharedInstance] apiToken] == NULL) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Missing api token or missing push notification token."};
        NSString *domain = @"com.Sitata.SitataCore.ErrorDomain";
        NSError *error = [[NSError alloc] initWithDomain:domain code:-101 userInfo:userInfo];
        callback(error);
    }




    // Gather device information to send to server along with push notification token
    UIDevice *device = [UIDevice currentDevice];
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *language;
    if (languages != NULL && [languages count] > 0) {
        language = [languages objectAtIndex:0];
    }
    NSString *UUID;
    if (device.identifierForVendor != NULL) {
        UUID = device.identifierForVendor.UUIDString;
    }

    NSString *ostype;
#ifdef __LP64__
    ostype = @"64bit";
#else
    ostype = @"32bit";
#endif

    NSDictionary *deviceInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"Apple", @"manufacturer",
                                device.model, @"model",
                                @"ios", @"platform",
                                device.systemName, @"osname",
                                device.systemVersion, @"osversion",
                                language, @"locale",
                                UUID, @"uuid",
                                [NSProcessInfo processInfo].activeProcessorCount, @"processorCount",
                                device.name, @"username",
                                ostype, @"ostype",
                                token, @"token", nil];


    [STASDKApiMisc sendDeviceToken:deviceInfo onFinished:^(NSURLSessionDataTask *task, NSError *error) {
        if (error != nil) {
            NSLog(@"Failed to send device info - error: %@", [error localizedDescription]);
            [self catchCommonHttp:task error:error callback:callback];
            return;
        }

        // nothing else to do here for success case
    }];


}

// This catches common http status codes. Some codes do not necessitate a sync retry. e.g. 404, 401, etc.
+(void)catchCommonHttp:(NSURLSessionDataTask*)task error:(NSError*)error callback:(void (^)(NSError*))callback {
    NSHTTPURLResponse *httpresponse = (NSHTTPURLResponse*) task.response;
    switch ([httpresponse statusCode]) {
        case 404:
        case 401:
            // not found
            // unauthorized
            //
            // firing the callback with null will tell our background jobs
            // layer that things were successful - i.e. don't retry this job.
            callback(NULL);
            break;
        default:
            callback(error);
            break;
    }
}



@end
