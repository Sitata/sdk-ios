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


// Present the Alerts user interface
+ (void)showAlerts;

// Present the Advisories user interface
+ (void)showAdvisories;


// Present the Trip Vaccinations user interface
+ (void)showTripVaccinations;

// Present the Trip Medications user interface
+ (void)showTripMedications;

// Present the Trip Diseases user interface
+ (void)showTripDiseases;

// Present the Trip Safety user interface
+ (void)showTripSafety;

// Present the Trip Hospitals user interface
+ (void)showTripHospitals;

// Peresent the Emergency Numbers user interface
+ (void)showEmergencyNumbers;

// Show the Alert user interface for the given Alert identifier
+ (void)showAlert:(NSString*_Nonnull)alertId;

// Show trip builder UI for a given trip id. Pass null as tripId to allow for
// a new trip to be created.
+ (void)showTripBuilder:(NSString*_Nullable)tripId;

// Returns a date string in format YYYY-MM-DD
+ (NSString *_Nonnull)dateDisplayString:(NSDate*_Nonnull)date;

// Returns a formatted distance string (using unit settings) for display. Will
// convert given distance value (meters required) when necessary.
+ (NSString *_Nonnull)formattedDistance:(double)distanceMeters;




@end
