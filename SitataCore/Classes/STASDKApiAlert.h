//
//  STASDKApiAlert.h
//  STASDKApiAlert
//
//  Created by Adam St. John on 2017-01-10.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STASDKMAlert;
@class STASDKMAdvisory;


@interface STASDKApiAlert : NSObject

// Request all alerts for a trip.
+(void)getTripAlerts:(NSString*)tripId onFinished:(void(^)(NSArray<STASDKMAlert*>*, NSURLSessionDataTask*, NSError*))callback;

// Request all advisories for a trip.
+(void)getTripAdvisories:(NSString*)tripId onFinished:(void(^)(NSArray<STASDKMAdvisory*>*, NSURLSessionDataTask*, NSError*))callback;

// Mark a trip alert as having been read by the user.
+(void)markRead:(NSString*)alertId onFinished:(void(^)(NSURLSessionDataTask*, NSError*))callback;

// Fetch an alert along with any trip ids that are assocaited with it.
+(void)fromPush:(NSString*)alertId onFinished:(void(^)(STASDKMAlert*, NSArray*, NSURLSessionDataTask*, NSError*))callback;

@end


