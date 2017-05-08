//
//  STASDKMTripHealthComment.m
//  Pods
//
//  Created by Adam St. John on 2017-05-03.
//
//

#import "STASDKMTripHealthComment.h"

#import "STASDKMTrip.h"

@implementation STASDKMTripDiseaseComment

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

+(RLMResults<STASDKMTripDiseaseComment*>*)commentsForDisease:(NSString*)diseaseId trip:(STASDKMTrip*)trip {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"diseaseId = %@", diseaseId];
    return [[[trip tripDiseaseComments] objectsWithPredicate:predicate] sortedResultsUsingKeyPath:@"diseaseName" ascending:YES];
}

#pragma mark - Object Mapping Disease

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"identifier": @"id",
             @"countryId": @"country_id",
             @"comment": @"comment",
             @"diseaseId": @"disease_id",
             @"diseaseName": @"disease_name"
             };
}







@end



@implementation STASDKMTripVaccinationComment

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

+(RLMResults<STASDKMTripVaccinationComment*>*)commentsForVaccination:(NSString*)vaccinationId trip:(STASDKMTrip*)trip {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vaccinationId = %@", vaccinationId];
    return [[[trip tripVaccinationComments] objectsWithPredicate:predicate] sortedResultsUsingKeyPath:@"vaccinationName" ascending:YES];
}


#pragma mark - Object Mapping Vaccination

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"identifier": @"id",
             @"countryId": @"country_id",
             @"comment": @"comment",
             @"vaccinationId": @"vaccination_id",
             @"vaccinationName": @"vaccination_name"
             };
}


@end



@implementation STASDKMTripMedicationComment

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

+(RLMResults<STASDKMTripMedicationComment*>*)commentsForMedication:(NSString*)medicationId trip:(STASDKMTrip*)trip {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"medicationId = %@", medicationId];
    return [[[trip tripMedicationComments] objectsWithPredicate:predicate] sortedResultsUsingKeyPath:@"medicationName" ascending:YES];
}


#pragma mark - Object Mapping Medication

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"identifier": @"id",
             @"countryId": @"country_id",
             @"comment": @"comment",
             @"medicationId": @"medication_id",
             @"medicationName": @"medication_name"
             };
}


@end

