//
//  STASDKMCountry.h
//  Pods
//
//  Created by Adam St. John on 2017-05-02.
//
//

#import <Realm/Realm.h>
#import "STASDKMHospital.h"


@interface STASDKMCountry : RLMObject

@property NSString *identifier;
@property NSDate *createdAt;
@property NSDate *updatedAt;
@property NSDate *deletedAt;
@property NSString *name;
@property NSString *countryCode;
@property NSString *countryCode3;
@property NSString *capital;
@property NSString *facts;
@property NSString *language;
@property NSString *currencyName;
@property NSString *currencyCode;
@property NSString *divisionName;
@property NSString *regionName;
@property int travelStatus;
@property NSString *secEmerNum;
@property NSString *secPersonal;
@property NSString *secExtViol;
@property NSString *secPolUnr;
@property NSString *secAreas;
@property NSString *flagMainURL;
@property NSString *flagListURL;
@property NSString *flagURL;
@property NSString *countryDatum;
@property NSString *emergNumbers;
@property NSString *topoJson;

// relationships
@property RLMArray<STASDKMHospital *><STASDKMHospital> *hospitals;

//
//// Related Models
//@property (nonatomic, copy) NSSet *hospitals;
//


// Find stored country by identifier
+(STASDKMCountry*)findBy:(NSString *)countryId;

// Find stored country by country code
+(STASDKMCountry*)findByCountryCode:(NSString *)countryCode;

// Returns an array of all countries saved to local database sorted alphabetically.
+(RLMArray<STASDKMCountry*>*)allCountries;



// Returns an array of STASDKDBModelContactDetail obejcts representing the emergency
// numbers for the country.
-(NSArray*)emergNumbersArray;



@end

// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMCountry *><STASDKMCountry>
RLM_ARRAY_TYPE(STASDKMCountry)
