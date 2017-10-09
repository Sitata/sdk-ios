//
//  STASDKMJob.m
//  SitataCore
//
//  Created by Adam St. John on 2017-10-09.
//

#import "STASDKMJob.h"

#import "STASDKDataController.h"

@implementation STASDKMJob

+ (NSString *)primaryKey {
    return @"identifier";
}


+(STASDKMJob*)captureFirstJob:(int)jobStatus {
    RLMRealm *realm = [[STASDKDataController sharedInstance] theRealm];

    [realm beginWriteTransaction];
    STASDKMJob *job = [STASDKMJob findFirstByStatus:jobStatus]; 
    if (job) {
        job.status = 1;
    }
    [realm commitWriteTransaction];
    return job;
}


+(STASDKMJob*)findFirstByStatus:(int)status {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(status == %d)", status];
    RLMResults<STASDKMJob *> *results = [[STASDKMJob objectsInRealm:[[STASDKDataController sharedInstance] theRealm] withPredicate:pred] sortedResultsUsingKeyPath:@"createdAt" ascending:YES];
    if (results && results.count > 0) {
        return results.firstObject;
    } else {
        return nil;
    }
}

+(RLMResults<STASDKMJob*>*)findDead {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(status == %d)", -1];
    RLMResults<STASDKMJob *> *results = [[STASDKMJob objectsInRealm:[[STASDKDataController sharedInstance] theRealm] withPredicate:pred] sortedResultsUsingKeyPath:@"createdAt" ascending:YES];
    return results;
}

+(STASDKMJob*)findBy:(NSString *)identifier {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];

    RLMResults<STASDKMJob *> *results = [STASDKMJob objectsInRealm:[[STASDKDataController sharedInstance] theRealm] withPredicate:pred];
    if (results && results.count > 0) {
        return results.firstObject;
    } else {
        return nil;
    }
}

+(bool)checkExists:(STASDKMJob*)job {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(jobName == %@) AND (jobArgs == %@)", job.jobName, job.jobArgs];
    RLMResults<STASDKMJob *> *results = [[STASDKMJob objectsInRealm:[[STASDKDataController sharedInstance] theRealm] withPredicate:pred] sortedResultsUsingKeyPath:@"createdAt" ascending:YES];

    return results.count > 0;
}

//+(STASDKMJob*)findBy:(NSString *)jobName jobArgs:(NSDictionary*)jobArgs {
//    NSString* jobArgsStr = [self jobArgsToString:jobArgs];
//
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(jobName == %@) AND (jobArgs == %@)", jobName, jobArgsStr];
//    RLMResults<STASDKMJob *> *results = [STASDKMJob objectsInRealm:[[STASDKDataController sharedInstance] theRealm] withPredicate:pred];
//    if (results && results.count > 0) {
//        return results.firstObject;
//    } else {
//        return nil;
//    }
//}




+(NSString*)jobArgsToString:(NSDictionary*)jobArgs {
    NSError *err;
    NSData *jsonData = [NSJSONSerialization  dataWithJSONObject:jobArgs options:0 error:&err];
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return str;
}

+(NSDictionary*)jobArgsFromString:(NSString*)jobStr {
    NSError * err;
    NSData *data =[jobStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *response;
    if(data!=nil){
        response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    }
    return response;
}



- (id)init
{
    self = [super init];
    if (self) {
        _status = 0;
        _maxRetries = 10;
        _retries = 0;
        _createdAt = [[NSDate alloc] init];
        _identifier = [[NSUUID UUID] UUIDString];
    }
    return self;
}


- (void)addJobArgs:(NSDictionary*)args {
    self.jobArgs = [STASDKMJob jobArgsToString:args];
}
- (NSDictionary*)fetchJobArgs {
    return [STASDKMJob jobArgsFromString:self.jobArgs];
}

- (void)incRetries {
    RLMRealm *realm = [[STASDKDataController sharedInstance] theRealm];

    [realm beginWriteTransaction];
    self.retries++;
    self.status = 2; // failed
    if (self.retries > self.maxRetries) {
        self.status = -1;
    }
    [realm commitWriteTransaction];
}

+ (void)incRetries:(NSString*)identifier {
    RLMRealm *realm = [[STASDKDataController sharedInstance] theRealm];
    STASDKMJob *oldJob = [STASDKMJob findBy:identifier];
    if (oldJob != NULL) {
        [realm transactionWithBlock:^{
            oldJob.retries++;
            oldJob.status = 2; // failed
            if (oldJob.retries > oldJob.maxRetries) {
                oldJob.status = -1;
            }
        }];
    }
}

+ (void)destroy:(NSString*)identifier {
    RLMRealm *realm = [[STASDKDataController sharedInstance] theRealm];
    STASDKMJob *deleteJob = [STASDKMJob findBy:identifier];
    if (deleteJob != NULL) {
        [realm transactionWithBlock:^{
            [realm deleteObject:deleteJob];
        }];
    }
}

@end
