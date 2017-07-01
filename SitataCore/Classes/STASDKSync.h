//
//  STASDKSync.h
//  STASDK
//
//  Created by Adam St. John on 2016-12-19.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//



#import <Foundation/Foundation.h>



FOUNDATION_EXPORT NSNotificationName const NotifyAlertSynced;
FOUNDATION_EXPORT NSString *const NotifyKeyAlertId;




@interface STASDKSync : NSObject


// Sync everything necessary and save things locally
+ (void)fullSync:(void (^)(NSError*))syncCompleted;

// Sync all trips for the local user.
+ (void)syncAllTrips:(void (^)(NSError*))callback;

// Sync the current trip and all associated objects
// and save them locally to the database.
+ (void)syncCurrentTrip:(void (^)(NSError*))callback;

// Sync a country for the given countryID and save locally.
+ (void) syncCountry:(NSString*)countryId callback:(void (^)(NSError*))callback;

// Sync full list of diseases
+ (void) syncDiseases:(void (^)(NSError*))callback;

// Sync a disease for the given diseaseId and save locally.
+ (void) syncDisease:(NSString*)diseaseId callback:(void (^)(NSError*))callback;

// Sync full list of medications
+ (void) syncMedications:(void (^)(NSError*))callback;

// Sync full list of vaccinations
+ (void) syncVaccinations:(void (^)(NSError*))callback;

// Sync list of trip alerts for a trip
+ (void) syncTripAlerts:(NSString*)tripId callback:(void (^)(NSError*))callback;

// Sync list of trip advisories for a trip
+ (void) syncTripAdvisories:(NSString*)tripId callback:(void (^)(NSError*))callback;

// Sync list of trip hospitals for a trip
+ (void) syncTripHospitals:(NSString*)tripId callback:(void (^)(NSError*))callback;

// Sync to server that alert was marked as read
+ (void) syncAlertMarkRead:(NSString*)alertId callback:(void (^)(NSError*))callback;

// Sync push notification token
+ (void) syncPushToken:(NSString*)token callback:(void (^)(NSError*))callback;

// Sync singular alert (usually from push notification)
+ (void) syncAlert:(NSString*)alertId callback:(void (^)(NSError*))callback;



@end
