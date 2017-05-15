//
//  STASDKMMedication.h
//  Pods
//
//  Created by Adam St. John on 2017-05-02.
//
//

#import <Realm/Realm.h>

@interface STASDKMMedication : RLMObject

@property (retain) NSDate *updatedAt;
@property (retain) NSString *identifier;
@property (retain) NSString *name;
@property (retain) NSString *medicationDatum;

// Find stored medication by identifier
+(STASDKMMedication*)findBy:(NSString *)medicationId;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMMedication *><STASDKMMedication>
RLM_ARRAY_TYPE(STASDKMMedication)
