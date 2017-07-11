//
//  STASDKMDestinationLocation.m
//  Pods
//
//  Created by Adam St. John on 2017-07-10.
//
//

#import "STASDKMDestinationLocation.h"

@implementation STASDKMDestinationLocation

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
             @"friendlyName": @"friendly_name",
             @"latitude": @"latitude",
             @"longitude": @"longitude"
             };
}



//- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
////    NSString *departureStr = dic[@"departure_date"];
////    NSString *returnStr = dic[@"return_date"];
////
////    NSDateFormatter *dfmt = [STASDKApiUtils dateFormatter];
////    if (![departureStr isEqual:(id)[NSNull null]]) {
////        _departureDate = [dfmt dateFromString:departureStr];
////    }
////    if (![returnStr isEqual:(id)[NSNull null]]) {
////        _returnDate = [dfmt dateFromString:returnStr];
////    }
//
//
//
//    return YES;
//}
//
//- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
//
//
//    if (![_departureDate isEqual:(id)[NSNull null]]) {
//        dic[@"departure_date"] = [NSNumber numberWithDouble:[_departureDate timeIntervalSince1970]];
//    }
//    if (![_returnDate isEqual:(id)[NSNull null]]) {
//        dic[@"return_date"] = [NSNumber numberWithDouble:[_returnDate timeIntervalSince1970]];
//    }
//
//
//    return YES;
//}






/**
 EXAMPLE RESPONSE FROM GOOGLE:

 {
 "status": "OK",
 "predictions" : [
 {
 "description" : "Paris, France",
 "id" : "691b237b0322f28988f3ce03e321ff72a12167fd",
 "matched_substrings" : [
 {
 "length" : 5,
 "offset" : 0
 }
 ],
 "place_id" : "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
 "reference" : "CjQlAAAA_KB6EEceSTfkteSSF6U0pvumHCoLUboRcDlAH05N1pZJLmOQbYmboEi0SwXBSoI2EhAhj249tFDCVh4R-PXZkPK8GhTBmp_6_lWljaf1joVs1SH2ttB_tw",
 "terms" : [
 {
 "offset" : 0,
 "value" : "Paris"
 },
 {
 "offset" : 7,
 "value" : "France"
 }
 ],
 "types" : [ "locality", "political", "geocode" ]
 },
 {
 "description" : "Paris Avenue, Earlwood, New South Wales, Australia",
 "id" : "359a75f8beff14b1c94f3d42c2aabfac2afbabad",
 "matched_substrings" : [
 {
 "length" : 5,
 "offset" : 0
 }
 ],
 "place_id" : "ChIJrU3KAHG6EmsR5Uwfrk7azrI",
 "reference" : "CkQ2AAAARbzLE-tsSQPgwv8JKBaVtbjY48kInQo9tny0k07FOYb3Z_z_yDTFhQB_Ehpu-IKhvj8Msdb1rJlX7xMr9kfOVRIQVuL4tOtx9L7U8pC0Zx5bLBoUTFbw9R2lTn_EuBayhDvugt8T0Oo",
 "terms" : [
 {
 "offset" : 0,
 "value" : "Paris Avenue"
 },
 {
 "offset" : 14,
 "value" : "Earlwood"
 },
 {
 "offset" : 24,
 "value" : "New South Wales"
 },
 {
 "offset" : 41,
 "value" : "Australia"
 }
 ],
 "types" : [ "route", "geocode" ]
 },
 {
 "description" : "Paris Street, Carlton, New South Wales, Australia",
 "id" : "bee539812eeda477dad282bcc8310758fb31d64d",
 "matched_substrings" : [
 {
 "length" : 5,
 "offset" : 0
 }
 ],
 "place_id" : "ChIJCfeffMi5EmsRp7ykjcnb3VY",
 "reference" : "CkQ1AAAAAERlxMXkaNPLDxUJFLm4xkzX_h8I49HvGPvmtZjlYSVWp9yUhQSwfsdveHV0yhzYki3nguTBTVX2NzmJDukq9RIQNcoFTuz642b4LIzmLgcr5RoUrZhuNqnFHegHsAjtoUUjmhy4_rA",
 "terms" : [
 {
 "offset" : 0,
 "value" : "Paris Street"
 },
 {
 "offset" : 14,
 "value" : "Carlton"
 },
 {
 "offset" : 23,
 "value" : "New South Wales"
 },
 {
 "offset" : 40,
 "value" : "Australia"
 }
 ],
 "types" : [ "route", "geocode" ]
 },
 ...additional results ...

 */
+(STASDKMDestinationLocation*)initFromGoogleResult:(NSDictionary*)result {
    STASDKMDestinationLocation *loc = [[STASDKMDestinationLocation alloc] init];

    NSString *preferredName;
    NSDictionary *structured = [result objectForKey:@"structured_formatting"];
    if (structured) {
        preferredName = [structured objectForKey:@"main_text"];
    }
    if (!preferredName) {preferredName = [result objectForKey:@"description"];}

    loc.friendlyName = preferredName;
    loc._longName = [result objectForKey:@"description"];
    loc._googlePlaceId = [result objectForKey:@"place_id"];
    return loc;
}


@end
