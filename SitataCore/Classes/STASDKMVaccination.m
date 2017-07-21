//
//  STASDKMVaccination.m
//  Pods
//
//  Created by Adam St. John on 2017-05-02.
//
//

#import "STASDKMVaccination.h"
#import "STASDKApiUtils.h"
#import "STASDKDataController.h"

@implementation STASDKMVaccination

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


+(STASDKMVaccination*)findBy:(NSString *)vaccinationId {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"identifier == %@", vaccinationId];

    RLMResults<STASDKMVaccination *> *results = [STASDKMVaccination objectsInRealm:[[STASDKDataController sharedInstance] theRealm] withPredicate:pred];
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
             @"identifier": @"id",
             @"name": @"name",
             @"vaccinationDatum": @"vaccination_datum"

             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSString *updatedAtStr = dic[@"updated_at"];

    NSDateFormatter *fmt = [STASDKApiUtils dateTimeFormatter];
    if (![updatedAtStr isEqual:(id)[NSNull null]]) {
        _updatedAt = [fmt dateFromString:updatedAtStr];
    }


    NSDictionary *datum = [dic objectForKey:@"vaccination_datum"];
    if (datum != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:datum options:0 error:&error];
        if (data != nil) {
            NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _vaccinationDatum = jsonStr;
        }
    }

    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {

    if (![_updatedAt isEqual:(id)[NSNull null]]) {
        dic[@"updated_at"] = [NSNumber numberWithDouble:[_updatedAt timeIntervalSince1970]];
    }
    
    return YES;
}



@end
