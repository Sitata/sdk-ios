//
//  STASDKMDestination.h
//  Pods
//
//  Created by Adam St. John on 2017-05-03.
//
//

#import <Realm/Realm.h>

@interface STASDKMDestination : RLMObject

@property NSString *identifier;
@property NSDate *departureDate;
@property NSDate *returnDate;
@property NSString *countryId;
@property NSString *countryCode;




@end

// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMDestination *><STASDKMDestination>
RLM_ARRAY_TYPE(STASDKMDestination)
