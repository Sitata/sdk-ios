//
//  STASDKApiMisc.h
//  Pods
//
//  Created by Adam St. John on 2017-04-06.
//
//

#import <Foundation/Foundation.h>

@class STASDKMEvent;

@interface STASDKApiMisc : NSObject


// POST /users/device_push
+(void)sendDeviceToken:(NSDictionary*)deviceInfo onFinished:(void(^)(NSURLSessionDataTask*, NSError*))callback;

// POST /analytics/sdk_event
+(void)sendEvent:(STASDKMEvent*)event onFinished:(void(^)(NSURLSessionDataTask*, NSError*))callback;


// Given a string query and country code, will ask google for city suggestions and return an array of dictionaries representing
// the destination location
+(void)googleFetchCitySuggestions:(NSString*)query inCountry:(NSString*)countryCode onFinished:(void(^)(NSMutableArray*, NSURLSessionDataTask*, NSError*)) callback;


// Return a NSDictionary of google place id data
+(void)googleFetchPlace:(NSString*)placeId onFinished:(void(^)(NSDictionary*, NSURLSessionDataTask*, NSError*)) callback;




@end
