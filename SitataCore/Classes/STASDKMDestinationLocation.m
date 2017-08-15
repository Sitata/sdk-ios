//
//  STASDKMDestinationLocation.m
//  Pods
//
//  Created by Adam St. John on 2017-07-10.
//
//

#import "STASDKMDestinationLocation.h"

@implementation STASDKMDestinationLocation

+ (NSString *)primaryKey {
    return @"identifier";
}

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}



#pragma mark - Object Mapping


+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"identifier": @"id",
             @"friendlyName": @"friendly_name",
             @"latitude": @"latitude",
             @"longitude": @"longitude"
             };
}






//- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
////    NSString *departureStr = dic[@"departure_date"];
////    NSString *returnStr = dic[@"return_date"];
////
////    NSDateFormatter *dfmt = [STASDKApiUtils dateFormatter];
////    if (![departureStr isEqual:(id)[NSNull null]]) {
////        _departureDate = [dfmt dateFromString:departureStr];
////    }
////    if (![returnStr isEqual:(id)[NSNull null]]) {
////        _returnDate = [dfmt dateFromString:returnStr];
////    }
//
//
//
//    return YES;
//}
//


- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {

    // Removing id on json output is necessary because we want our rails server
    // to blast away all destination locations and rebuild. If ids are present, then
    // rails will try to match with existing ids - which will throw a NotFoundError
    // for new destinations (because we set temporaray UUID to make realm work
    [dic removeObjectForKey:@"id"];

    return YES;
}
















@end
