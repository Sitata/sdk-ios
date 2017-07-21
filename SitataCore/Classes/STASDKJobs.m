//
//  STASDKJobs.m
//  Pods
//
//  Created by Adam St. John on 2016-12-21.
//
//

#import <Foundation/Foundation.h>


// Job Names
NSString *JOB_FULL_SYNC = @"full-sync";

NSString *JOB_SYNC_COUNTRY = @"sync-country";
NSString *JOB_SYNC_DISEASE = @"sync-disease";
NSString *JOB_SYNC_TRIP_ALERTS = @"sync-trip-alerts";
NSString *JOB_SYNC_TRIP_ADVISORIES = @"sync-trip-advisories";
NSString *JOB_SYNC_TRIP_HOSPITALS = @"sync-trip-hospitals";
NSString *JOB_SYNC_PUSH_TOKEN = @"sync-push-token";
NSString *JOB_ALERT_MARK_READ = @"alert-mark-read";
NSString *JOB_SYNC_ALERT = @"sync-alert";
NSString *JOB_CHANGE_TRIP_SETTINGS = @"change-trip-settings";
NSString *JOB_UPDATE_USER_SETTINGS = @"update-user-settings";



// Job Parameters
NSString *JOB_PARAM_CID = @"countryId";
NSString *JOB_PARAM_DID = @"diseaseId";
NSString *JOB_PARAM_TRIPID = @"tripId";
NSString *JOB_PARAM_PTOKEN = @"ptoken";
NSString *JOB_PARAM_AID = @"alertId";
NSString *JOB_PARAM_SETTINGS = @"settings";
