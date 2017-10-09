//
//  STASDKMJob.h
//  SitataCore
//
//  Created by Adam St. John on 2017-10-09.
//

#import <Realm/Realm.h>

@interface STASDKMJob : RLMObject

@property (retain) NSString *identifier;
@property (retain) NSString *jobName;
@property (nonatomic) NSString *jobArgs;
@property (retain) NSDate *createdAt;
@property int maxRetries;
@property int retries;
@property int status; // 0 unproccessed, 1 processing, 2 failed, -1 dead

// Within a transaction, fetch the first unprocessed job and mark as processing
+ (STASDKMJob*)captureFirstJob:(int)jobStatus;

+(STASDKMJob*)findBy:(NSString *)identifier;
+(RLMResults<STASDKMJob*>*)findDead;

+(bool)checkExists:(STASDKMJob*)job;

- (void)addJobArgs:(NSDictionary*)args;
- (NSDictionary*)fetchJobArgs;

// Increment the number of retries. If max retries is exceeded, set status to dead
- (void)incRetries;

+ (void)incRetries:(NSString*)identifier;

// remove job from database
+ (void)destroy:(NSString*)identifier;

@end


RLM_ARRAY_TYPE(STASDKMJob)
