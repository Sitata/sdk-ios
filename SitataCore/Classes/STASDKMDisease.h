//
//  STASDKMDisease.h
//  Pods
//
//  Created by Adam St. John on 2017-05-02.
//
//

#import <Realm/Realm.h>

@interface STASDKMDisease : RLMObject

@property NSDate *createdAt;
@property NSDate *updatedAt;
@property NSDate *deletedAt;
@property NSString *identifier;
@property NSString *commonName;
@property NSString *name;
@property NSString *fullName;
@property NSString *scientificName;
@property NSString *occursWhere;
@property NSString *diseaseDatum;



// Find stored disease by identifier
+(STASDKMDisease*)findBy:(NSString *)diseaseId;


// Returns description from disease datum field.
-(NSString*)description;

// Returns transmission from disease datum field.
-(NSString*)transmission;

// Returns susceptibility from disease datum field.
-(NSString*)susceptibility;

// Returns symptoms from disease datum field.
-(NSString*)symptoms;

// Returns prevention from disease datum field.
-(NSString*)prevention;

// Returns treatment from disease datum field.
-(NSString*)treatment;







@end

// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMDisease *><STASDKMDisease>
RLM_ARRAY_TYPE(STASDKMDisease)
