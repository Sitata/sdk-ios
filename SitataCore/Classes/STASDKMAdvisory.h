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

@property (retain) NSDate *createdAt;
@property (retain) NSDate *updatedAt;
@property (retain) NSString *identifier;

@property (retain) NSString *headline;
@property (retain) NSString *body;
@property int status;
@property (retain) NSString *countryId;
@property (retain) NSString *countryDivisions;
@property (retain) NSString *countryRegions;
@property (retain) NSString *countryDivisionIds;
@property (retain) NSString *countryRegionIds;
@property (retain) NSString *topoJson;

@property BOOL _read;

// Find stored advisory by identifier
+(STASDKMAdvisory*)findBy:(NSString *)advisoryId;




// Returns an array of NSDictionary objects representing the associated provincial/state boundaries.
-(NSArray*)countryDivisionsArr;

// Returns an array of NSDictionary objects representing the associated municipal boundaries.
-(NSArray*)countryRegionsArr;

-(void)setRead;

// Return a dictionary representation of the topo_json
-(NSDictionary*)topoJsonObj;


@end

// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMAdvisory *><STASDKMAdvisory>
RLM_ARRAY_TYPE(STASDKMAdvisory)
