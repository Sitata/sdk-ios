//
//  STASDKMDestination.h
//  Pods
//
//  Created by Adam St. John on 2017-05-03.
//
//

#import <Realm/Realm.h>

#import "STASDKMDestinationLocation.h"


@interface STASDKMDestination : RLMObject

@property (retain) NSString *identifier;
@property (retain) NSDate *departureDate;
@property (retain) NSDate *returnDate;
@property (retain) NSString *countryId;
@property (retain) NSString *countryCode;



//related models
@property (retain) RLMArray<STASDKMDestinationLocation *><STASDKMDestinationLocation> *destinationLocations;


// Removes associated models from the database. THIS MUST BE CALLED WITHIN A REALM TRANSACTION.
-(void)removeAssociated:(RLMRealm*)realm;


@end

// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMDestination *><STASDKMDestination>
RLM_ARRAY_TYPE(STASDKMDestination)
