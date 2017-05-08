//
//  STASDKMHospital.m
//  Pods
//
//  Created by Adam St. John on 2017-05-02.
//
//

#import "STASDKMHospital.h"
#import "STASDKApiUtils.h"
#import "STASDKMAddress.h"
#import "STASDKMContactDetail.h"

@implementation STASDKMHospital


@synthesize description;

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

+ (NSString *)primaryKey {
    return @"identifier";
}



#pragma mark - DB Queries


+(RLMResults<STASDKMHospital*>*)findForCountry:(NSString*)countryId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"countryId == %@", countryId];
    return [[STASDKMHospital objectsWithPredicate:predicate] sortedResultsUsingKeyPath:@"updatedAt" ascending:NO];
}




-(NSArray*)locationArr {
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.location];
}

-(double)longitude {
    NSArray *loc = [self locationArr];
    return [[loc objectAtIndex:0] doubleValue];
}
-(double)latitude {
    NSArray *loc = [self locationArr];
    return [[loc objectAtIndex:1] doubleValue];
}




-(BOOL)isAccredited {
    return [self accrJci]; // only accreditation so far is by JCI.
}

// Returns the contact details
-(NSArray*)contactDetailsArray {
    NSError *error;
    NSData* data = [self.contactDetails dataUsingEncoding:NSUTF8StringEncoding];
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

//
-(STASDKMAddress*)addressObj {
    NSError *error;
    NSData* data = [self.address dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *props = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if (error == nil) {
        return [[STASDKMAddress alloc] initWith:props];
    } else {
        return NULL;
    }
}







#pragma mark - Object Mapping

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"updatedAt": @"updated_at",
             @"createdAt": @"created_at",
             @"verifiedAt": @"verified_at",
             @"identifier": @"id",

             @"name": @"name",
             @"description": @"description",
             @"countryId": @"country_id",
             @"starred": @"starred",
             @"emergency": @"emergency",
             @"accrJci": @"accr_jci",
             @"verified": @"verified",

             @"location": @"location",
             @"address": @"address",
             @"contactDetails": @"contactDetails"

             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSString *createdAtStr = dic[@"created_at"];
    NSString *updatedAtStr = dic[@"updated_at"];
    NSString *verifiedAtStr = dic[@"verified_at"];

    NSDateFormatter *fmt = [STASDKApiUtils dateTimeFormatter];
    if (![createdAtStr isEqual:(id)[NSNull null]]) {
        _createdAt = [fmt dateFromString:createdAtStr];
    }
    if (![updatedAtStr isEqual:(id)[NSNull null]]) {
        _updatedAt = [fmt dateFromString:updatedAtStr];
    }
    if (![verifiedAtStr isEqual:(id)[NSNull null]]) {
        _verifiedAt = [fmt dateFromString:verifiedAtStr];
    }

    // JSON array of [longitude, latitude]
    NSArray *loc = [dic objectForKey:@"location"];
    _location = [NSKeyedArchiver archivedDataWithRootObject:loc];
    


    NSDictionary *address = [dic objectForKey:@"address"];
    if (address != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:address options:0 error:&error];
        if (data != nil) {
            NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _address = jsonStr;
        }
    }

    NSDictionary *contactDetails = [dic objectForKey:@"contact_details"];
    if (contactDetails != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:contactDetails options:0 error:&error];
        if (data != nil) {
            NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _contactDetails = jsonStr;
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
    if (![_verifiedAt isEqual:(id)[NSNull null]]) {
        dic[@"verified_at"] = [NSNumber numberWithDouble:[_verifiedAt timeIntervalSince1970]];
    }

    return YES;
}









@end
