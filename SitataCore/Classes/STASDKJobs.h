//
//  STASDKJobs.h
//  Pods
//
//  Created by Adam St. John on 2016-12-21.
//
//






@interface STASDKJobs : NSObject

@property bool stopped;
@property int runCount;


/**
 Shared instance singleton

 @return Shared instance
 */
+ (STASDKJobs*)sharedInstance;

-(void)processJobs;
-(void)start;
-(void)stop;

-(void)addJob:(NSString*)jobName;
-(void)addJob:(NSString*)jobName jobArgs:(NSDictionary*)jobArgs;
-(void)addJob:(NSString*)jobName jobArgs:(NSDictionary*)jobArgs maxRetries:(int)maxRetries;

@end





