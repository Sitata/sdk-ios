//
//  STASDKUI.h
//  Pods
//
//  Created by Adam St. John on 2017-02-05.
//
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(int, HealthType) {
    Vaccinations = 0,
    Medications = 1,
    Diseases = 2
};
typedef NS_ENUM(int, InfoType) {
    Alerts = 0,
    Advisories = 1
};

@interface STASDKUI : NSObject


// Present the Alerts user interface for the current trip
+ (void)showAlerts;

// Present the Alerts user interface for the given tripId
+ (void)showAlerts:(NSString*_Nonnull)tripId;


// Present the Advisories user interface
+ (void)showAdvisories;

// Present the Advisories user interface for the given tripId
+ (void)showAdvisories:(NSString*_Nonnull)tripId;


// Present the Trip Vaccinations user interface for the current trip
+ (void)showTripVaccinations;
// Present the Trip Vaccinations user interfac for the given tripId
+ (void)showTripVaccinations:(NSString*_Nonnull)tripId;

// Present the Trip Medications user interface for the current trip
+ (void)showTripMedications;
// Present the Trip Medications user interface for the given tripId
+ (void)showTripMedications:(NSString*_Nonnull)tripId;

// Present the Trip Diseases user interface for the current trip
+ (void)showTripDiseases;
// Present the Trip Diseases user interface for the given tripId
+ (void)showTripDiseases:(NSString*_Nonnull)tripId;

// Present the Trip Safety user interface for the current trip
+ (void)showTripSafety;
// Present the Trip Safety user interface for the given tripId
+ (void)showTripSafety:(NSString*_Nonnull)tripId;

// Present the Trip Hospitals user interface for the current trip
+ (void)showTripHospitals;
// Present the Trip Hospitals user interface for the given tripId
+ (void)showTripHospitals:(NSString*_Nonnull)tripId;

// Peresent the Emergency Numbers user interface
+ (void)showEmergencyNumbers;

// Show the Alert user interface for the given Alert identifier
+ (void)showAlert:(NSString*_Nonnull)alertId;

// Show trip builder UI for a given trip id. Pass null as tripId to allow for
// a new trip to be created.
+ (void)showTripBuilder:(NSString*_Nullable)tripId;

// Returns a date string in format YYYY-MM-DD
+ (NSString *_Nonnull)dateDisplayString:(NSDate*_Nonnull)date;

// Returns a date string in the format Jan 28
+ (NSString *_Nonnull)dateDisplayShort:(NSDate*_Nonnull)date;

// Returns a formatted distance string (using unit settings) for display. Will
// convert given distance value (meters required) when necessary.
+ (NSString *_Nonnull)formattedDistance:(double)distanceMeters;




@end
