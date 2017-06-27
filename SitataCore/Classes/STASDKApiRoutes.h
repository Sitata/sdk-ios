//
//  STASDKApiRoutes.h
//  STASDKApiRoutes
//
//  Created by Adam St. John on 2016-10-02.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface STASDKApiRoutes : NSObject


// MARK: == TRIPS ==

// /trips
+(NSString*)trips;

// /trips/current_trip
+(NSString*)currentTrip;

// /trips/:id
+(NSString*)trip:(NSString*)tripId;



// MARK: == COUNTRIES ==

// /countries
+(NSString*)countries;

// /countries/short_list
+(NSString*)countriesShortForm;

// /countries/:id
+(NSString*)country:(NSString*)countryId;




// Mark: == DISEASES ==

// /diseases
+(NSString*)diseases;

// /diseases/:id
+(NSString*)disease:(NSString*)diseaseId;



// Mark: == VACCINATIONS ==

// /vaccinations
+(NSString*)vaccinations;

// /vaccinations/:id
+(NSString*)vaccination:(NSString*)vaccinationId;



// Mark: == MEDICATIONS ==

// /medications
+(NSString*)medications;

// /medications/:id
+(NSString*)medication:(NSString*)medicationId;


// Mark: == ALERTS ==

// /api/v1/trips/:trip_id/alerts
+(NSString*)tripAlerts:(NSString*)tripId;

// /api/v1/alerts/:alert_id/mark_read
+(NSString*)alertMarkRead:(NSString*)alertId;

// /api/v1/alerts/:alert_id/from_push
+(NSString*)alertFromPush:(NSString*)alertId;

// Mark: == ADVISORIES ==

// /api/v1/trips/:trip_id/advisories
+(NSString*)tripAdvisories:(NSString*)tripId;


// Mark: == HOSPITALS ==

// /api/v1/hospitals
+(NSString*)hospitals;

// /api/v1/trips/:trip_id/hospitals
+(NSString*)tripHospitals:(NSString*)tripId;

// /api/v1/countries/:country_id/hospitals
+(NSString*)countryHospitals:(NSString*)countryId;



// Mark: == MOBILE DEVICE / PUSH TOKEN ==

// /api/v1/users/add_device
+(NSString*)addDevice;

@end
