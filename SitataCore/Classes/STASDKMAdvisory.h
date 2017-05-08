//
//  STASDKMAdvisory.h
//  Pods
//
//  Created by Adam St. John on 2017-05-03.
//
//

#import <Realm/Realm.h>

@class STASDKMTrip;

@interface STASDKMAdvisory : RLMObject

@property NSDate *createdAt;
@property NSDate *updatedAt;
@property NSString *identifier;

@property NSString *headline;
@property NSString *body;
@property int status;
@property NSString *countryId;
@property NSString *countryDivisions;
@property NSString *countryRegions;
@property NSString *countryDivisionIds;
@property NSString *countryRegionIds;



// Find stored advisory by identifier
+(STASDKMAdvisory*)findBy:(NSString *)advisoryId;




// Returns an array of NSDictionary objects representing the associated provincial/state boundaries.
-(NSArray*)countryDivisionsArr;

// Returns an array of NSDictionary objects representing the associated municipal boundaries.
-(NSArray*)countryRegionsArr;


@end

// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMAdvisory *><STASDKMAdvisory>
RLM_ARRAY_TYPE(STASDKMAdvisory)
