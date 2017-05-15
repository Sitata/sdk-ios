//
//  STASDKMAlert.h
//  Pods
//
//  Created by Adam St. John on 2017-05-02.
//
//

#import <Realm/Realm.h>

@class STASDKMTrip;

@interface STASDKMAlert : RLMObject

@property (retain) NSDate *createdAt;
@property (retain) NSDate *updatedAt;
@property (retain) NSString *identifier;
@property (retain) NSString *headline;
@property (retain) NSString *body;
@property (retain) NSString *bodyAdvice;
@property (retain) NSString *category;
@property (retain) NSString *riskLevel;
@property (retain) NSString *alertLocations;
@property (retain) NSString *alertSources;
@property (retain) NSString *countryIds;
@property (retain) NSString *diseaseIds;
@property (retain) NSString *safetyIds;
@property (retain) NSString *countryDivisions;
@property (retain) NSString *countryRegions;
@property (retain) NSString *countryDivisionIds;
@property (retain) NSString *countryRegionIds;

@property BOOL _read;

// Find stored alert by identifier
+(STASDKMAlert*)findBy:(NSString *)alertId;



// Returns an array of STASDKModelAlertSource objects.
-(NSArray*)alertSourcesArr;

// Returns an array of STASDKModelAlertLocation objects.
-(NSArray*)alertLocationsArr;

// Returns an array of NSDictionary objects representing the associated provincial/state boundaries.
-(NSArray*)countryDivisionsArr;

// Returns an array of NSDictionary objects representing the associated municipal boundaries.
-(NSArray*)countryRegionsArr;

// Returns an array of NSString objects representing diseaseIds of the associated diseases.
-(NSArray*)diseaseIdsArr;

// Returns true if alert is disease type.
-(BOOL)isDiseaseType;

// If the read property is false, set to true and create a background job to
// inform server that alert was read.
-(void)setRead;


@end

// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMAlert *><STASDKMAlert>
RLM_ARRAY_TYPE(STASDKMAlert)
