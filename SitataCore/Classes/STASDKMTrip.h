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


@property NSDate *createdAt;
@property NSDate *updatedAt;
@property NSDate *deletedAt;
@property NSString *identifier;
@property NSString *name;
@property NSDate *start;
@property NSDate *finish;
@property BOOL muted;
@property BOOL read;
@property int tripType;
@property NSData *activities;
@property NSString *companyName;
@property NSString *companyId;
@property NSString *employeeName;
@property NSString *employeeId;
@property int pastAlertCount;


// related models
@property RLMArray<STASDKMDestination *><STASDKMDestination> *destinations;
@property RLMArray<STASDKMAlert *><STASDKMAlert> *alerts;
@property RLMArray<STASDKMAdvisory *><STASDKMAdvisory> *advisories;

@property RLMArray<STASDKMTripDiseaseComment *><STASDKMTripDiseaseComment> *tripDiseaseComments;
@property RLMArray<STASDKMTripVaccinationComment *><STASDKMTripVaccinationComment> *tripVaccinationComments;
@property RLMArray<STASDKMTripMedicationComment *><STASDKMTripMedicationComment> *tripMedicationComments;


// Return the current trip or next upcoming trip from the database.
+(STASDKMTrip*)currentTrip;

// Find stored trip by identifier
+(STASDKMTrip*)findBy:(NSString *)tripId;

// Destroy all previous data and related models and resave to database. 
-(void)resave:(NSError **)error;



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
