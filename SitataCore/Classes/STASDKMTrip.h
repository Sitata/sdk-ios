//
//  STASDKMTrip.h
//  Pods
//
//  Created by Adam St. John on 2017-05-02.
//
//

#import <Realm/Realm.h>

#import "STASDKMDestination.h"
#import "STASDKMAlert.h"
#import "STASDKMAdvisory.h"
#import "STASDKMTripHealthComment.h"

@class STASDKMCountry;
@class STASDKMDestination;



@interface STASDKMTrip : RLMObject


@property (retain) NSDate *createdAt;
@property (retain) NSDate *updatedAt;
@property (retain) NSDate *deletedAt;
@property (retain) NSString *identifier;
@property (retain) NSString *name;
@property (retain) NSDate *start;
@property (retain) NSDate *finish;
@property BOOL muted;
@property BOOL read;
@property int tripType;
@property (retain) NSData *activities;
@property (retain) NSString *companyName;
@property (retain) NSString *companyId;
@property (retain) NSString *employeeName;
@property (retain) NSString *employeeId;
@property int pastAlertCount;


// related models
@property (retain) RLMArray<STASDKMDestination *><STASDKMDestination> *destinations;
@property (retain) RLMArray<STASDKMAlert *><STASDKMAlert> *alerts;
@property (retain) RLMArray<STASDKMAdvisory *><STASDKMAdvisory> *advisories;

@property (retain) RLMArray<STASDKMTripDiseaseComment *><STASDKMTripDiseaseComment> *tripDiseaseComments;
@property (retain) RLMArray<STASDKMTripVaccinationComment *><STASDKMTripVaccinationComment> *tripVaccinationComments;
@property (retain) RLMArray<STASDKMTripMedicationComment *><STASDKMTripMedicationComment> *tripMedicationComments;


// Return the current trip or next upcoming trip from the database.
+(STASDKMTrip*)currentTrip;

// Find stored trip by identifier
+(STASDKMTrip*)findBy:(NSString *)tripId;

// Destroy all previous data and related models and resave to database. 
-(void)resave:(NSError **)error;


// Returns true if the trip does not have any destination data.
-(bool)isEmpty;


// Returns a list of STASDKMDestination objects sorted by departure date
-(RLMResults<STASDKMDestination*>*)sortedDestinations;

// Returns the country that the user is currently in according to the
// trip itinerary or NULL.
-(STASDKMCountry*)currentCountry;

// Returns the destination that the user is currently in according to
// the trip itinerary or NULL;
-(STASDKMDestination*)currentDestination;

-(NSArray*)activitiesArr;



@end

// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMTrip *><STASDKMTrip>
RLM_ARRAY_TYPE(STASDKMTrip)
