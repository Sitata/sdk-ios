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

// Find trips with a finish date greater than or equal to today, sorted by start date ascending
+(RLMResults<STASDKMTrip *>*)currentAndFutureTrips;

// Find stored trip by identifier
+(STASDKMTrip*)findBy:(NSString *)tripId;

// Destroy all previous data and related models and resave to database. 
-(void)resave:(NSError **)error;

// Removes associated models from the database. THIS MUST BE CALLED WITHIN A REALM TRANSACTION.
-(void)removeAssociated:(RLMRealm*)realm;


// Returns true if the trip does not have any destination data.
-(bool)isEmpty;

// Remove the trip and associated objects
-(void)destroy;

// Returns a list of STASDKMDestination objects sorted by departure date
-(RLMResults<STASDKMDestination*>*)sortedDestinations;

// Returns the country that the user is currently in according to the
// trip itinerary or NULL.
-(STASDKMCountry*)currentCountry;

// Returns the destination that the user is currently in according to
// the trip itinerary or NULL;
-(STASDKMDestination*)currentDestination;

-(NSArray*)activitiesArr;


// Returns true if the given activity is included in the trip
-(bool)hasActivity:(int)activity;

// Adds an activity to the trip
-(void)addActivity:(int)activity;

// Removes an activity from the trip
-(void)removeActivity:(int)activity;





@end

// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMTrip *><STASDKMTrip>
RLM_ARRAY_TYPE(STASDKMTrip)
