//
//  STASDKMEvent.m
//  Pods
//
//  Created by Adam St. John on 2017-08-11.
//
//

#import "STASDKMEvent.h"

#import "STASDKDataController.h"
#import <EDQueue/EDQueue.h>
#import "STASDKJobs.h"

#import "STASDKController.h"
#import <CoreLocation/CoreLocation.h>

@implementation STASDKMEvent


+ (NSString *)primaryKey {
    return @"identifier";
}


+ (NSDictionary *)modelCustomPropertyMapper {

    return @{
             @"identifier": @"id",
             @"eventType": @"event_type",
             @"name": @"name",
             @"latitude": @"latitude",
             @"longitude": @"longitude",
             @"occurredAt": @"occurred_at"
             };
}




+(STASDKMEvent*)findBy:(NSString *)eventId {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"identifier == %@", eventId];

    RLMResults<STASDKMEvent *> *results = [STASDKMEvent objectsInRealm:[[STASDKDataController sharedInstance] theRealm] withPredicate:pred];
    if (results && results.count > 0) {
        return results.firstObject;
    } else {
        return nil;
    }
}


+(void)trackEvent:(int)eventType name:(int)name {
    // generate identifier
    // save to local db
    STASDKMEvent *event = [[STASDKMEvent alloc] init];
    event.occurredAt = [[NSDate alloc] init];
    event.eventType = eventType;
    event.name = name;
    event.identifier = [[NSUUID UUID] UUIDString];

    CLLocation *loc = [[STASDKController sharedInstance] currentLocation];
    if (loc != NULL) {
        CLLocationCoordinate2D coord = loc.coordinate;
        event.latitude = coord.latitude;
        event.longitude = coord.longitude;
    }

    RLMRealm *realm = [[STASDKDataController sharedInstance] theRealm];
    [realm transactionWithBlock:^{
        [realm addObject:event];
    }];

    // Do background job
    [[EDQueue sharedInstance] enqueueWithData:@{JOB_PARAM_EID: event.identifier} forTask:JOB_SEND_EVENT];
}

+(void)destroy:(NSString*)identifier {
    // this is so we don't have issues with realm threads
    RLMRealm *realm = [[STASDKDataController sharedInstance] theRealm];
    STASDKMEvent *deleteMeEvent = [STASDKMEvent findBy:identifier];
    if (deleteMeEvent != NULL) {
        [realm transactionWithBlock:^{
            [realm deleteObject:deleteMeEvent];
        }];
    }
}




- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {

    if (![self.occurredAt isEqual:(id)[NSNull null]]) {
        dic[@"occurred_at"] = [NSNumber numberWithDouble:[self.occurredAt timeIntervalSince1970]];
    }

    return YES;
}



@end
