//
//  STASDKMAlert.m
//  Pods
//
//  Created by Adam St. John on 2017-05-02.
//
//

#import "STASDKMAlert.h"

#import "STASDKApiUtils.h"
#import "STASDKMAlertSource.h"
#import "STASDKMAlertLocation.h"
#import "STASDKMTrip.h"
#import "STASDKDataController.h"

#import "STASDKJobs.h"
#import <EDQueue/EDQueue.h>

@implementation STASDKMAlert

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

+(STASDKMAlert*)findBy:(NSString *)alertId {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"identifier == %@", alertId];

    RLMResults<STASDKMAlert *> *results = [STASDKMAlert objectsInRealm:[[STASDKDataController sharedInstance] theRealm] withPredicate:pred];
    if (results && results.count > 0) {
        return results.firstObject;
    } else {
        return nil;
    }
}








// alert sources are stringified json
-(NSArray*)alertSourcesArr {

    NSError *error;
    NSData* data = [self.alertSources dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error == nil) {
        NSMutableArray *sources = [[NSMutableArray alloc] init];
        for (NSDictionary *alertSourceDict in jsonArr) {

            STASDKMAlertSource *as = [[STASDKMAlertSource alloc] initWith:alertSourceDict];
            [sources addObject:as];
        }
        return sources;
    } else {
        return @[]; // return empty array if error
    }
}

// alert locations are stringified json
-(NSArray*)alertLocationsArr {
    NSError *error;
    NSData* data = [self.alertLocations dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error == nil) {
        NSMutableArray *locations = [[NSMutableArray alloc] init];
        for (NSDictionary *locationDict in jsonArr) {

            STASDKMAlertLocation *al = [[STASDKMAlertLocation alloc] initWith:locationDict];
            [locations addObject:al];
        }
        return locations;
    } else {
        return @[]; // return empty array if error
    }
}

// Returns an array of NSDictionary objects representing the associated countries.
-(NSArray*)countriesArr {
    NSError *error;
    NSData* data = [self.countries dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error == nil) {
        return jsonArr;
    } else {
        return @[]; // return empty array if error
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


-(NSArray*)diseaseIdsArr {
    NSError *error;
    NSData* data = [self.diseaseIds dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error == nil) {
        return jsonArr;
    } else {
        return @[]; // return empty array if error
    }
}


-(BOOL)isDiseaseType {
    return [self.category isEqualToString:@"health"];
}

-(void)setRead {
    if (!self._read) {
        RLMRealm *realm = [[STASDKDataController sharedInstance] theRealm];
        [realm beginWriteTransaction];
        self._read = YES;
        [realm commitWriteTransaction];
        [[EDQueue sharedInstance] enqueueWithData:@{JOB_PARAM_AID: [self identifier]} forTask:JOB_ALERT_MARK_READ];
    }
}





# pragma mark - Object Mapping




+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"updatedAt": @"updated_at",
             @"createdAt": @"created_at",
             @"identifier": @"id",

             @"headline": @"headline",
             @"body": @"body",
             @"bodyAdvice": @"body_advice",
             @"category": @"category",
             @"riskLevel": @"risk_level",


             @"alertLocations": @"alert_locations",
             @"alertSources": @"alert_sources",
             @"countryIds": @"country_ids",
             @"diseaseIds": @"disease_ids",
             @"safetyIds": @"safety_ids",
             @"countries": @"countries",
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


    NSDictionary *alertLocations = [dic objectForKey:@"alert_locations"];
    if (alertLocations != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:alertLocations options:0 error:&error];
        if (data != nil) {
            NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _alertLocations = jsonStr;
        }
    }

    NSDictionary *alertSources = [dic objectForKey:@"alert_sources"];
    if (alertSources != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:alertSources options:0 error:&error];
        if (data != nil) {
            NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _alertSources = jsonStr;
        }
    }

    NSDictionary *countryIds = [dic objectForKey:@"country_ids"];
    if (countryIds != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:countryIds options:0 error:&error];
        if (data != nil) {
            NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _countryIds = jsonStr;
        }
    }

    NSDictionary *diseaseIds = [dic objectForKey:@"disease_ids"];
    if (diseaseIds != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:diseaseIds options:0 error:&error];
        if (data != nil) {
            NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _diseaseIds = jsonStr;
        }
    }

    NSDictionary *safetyIds = [dic objectForKey:@"safety_ids"];
    if (safetyIds != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:safetyIds options:0 error:&error];
        if (data != nil) {
            NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _safetyIds = jsonStr;
        }
    }

    NSDictionary *countries = [dic objectForKey:@"countries"];
    if (countries != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:countries options:0 error:&error];
        if (data != nil) {
            NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _countries = jsonStr;
        }
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
