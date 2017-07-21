//
//  STASDKMDisease.m
//  Pods
//
//  Created by Adam St. John on 2017-05-02.
//
//

#import "STASDKMDisease.h"

#import "STASDKApiUtils.h"
#import "STASDKDataController.h"

@implementation STASDKMDisease

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





-(NSDictionary*)datumObj {
    // TODO: Can this process be memoized?
    NSError *error;
    NSData* data = [self.diseaseDatum dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *datum = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if (error == nil) {
        return datum;
    } else {
        return @{}; // return empty array if error
    }
}

// Returns description from disease datum field.
-(NSString*)description {
    NSDictionary *datum = [self datumObj];
    return [datum objectForKey:@"description"];
}

// Returns transmission from disease datum field.
-(NSString*)transmission {
    NSDictionary *datum = [self datumObj];
    return [datum objectForKey:@"transmission"];
}

// Returns susceptibility from disease datum field.
-(NSString*)susceptibility {
    NSDictionary *datum = [self datumObj];
    return [datum objectForKey:@"susceptibility"];
}

// Returns symptoms from disease datum field.
-(NSString*)symptoms {
    NSDictionary *datum = [self datumObj];
    return [datum objectForKey:@"symptoms"];
}

// Returns prevention from disease datum field.
-(NSString*)prevention {
    NSDictionary *datum = [self datumObj];
    return [datum objectForKey:@"prevention"];
}

// Returns treatment from disease datum field.
-(NSString*)treatment {
    NSDictionary *datum = [self datumObj];
    return [datum objectForKey:@"treatment"];
}




#pragma mark - Queries


+(STASDKMDisease*)findBy:(NSString *)diseaseId {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"identifier == %@", diseaseId];

    RLMResults<STASDKMDisease *> *results = [STASDKMDisease objectsInRealm:[[STASDKDataController sharedInstance] theRealm] withPredicate:pred];
    if (results && results.count > 0) {
        return results.firstObject;
    } else {
        return nil;
    }
}



#pragma mark - Object Mapping

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"updatedAt": @"updated_at",
             @"createdAt": @"created_at",
             @"deletedAt": @"deleted_at",
             @"identifier": @"id",

             @"name": @"name",
             @"commonName": @"common_name",
             @"fullName": @"full_name",
             @"scientificName": @"scientific_name",
             @"occursWhere": @"occurs_where",
             @"diseaseDatum": @"disease_datum"

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


    NSDictionary *datum = [dic objectForKey:@"disease_datum"];
    if (datum != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:datum options:0 error:&error];
        if (data != nil) {
            NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _diseaseDatum = jsonStr;
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
