//
//  STASDKMUserSettings.m
//  Pods
//
//  Created by Adam St. John on 2017-07-18.
//
//

#import "STASDKMUserSettings.h"

@implementation STASDKMUserSettings









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
