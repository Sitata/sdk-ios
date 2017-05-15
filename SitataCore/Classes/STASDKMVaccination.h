//
//  STASDKMVaccination.h
//  Pods
//
//  Created by Adam St. John on 2017-05-02.
//
//

#import <Realm/Realm.h>

@interface STASDKMVaccination : RLMObject

@property (retain) NSDate *updatedAt;
@property (retain) NSString *identifier;
@property (retain) NSString *name;
@property (retain) NSString *vaccinationDatum;


// Find stored vaccination by identifier
+(STASDKMVaccination*)findBy:(NSString *)vaccinationId;


@end

// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMVaccination *><STASDKMVaccination>
RLM_ARRAY_TYPE(STASDKMVaccination)
