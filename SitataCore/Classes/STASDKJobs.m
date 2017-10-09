//
//  STASDKJobs.m
//  Pods
//
//  Created by Adam St. John on 2016-12-21.
//
//

#import <Foundation/Foundation.h>
#import "STASDKJobs.h"
#import "STASDKMJob.h"
#import "STASDKDataController.h"
#import "STASDKDefines.h"

#import "STASDKSync.h"
#import "STASDKMUserSettings.h"
#import "STASDKMEvent.h"
#import "STASDKMTraveller.h"
#import "STASDKApiTraveller.h"
#import "STASDKApiTrip.h"
#import "STASDKApiMisc.h"


@implementation STASDKJobs



#pragma mark Singleton
+ (id)sharedInstance {
    static STASDKJobs *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}


- (id)init
{
    self = [super init];
    if (!self) return nil;
    _runCount = 0;
    return self;
}

-(void)start {
    self.stopped = NO;
    [self processStaleJobs];
    [self processJobs];
}

-(void)stop {
    self.stopped = YES;
}


-(void)processStaleJobs {
    // first destroy any dead jobs
    RLMResults<STASDKMJob*> *jobs = [STASDKMJob findDead];
    for(STASDKMJob *job in jobs) {
        [self removeJob:job];
    }

    // now process stale jobs
    [self runWorker: 2];
}


-(void)processJobs {
    // spawn up 3 workers
    for (int i = 0; i < 3; i++) {
        if (!self.stopped) {
            self.runCount++;
            [self runWorker: 0]; // unprocessed jobs
        }
    }
}

- (void)runWorker:(int)jobStatus {
    __weak STASDKJobs *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self runOnce:jobStatus onComplete:^(STASDKMJob *job) {
            if(job && !weakSelf.stopped) {
                [self runWorker:jobStatus]; // worker should continue to process another job
            } else {
                // else no more jobs
                weakSelf.runCount--;
            }
        }];
    });
}

-(void)runOnce:(int)jobStatus onComplete:(void (^)(STASDKMJob*))onComplete {
    // query database for an unprocessed job and set as processing
    STASDKMJob *job = [STASDKMJob captureFirstJob:jobStatus];

    // run the job
    if (job) {
        [self runJob:job completion:^(NSString *jobIdentifier, bool success) {
            STASDKMJob *job = [STASDKMJob findBy:jobIdentifier];
            if (jobIdentifier) {
                // if success, remove from database
                [self removeJob:job];
            } else {
                // if error, increment retry count, save
                [self setFailed:job];
            }
            onComplete(job);
        }];
    } else {
        onComplete(NULL);
    }
}

-(void)addJob:(NSString *)jobName {
    [self addJob:jobName jobArgs:NULL];
}
-(void)addJob:(NSString*)jobName jobArgs:(NSDictionary *)jobArgs {
    [self addJob:jobName jobArgs:jobArgs maxRetries:-1];
}
-(void)addJob:(NSString*)jobName jobArgs:(NSDictionary*)jobArgs maxRetries:(int)maxRetries {
    STASDKMJob *job = [[STASDKMJob alloc] init];
    job.jobName = jobName;
    if (jobArgs) {
        [job addJobArgs:jobArgs];
    }
    if (maxRetries != -1) {
        job.maxRetries = maxRetries;
    }

    // don't add duplicate jobs
    bool jobExists = [STASDKMJob checkExists:job];
    if (!jobExists) {
        RLMRealm *realm = [[STASDKDataController sharedInstance] theRealm];
        [realm transactionWithBlock:^{
            [realm addObject:job];
        }];
    }

    if (self.runCount > 0) {
        [self runWorker:0]; // run a worker to process (unprocessed) jobs
    } else {
        [self processJobs]; // spin up a batch of workers
    }
}


- (void)setFailed:(STASDKMJob*)job {
    [STASDKMJob incRetries:job.identifier];
}

- (void)removeJob:(STASDKMJob*)job {
    [STASDKMJob destroy:job.identifier];
}




- (void)runJob:(STASDKMJob*)job completion:(void (^)(NSString*, bool))block {
    NSDictionary *data = [job fetchJobArgs];
    NSString *jobId = job.identifier;

    @try {
        // SYNC EVERYTHING
        if ([job.jobName isEqualToString:JOB_FULL_SYNC]) {
            [STASDKSync fullSync:^(NSError *err) {
                if (err != nil) {
                    block(jobId, false);
                } else {
                    block(jobId, true);
                }
            }];

        // SYNC COUNTRY
        } else if ([job.jobName isEqualToString:JOB_SYNC_COUNTRY]) {
            if (data == nil) {
                block(jobId, false);
                return;
            }
            NSString *countryId = [data objectForKey:JOB_PARAM_CID];
            if (countryId == nil) {
                block(jobId, false);
                return;
            }
            [STASDKSync syncCountry:countryId callback:^(NSError *err) {
                if (err != nil) {
                    block(jobId, false);
                } else {
                    block(jobId, true);
                }
            }];

        // SYNC DISEASE
        } else if ([job.jobName isEqualToString:JOB_SYNC_DISEASE]) {
            if (data == nil) {
                block(jobId, false);
                return;
            }
            NSString *diseaseId = [data objectForKey:JOB_PARAM_DID];
            if (diseaseId == nil) {
                block(jobId, false);
                return;
            }
            [STASDKSync syncDisease:diseaseId callback:^(NSError *err) {
                if (err != nil) {
                    block(jobId, false);
                } else {
                    block(jobId, true);
                }
            }];


        // SYNC TRIP ALERTS
        } else if ([job.jobName isEqualToString:JOB_SYNC_TRIP_ALERTS]) {
            if (data == nil) {
                block(jobId, false);
                return;
            }
            NSString *tripId = [data objectForKey:JOB_PARAM_TRIPID];
            if (tripId == nil) {
                block(jobId, false);
                return;
            }
            [STASDKSync syncTripAlerts:tripId callback:^(NSError *err) {
                if (err != nil) {
                    block(jobId, false);
                } else {
                    block(jobId, true);
                }
            }];


        // SYNC TRIP ADVISORIES
        } else if ([job.jobName isEqualToString:JOB_SYNC_TRIP_ADVISORIES]) {
            if (data == nil) {
                block(jobId, false);
                return;
            }
            NSString *tripId = [data objectForKey:JOB_PARAM_TRIPID];
            if (tripId == nil) {
                block(jobId, false);
                return;
            }
            [STASDKSync syncTripAdvisories:tripId callback:^(NSError *err) {
                if (err != nil) {
                    block(jobId, false);
                } else {
                    block(jobId, true);
                }
            }];

        // SYNC TRIP HOSPITALS
        } else if ([job.jobName isEqualToString:JOB_SYNC_TRIP_HOSPITALS]) {
            if (data == nil) {
                block(jobId, false);
                return;
            }
            NSString *tripId = [data objectForKey:JOB_PARAM_TRIPID];
            if (tripId == nil) {
                block(jobId, false);
                return;
            }
            [STASDKSync syncTripHospitals:tripId callback:^(NSError *err) {
                if (err != nil) {
                    block(jobId, false);
                } else {
                    block(jobId, true);
                }
            }];

        // MARK ALERT AS READ
        } else if ([job.jobName isEqualToString:JOB_ALERT_MARK_READ]) {
            if (data == nil) {
                block(jobId, false);
                return;
            }
            NSString *alertId = [data objectForKey:JOB_PARAM_AID];
            if (alertId == nil) {
                block(jobId, false);
                return;
            }
            [STASDKSync syncAlertMarkRead:alertId callback:^(NSError *err) {
                if (err != nil) {
                    block(jobId, false);
                } else {
                    block(jobId, true);
                }
            }];

        // SYNC PUSH TOKEN
        } else if ([job.jobName isEqualToString:JOB_SYNC_PUSH_TOKEN]) {
            if (data == nil) {
                block(jobId, false);
                return;
            }
            NSString *token = [data objectForKey:JOB_PARAM_PTOKEN];
            if (token == nil) {
                block(jobId, false);
                return;
            }
            [STASDKSync syncPushToken:token callback:^(NSError *err) {
                if (err != nil) {
                    block(jobId, false); // retry
                } else {
                    block(jobId, true);
                }
            }];

        // SYNC SINGULAR ALERT (PUSH NOTIFICATION)
        } else if ([job.jobName isEqualToString:JOB_SYNC_PUSH_TOKEN]) {
            if (data == nil) {
                block(jobId, false);
                return;
            }
            NSString *alertId = [data objectForKey:JOB_PARAM_AID];
            if (alertId == nil) {
                block(jobId, false);
                return;
            }
            [STASDKSync syncAlert:alertId callback:^(NSError *err) {
                if (err != nil) {
                    block(jobId, false);
                } else {
                    block(jobId, true);
                }
            }];

        // TRIP SETTINGS
        } else if ([job.jobName isEqualToString:JOB_SYNC_PUSH_TOKEN]) {
            if (data == nil) {
                block(jobId, false);
                return;
            }
            NSString *tripId = [data objectForKey:JOB_PARAM_TRIPID];
            NSDictionary *settings = [data objectForKey:JOB_PARAM_SETTINGS];
            if (tripId == nil) {
                block(jobId, false);
                return;
            }
            [STASDKApiTrip changeTripSettings:tripId settings:settings onFinished:^(NSURLSessionTask *task, NSError *error) {
                if (error != nil) {
                    block(jobId, false);
                } else {
                    block(jobId, true);
                }
            }];

        // USER SETTINGS
        } else if ([job.jobName isEqualToString:JOB_UPDATE_USER_SETTINGS]) {
            if (data == nil) {
                block(jobId, false);
                return;
            }
            NSString *settingsId = [data objectForKey:JOB_PARAM_SETTINGS];
            if (settingsId == nil) {
                block(jobId, false);
                return;
            }
            STASDKMUserSettings *settings = [STASDKMUserSettings findBy:settingsId];
            if (settings == nil) {
                block(jobId, false);
                return;
            }
            STASDKMTraveller *user = (STASDKMTraveller*) settings.travellers.firstObject;
            if (user == nil) {
                block(jobId, false);
                return;
            }
            [STASDKApiTraveller update:user onFinished:^(STASDKMTraveller *user, NSURLSessionDataTask *task, NSError *error) {
                if (error != nil) {
                    block(jobId, false);
                } else {
                    block(jobId, true);
                }
            }];

        // ANALYTICS
        } else if ([job.jobName isEqualToString:JOB_UPDATE_USER_SETTINGS]) {
            if (data == nil) {
                block(jobId, false);
                return;
            }
            NSString *eventId = [data objectForKey:JOB_PARAM_EID];
            if (eventId == nil) {
                block(jobId, false);
                return;
            }
            STASDKMEvent *event = [STASDKMEvent findBy:eventId];
            NSString *identifier = event.identifier;
            [STASDKApiMisc sendEvent:event onFinished:^(NSURLSessionDataTask *task, NSError *error) {
                if (error != nil) {
                    block(jobId, false);
                } else {
                    // remove event from local database
                    [STASDKMEvent destroy:identifier];
                    block(jobId, true);
                }
            }];
        }
    } @catch (NSException *exception) {
        block(jobId, false);
    }


}




@end




