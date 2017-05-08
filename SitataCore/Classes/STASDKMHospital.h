//
//  STASDKMHospital.h
//  Pods
//
//  Created by Adam St. John on 2017-05-02.
//
//

#import <Realm/Realm.h>

@class STASDKMAddress;

@interface STASDKMHospital : RLMObject


@property NSDate *createdAt;
@property NSDate *updatedAt;
@property NSDate *verifiedAt;
@property NSString *identifier;

@property NSString *name;
@property NSString *description;
@property NSString *countryId;
@property BOOL starred;
@property BOOL emergency;
@property BOOL accrJci;
@property BOOL verified;

@property NSData *location; // array type stored as NSData
@property NSString *address;
@property NSString *contactDetails;



+(RLMResults<STASDKMHospital*>*)findForCountry:(NSString*)countryId;


-(double)longitude;
-(double)latitude;


// Returns true if hospital has been accredited.
-(BOOL)isAccredited;

// Returns an array of STASDKModelContactDetail objects representing the contact details of
// the hospital
-(NSArray*)contactDetailsArray;

// Returns a STASDKMOdelAddress object representing the address for the hospital
-(STASDKMAddress*)addressObj;



@end

// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMHospital *><STASDKMHospital>
RLM_ARRAY_TYPE(STASDKMHospital)
