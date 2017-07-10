//
//  STASDKMDestinationLocation.h
//  Pods
//
//  Created by Adam St. John on 2017-07-10.
//
//

#import <Realm/Realm.h>

@interface STASDKMDestinationLocation : RLMObject

@property (retain) NSString *identifier;
@property (retain) NSString *friendlyName;
@property double latitude;
@property double longitude;

@property NSString *_googlePlaceId;



// Create a new STASDKMDestinationLocation from a google result json object
+(STASDKMDestinationLocation*)initFromGoogleResult:(NSDictionary*)result;


@end

// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMDestinationLocation *><STASDKMDestinationLocation>
RLM_ARRAY_TYPE(STASDKMDestinationLocation)
