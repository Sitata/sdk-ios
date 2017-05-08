//
//  STASDKMCountry.m
//  Pods
//
//  Created by Adam St. John on 2017-05-02.
//
//

#import "STASDKMCountry.h"

#import "STASDKMContactDetail.h"
#import "STASDKApiUtils.h"


@implementation STASDKMCountry

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









// Returns the contact details for emergency numbers
-(NSArray*)emergNumbersArray {
    NSError *error;
    NSData* data = [self.emergNumbers dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSMutableArray *contacts = [[NSMutableArray alloc] init];

    if (error == nil) {
        for (NSDictionary *props in jsonArr) {
            STASDKMContactDetail *contact = [[STASDKMContactDetail alloc] initWith:props];
            [contacts addObject:contact];
        }
        return contacts;
    } else {
        return @[]; // return empty array if error
    }
}


// MARK: - Queries


+(STASDKMCountry*)findBy:(NSString *)countryId {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"identifier == %@", countryId];

    RLMResults<STASDKMCountry *> *results = [STASDKMCountry objectsWithPredicate:pred];
    if (results && results.count > 0) {
        return results.firstObject;
    } else {
        return nil;
    }
}

+(STASDKMCountry*)findByCountryCode:(NSString *)countryCode {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"countryCode == %@", countryCode];

    RLMResults<STASDKMCountry *> *results = [STASDKMCountry objectsWithPredicate:pred];
    if (results && results.count > 0) {
        return results.firstObject;
    } else {
        return nil;
    }
}

+(RLMResults<STASDKMCountry *>*)allCountries {
    return [[STASDKMCountry allObjects] sortedResultsUsingKeyPath:@"name" ascending:YES];
}



// MARK: - Object Mapping

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"identifier": @"id",
             @"updatedAt": @"updated_at",
             @"createdAt": @"created_at",
             @"deletedAt": @"deleted_at",
             @"name": @"name",
             @"countryCode": @"country_code",
             @"countryCode3": @"country_code_3",
             @"capital": @"capital",
             @"facts": @"facts",
             @"language": @"language",
             @"currencyName": @"currency_name",
             @"currencyCode": @"currency_code",
             @"divisionName": @"division_name",
             @"regionName": @"region_name",
             @"travelStatus": @"travel_status",
             @"secEmerNum": @"sec_emer_num",
             @"secPersonal": @"sec_personal",
             @"secExtViol": @"sec_ext_viol",
             @"secPolUnr": @"sec_pol_unr",
             @"secAreas": @"sec_areas",
             @"countryDatum": @"country_datum",
             @"emergNumbers": @"emerg_numbers",
             @"topoJson": @"topo_json"


             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSString *createdAtStr = dic[@"created_at"];
    NSString *updatedAtStr = dic[@"updated_at"];
    NSString *deletedAtStr = dic[@"deleted_at"];

    NSDateFormatter *fmt = [STASDKApiUtils dateTimeFormatter];
    if (![createdAtStr isEqual:(id)[NSNull null]]) {
        _createdAt = [fmt dateFromString:createdAtStr];
    }
    if (![updatedAtStr isEqual:(id)[NSNull null]]) {
        _updatedAt = [fmt dateFromString:updatedAtStr];
    }
    if (![deletedAtStr isEqual:(id)[NSNull null]]) {
        _deletedAt = [fmt dateFromString:deletedAtStr];
    }

    // separate flag json into different parts
    NSDictionary *flagJSON = [dic objectForKey:@"flag"];
    if (flagJSON != nil) {
        _flagURL = [flagJSON objectForKey:@"url"];
        _flagMainURL = [flagJSON objectForKey:@"main"];
        _flagListURL = [flagJSON objectForKey:@"list"];
    }

    NSDictionary *datum = [dic objectForKey:@"country_datum"];
    if (datum != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:datum options:0 error:&error];
        if (data != nil) {
            NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _countryDatum = jsonStr;
        }
    }

    NSArray *numbs = [dic objectForKey:@"emerg_numbers"];
    if (numbs != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:numbs options:0 error:&error];
        if (data != nil) {
            NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _emergNumbers = jsonStr;
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
    if (![_deletedAt isEqual:(id)[NSNull null]]) {
        dic[@"deleted_at"] = [NSNumber numberWithDouble:[_deletedAt timeIntervalSince1970]];
    }
    
    return YES;
}




@end
