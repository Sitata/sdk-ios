//
//  STASDKMUserSettings.m
//  Pods
//
//  Created by Adam St. John on 2017-07-18.
//
//

#import "STASDKMUserSettings.h"
#import "STASDKMTraveller.h"
#import "STASDKDataController.h"
#import "STASDKDefines.h"
#import "STASDKJobs.h"



@implementation STASDKMUserSettings

// To establish inverse relationship
+ (NSDictionary*)linkingObjectsProperties {
    return @{
             @"travellers": [RLMPropertyDescriptor descriptorWithClass:STASDKMTraveller.class propertyName:@"settings"],
             };
}





#pragma mark - Queries


+(STASDKMUserSettings*)findBy:(NSString *)settingsId {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"identifier == %@", settingsId];

    RLMRealm *realm = [[STASDKDataController sharedInstance] theRealm];
    RLMResults<STASDKMUserSettings *> *results = [STASDKMUserSettings objectsInRealm:realm withPredicate:pred];
    if (results && results.count > 0) {
        return results.firstObject;
    } else {
        return nil;
    }
}





-(void)backgroundUpdate:(NSError **)error {
    RLMRealm *realm = [[STASDKDataController sharedInstance] theRealm];

    [realm beginWriteTransaction];
    [realm addOrUpdateObject:self];
    [realm commitWriteTransaction:error];

    if (*error == NULL) {
        // spin up background job to save settings on server
        [[STASDKJobs sharedInstance] addJob:JOB_UPDATE_USER_SETTINGS jobArgs:@{JOB_PARAM_SETTINGS: self.identifier}];
    }
}






#pragma mark - Object Mapping
+ (NSString *)primaryKey {
    return @"identifier";
}



+ (NSDictionary *)modelCustomPropertyMapper {
    //@property BOOL *checkInWithLocation;
    return @{
             @"identifier": @"id",
             @"sendTripAlertEmail": @"send_trip_alert_email",
             @"sendAllGoodEmail": @"send_all_good_email",
             @"sendTripAlertPush": @"send_trip_alert_push",
             @"sendAllGoodPush": @"send_all_good_push"
             };
}













@end
