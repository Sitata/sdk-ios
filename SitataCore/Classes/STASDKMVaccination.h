//
//  STASDKMVaccination.h
//  Pods
//
//  Created by Adam St. John on 2017-05-02.
//
//

#import <Realm/Realm.h>

@interface STASDKMVaccination : RLMObject

@property NSDate *updatedAt;
@property NSString *identifier;
@property NSString *name;
@property NSString *vaccinationDatum;


// Find stored vaccination by identifier
+(STASDKMVaccination*)findBy:(NSString *)vaccinationId;


@end

// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMVaccination *><STASDKMVaccination>
RLM_ARRAY_TYPE(STASDKMVaccination)
