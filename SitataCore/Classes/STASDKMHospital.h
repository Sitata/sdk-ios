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


@property (retain) NSDate *createdAt;
@property (retain) NSDate *updatedAt;
@property (retain) NSDate *verifiedAt;
@property (retain) NSString *identifier;

@property (retain) NSString *name;
@property (retain) NSString *description;
@property (retain) NSString *countryId;
@property BOOL starred;
@property BOOL emergency;
@property BOOL accrJci;
@property BOOL verified;

@property (retain) NSData *location; // array type stored as NSData
@property (retain) NSString *address;
@property (retain) NSString *contactDetails;



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
