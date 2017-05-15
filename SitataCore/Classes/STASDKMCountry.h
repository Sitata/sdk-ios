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

@property (retain) NSString *identifier;
@property (retain) NSDate *createdAt;
@property (retain) NSDate *updatedAt;
@property (retain) NSDate *deletedAt;
@property (retain) NSString *name;
@property (retain) NSString *countryCode;
@property (retain) NSString *countryCode3;
@property (retain) NSString *capital;
@property (retain) NSString *facts;
@property (retain) NSString *language;
@property (retain) NSString *currencyName;
@property (retain) NSString *currencyCode;
@property (retain) NSString *divisionName;
@property (retain) NSString *regionName;
@property int travelStatus;
@property (retain) NSString *secEmerNum;
@property (retain) NSString *secPersonal;
@property (retain) NSString *secExtViol;
@property (retain) NSString *secPolUnr;
@property (retain) NSString *secAreas;
@property (retain) NSString *flagMainURL;
@property (retain) NSString *flagListURL;
@property (retain) NSString *flagURL;
@property (retain) NSString *countryDatum;
@property (retain) NSString *emergNumbers;
@property (retain) NSString *topoJson;

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
