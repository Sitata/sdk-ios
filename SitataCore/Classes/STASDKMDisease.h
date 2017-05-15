//
//  STASDKMDisease.h
//  Pods
//
//  Created by Adam St. John on 2017-05-02.
//
//

#import <Realm/Realm.h>

@interface STASDKMDisease : RLMObject

@property (retain) NSDate *createdAt;
@property (retain) NSDate *updatedAt;
@property (retain) NSDate *deletedAt;
@property (retain) NSString *identifier;
@property (retain) NSString *commonName;
@property (retain) NSString *name;
@property (retain) NSString *fullName;
@property (retain) NSString *scientificName;
@property (retain) NSString *occursWhere;
@property (retain) NSString *diseaseDatum;



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
