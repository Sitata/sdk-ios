//
//  STASDKMDestination.m
//  Pods
//
//  Created by Adam St. John on 2017-05-03.
//
//

#import "STASDKMDestination.h"

#import "STASDKApiUtils.h"

#import <YYModel/YYModel.h>

#import "STASDKMDestinationLocation.h"

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

    // We have to do the following for destination locations
    // explicitly because Realm doesn't play nice 100% with yyModel.
    NSArray *destinationLocations = dic[@"destination_locations"];
    for (NSDictionary *d in destinationLocations) {
        STASDKMDestinationLocation *loc = [STASDKMDestinationLocation yy_modelWithDictionary:d];
        [self.destinationLocations addObject:loc];
    }



    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {


    if (![self.departureDate isEqual:(id)[NSNull null]]) {
        dic[@"departure_date"] = [NSNumber numberWithDouble:[self.departureDate timeIntervalSince1970]];
    }
    if (![self.returnDate isEqual:(id)[NSNull null]]) {
        dic[@"return_date"] = [NSNumber numberWithDouble:[self.returnDate timeIntervalSince1970]];
    }

    // Since 'container' properties are not working at the moment with Realm Collections
    NSMutableArray *destLocArr = [[NSMutableArray alloc] init];
    for (STASDKMDestinationLocation *loc in self.destinationLocations) {
        NSDictionary *locDict = [loc yy_modelToJSONObject];
        [destLocArr addObject:locDict];
    }
    dic[@"destination_locations"] = destLocArr;

    // Removing id on json output is necessary because we want our rails server
    // to blast away all destinations and rebuild. If ids are present, then
    // rails will try to match with existing ids - which will throw a NotFoundError
    // for new destinations (because we set temporaray UUID to make realm work
    [dic removeObjectForKey:@"id"];

    return YES;
}





// Removes associated models from the database
// THIS MUST BE CALLED WITHIN A REALM TRANSACTION
-(void)removeAssociated:(RLMRealm*)realm {
    for (STASDKMDestinationLocation* loc in self.destinationLocations) {
        [realm deleteObject:loc];
    }
    [self.destinationLocations removeAllObjects];
}



@end
