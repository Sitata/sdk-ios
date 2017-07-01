//
//  STASDKMTrip.m
//  Pods
//
//  Created by Adam St. John on 2017-05-02.
//
//

#import "STASDKMTrip.h"

#import "STASDKApiUtils.h"
#import "STASDKMCountry.h"
#import "STASDKMDestination.h"
#import "STASDKMTripHealthComment.h"

#import <YYModel/YYModel.h>

@implementation STASDKMTrip

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

+(STASDKMTrip*)findBy:(NSString *)tripId {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"identifier == %@", tripId];

    RLMResults<STASDKMTrip *> *results = [STASDKMTrip objectsWithPredicate:pred];
    if (results && results.count > 0) {
        return results.firstObject;
    } else {
        return nil;
    }
}



+(STASDKMTrip*)currentTrip {

    //gather current calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //gather date components from date
    NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    //set date components
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    [dateComponents setNanosecond:0];

    NSDate *equalizedToday = [calendar dateFromComponents:dateComponents];

    // SELECT DATES WITH FINISH DAY GREATER OR EQUAL TO TODAY SORTED BY START DATE ASCENDING AND CHOOSE FIRST
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"finish >= %@", equalizedToday];

    RLMResults<STASDKMTrip *> *results = [[STASDKMTrip objectsWithPredicate:pred] sortedResultsUsingKeyPath:@"start" ascending:YES];

    if (results && results.count > 0) {
        return results.firstObject;
    } else {
        return nil;
    }

}



-(void)resave:(NSError **)error {
    RLMRealm *realm = [RLMRealm defaultRealm];

    // destroy related models where applicable
    STASDKMTrip *oldTrip = [STASDKMTrip findBy:self.identifier];
    if (oldTrip != NULL) {
        [realm beginWriteTransaction];
        [oldTrip.destinations removeAllObjects];
        [oldTrip.tripDiseaseComments removeAllObjects];
        [oldTrip.tripMedicationComments removeAllObjects];
        [oldTrip.tripVaccinationComments removeAllObjects];
        NSError *assocError;
        [realm commitWriteTransaction:&assocError];
        if (assocError) {
            *error = assocError;
            NSLog(@"Error removing associated trip models - %@", [assocError localizedDescription]);
            return;
        }
    }

    // save self
    NSError *selfError;
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:self];
    [realm commitWriteTransaction:&selfError];

    if (selfError != NULL) {
        *error = selfError;
    }
}

// Returns true if the trip does not have any destination data.
-(bool)isEmpty {
    return [[self destinations] count] <= 0;
}



-(RLMResults<STASDKMDestination*>*)sortedDestinations {
    return [[self destinations] sortedResultsUsingKeyPath:@"departureDate" ascending:YES];
}


// Returns the country that the user is currently in according to the
// trip itinerary or NULL.
-(STASDKMCountry*)currentCountry {
    STASDKMDestination *currentDest = [self currentDestination];
    if (currentDest) {
        return [STASDKMCountry findBy:currentDest.countryId];
    }
    return NULL;
}

// Returns the destination that the user is currently in according to
// the trip itinerary or NULL;
-(STASDKMDestination*)currentDestination {
    RLMResults<STASDKMDestination*> *destinations = [self sortedDestinations];
    NSDate *now = [[NSDate alloc] init];
    NSDate *compareNow = [[NSCalendar currentCalendar] startOfDayForDate:now];

    for (STASDKMDestination *dest in destinations) {
        // compare to today's date to see if we're in that destination
        // return it immediately if so - i.e. return first match
        NSDate *compareEnd = [[NSCalendar currentCalendar] startOfDayForDate:[dest returnDate]];

        //        The receiver and anotherDate are exactly equal to each other, NSOrderedSame
        //        The receiver is later in time than anotherDate, NSOrderedDescending
        //        The receiver is earlier in time than anotherDate, NSOrderedAscending.
        NSComparisonResult comparisonEnd = [compareNow compare:compareEnd];

        // if we are already past this destination, skip it
        if (comparisonEnd == NSOrderedDescending) {
            continue;
        } else {
            // otherwise, return the first destination that we haven't skipped yet.
            // This works because the dates are orderd.
            return dest;
        }
    }
    return NULL;
}


-(NSArray*)activitiesArr {
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.activities];
}








#pragma mark - Object Mapping

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"name": @"name",
             @"updatedAt": @"updated_at",
             @"createdAt": @"created_at",
             @"deletedAt": @"deleted_at",
             @"identifier": @"id",
             @"start": @"start",
             @"finish": @"finish",
             @"muted": @"muted",
             @"read": @"read",
             @"tripType": @"trip_type",
             @"activities": @"activities",
             @"destinations": @"destinations",
             @"tripVaccinationComments": @"trip_vaccination_comments",
             @"tripDiseaseComments": @"trip_disease_comments",
             @"tripMedicationComments": @"trip_medication_comments",
             @"companyName": @"company_name",
             @"companyId": @"company_id",
             @"employeeName": @"employee_name",
             @"employeeId": @"employee_id",
             @"pastAlertCount": @"past_alert_count"
             };
}

// Not working at the moment with Realm Collections
//+ (NSDictionary *)modelContainerPropertyGenericClass {
//    // value should be Class or Class name.
//    return @{@"destinations" : [STASDKMDestination class],
//             @"tripVaccinationComments": [STASDKMTripVaccinationComment class],
//             @"tripDiseaseComments": [STASDKMTripDiseaseComment class],
//             @"tripMedicationComments": [STASDKMTripMedicationComment class]
//             };
//}


- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {

    // We have to do the following for trip comments and destinations
    // explicitly because Realm doesn't play nice 100% with yyModel.
    NSArray *destinations = dic[@"destinations"];
    for (NSDictionary *d in destinations) {
        STASDKMDestination *dest = [STASDKMDestination yy_modelWithDictionary:d];
        [self.destinations addObject:dest];
    }

    NSArray *tvcs = dic[@"trip_vaccination_comments"];
    for (NSDictionary *c in tvcs) {
        STASDKMTripVaccinationComment *tc = [STASDKMTripVaccinationComment yy_modelWithDictionary:c];
        [self.tripVaccinationComments addObject:tc];
    }

    NSArray *tmcs = dic[@"trip_medication_comments"];
    for (NSDictionary *c in tmcs) {
        STASDKMTripMedicationComment *tc = [STASDKMTripMedicationComment yy_modelWithDictionary:c];
        [self.tripMedicationComments addObject:tc];
    }

    NSArray *tdcs = dic[@"trip_disease_comments"];
    for (NSDictionary *c in tdcs) {
        STASDKMTripDiseaseComment *tc = [STASDKMTripDiseaseComment yy_modelWithDictionary:c];
        [self.tripDiseaseComments addObject:tc];
    }

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

    // JSON array of integers
    NSArray *acts = [dic objectForKey:@"activities"];
    _activities = [NSKeyedArchiver archivedDataWithRootObject:acts];


    NSString *startStr = dic[@"start"];
    NSString *finishStr = dic[@"finish"];
    NSDateFormatter *dfmt = [STASDKApiUtils dateFormatter];
    if (![startStr isEqual:(id)[NSNull null]]) {
        _start = [dfmt dateFromString:startStr];
    }
    if (![finishStr isEqual:(id)[NSNull null]]) {
        _finish = [dfmt dateFromString:finishStr];
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

    if (![_start isEqual:(id)[NSNull null]]) {
        dic[@"start"] = [NSNumber numberWithDouble:[_start timeIntervalSince1970]];
    }
    if (![_finish isEqual:(id)[NSNull null]]) {
        dic[@"finish"] = [NSNumber numberWithDouble:[_finish timeIntervalSince1970]];
    }


    return YES;
}



@end
