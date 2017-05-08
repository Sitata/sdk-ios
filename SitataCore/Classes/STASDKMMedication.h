//
//  STASDKMMedication.h
//  Pods
//
//  Created by Adam St. John on 2017-05-02.
//
//

#import <Realm/Realm.h>

@interface STASDKMMedication : RLMObject

@property NSDate *updatedAt;
@property NSString *identifier;
@property NSString *name;
@property NSString *medicationDatum;

// Find stored medication by identifier
+(STASDKMMedication*)findBy:(NSString *)medicationId;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMMedication *><STASDKMMedication>
RLM_ARRAY_TYPE(STASDKMMedication)
