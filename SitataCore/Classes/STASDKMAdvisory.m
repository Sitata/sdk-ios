//
//  STASDKMAdvisory.m
//  Pods
//
//  Created by Adam St. John on 2017-05-03.
//
//

#import "STASDKMAdvisory.h"

#import "STASDKApiUtils.h"
#import "STASDKMTrip.h"
#import "STASDKDataController.h"

@implementation STASDKMAdvisory

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




#pragma mark - Queries

+(STASDKMAdvisory*)findBy:(NSString *)advisoryId {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"identifier == %@", advisoryId];

    RLMResults<STASDKMAdvisory *> *results = [STASDKMAdvisory objectsInRealm:[[STASDKDataController sharedInstance] theRealm] withPredicate:pred];
    if (results && results.count > 0) {
        return results.firstObject;
    } else {
        return nil;
    }
}









// country divisision boundaries are stringified json
-(NSArray*)countryDivisionsArr {
    NSError *error;
    NSData* data = [self.countryDivisions dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error == nil) {
        return jsonArr;
    } else {
        return @[]; // return empty array if error
    }
}

// country regions boundaries are stringified json
-(NSArray*)countryRegionsArr {
    NSError *error;
    NSData* data = [self.countryRegions dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error == nil) {
        return jsonArr;
    } else {
        return @[]; // return empty array if error
    }
}







#pragma mark - Object Mapping



+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"updatedAt": @"updated_at",
             @"createdAt": @"created_at",
             @"identifier": @"id",

             @"headline": @"headline",
             @"body": @"body",
             @"status": @"status",
             @"countryId": @"country_id",

             @"countryDivisions": @"country_divisions",
             @"countryRegions": @"country_regions",
             @"countryDivisionIds": @"country_division_ids",
             @"countryRegionIds": @"country_region_ids"


             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSString *createdAtStr = dic[@"created_at"];
    NSString *updatedAtStr = dic[@"updated_at"];

    NSDateFormatter *fmt = [STASDKApiUtils dateFormatter];
    if (![createdAtStr isEqual:(id)[NSNull null]]) {
        _createdAt = [fmt dateFromString:createdAtStr];
    }
    if (![updatedAtStr isEqual:(id)[NSNull null]]) {
        _updatedAt = [fmt dateFromString:updatedAtStr];
    }


    NSDictionary *divisions = [dic objectForKey:@"country_divisions"];
    if (divisions != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:divisions options:0 error:&error];
        if (data != nil) {
            NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _countryDivisions = jsonStr;
        }
    }

    NSDictionary *regions = [dic objectForKey:@"country_regions"];
    if (regions != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:regions options:0 error:&error];
        if (data != nil) {
            NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _countryRegions = jsonStr;
        }
    }

    NSDictionary *divisionIds = [dic objectForKey:@"country_division_ids"];
    if (divisionIds != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:divisionIds options:0 error:&error];
        if (data != nil) {
            NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _countryDivisionIds = jsonStr;
        }
    }

    NSDictionary *regionIds = [dic objectForKey:@"country_region_ids"];
    if (regionIds != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:regionIds options:0 error:&error];
        if (data != nil) {
            NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _countryRegionIds = jsonStr;
        }
    }




    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {

    if (![_createdAt isEqual:(id)[NSNull null]]) {
        dic[@"created_at"] = [NSNumber numberWithDouble:[_createdAt timeIntervalSince1970]];
    }
    if (![_updatedAt isEqual:(id)[NSNull null]]) {
        dic[@"updated_at"] = [NSNumber numberWithDouble:[_updatedAt timeIntervalSince1970]];
    }
    
    return YES;
}





@end
