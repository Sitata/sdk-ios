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



@end
