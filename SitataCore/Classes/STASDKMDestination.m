//
//  STASDKMDestination.m
//  Pods
//
//  Created by Adam St. John on 2017-05-03.
//
//

#import "STASDKMDestination.h"

#import "STASDKApiUtils.h"

@implementation STASDKMDestination

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
             @"countryId": @"country_id",
             @"countryCode": @"country_code",
             @"departureDate": @"departure_date",
             @"returnDate": @"return_date"
             };
}


- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSString *departureStr = dic[@"departure_date"];
    NSString *returnStr = dic[@"return_date"];

    NSDateFormatter *dfmt = [STASDKApiUtils dateFormatter];
    if (![departureStr isEqual:(id)[NSNull null]]) {
        _departureDate = [dfmt dateFromString:departureStr];
    }
    if (![returnStr isEqual:(id)[NSNull null]]) {
        _returnDate = [dfmt dateFromString:returnStr];
    }



    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {


    if (![_departureDate isEqual:(id)[NSNull null]]) {
        dic[@"departure_date"] = [NSNumber numberWithDouble:[_departureDate timeIntervalSince1970]];
    }
    if (![_returnDate isEqual:(id)[NSNull null]]) {
        dic[@"return_date"] = [NSNumber numberWithDouble:[_returnDate timeIntervalSince1970]];
    }


    return YES;
}


@end
