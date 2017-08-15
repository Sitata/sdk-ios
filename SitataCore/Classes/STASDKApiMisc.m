//
//  STASDKApiMisc.m
//  Pods
//
//  Created by Adam St. John on 2017-04-06.
//
//

#import "STASDKApiMisc.h"

#import <AFNetworking/AFNetworking.h>
#import "STASDKApiUtils.h"
#import "STASDKApiRoutes.h"
#import "STASDKMDestinationLocation.h"
#import "STASDKMEvent.h"

#import <YYModel/YYModel.h>



@implementation STASDKApiMisc


// POST /users/device_push
+(void)sendDeviceToken:(NSDictionary*)deviceInfo onFinished:(void(^)(NSURLSessionDataTask*, NSError*)) callback {
    NSString *url = [STASDKApiRoutes addDevice];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:deviceInfo, @"device", nil];

    [manager POST:url parameters:params constructingBodyWithBlock:nil progress:nil success:^(NSURLSessionDataTask *task, id  responseObject) {
        // do success - server replies with empty array so no need to parse anything
        callback(task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(task, error);
    }];
}


// POST /analytics/sdk_event
+(void)sendEvent:(STASDKMEvent*)event onFinished:(void(^)(NSURLSessionDataTask*, NSError*))callback {
    NSString *url = [STASDKApiRoutes sendEvent];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    NSDictionary *eventParams = [event yy_modelToJSONObject];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:eventParams, @"sdk_event", nil];

    [manager POST:url parameters:params constructingBodyWithBlock:nil progress:nil success:^(NSURLSessionDataTask *task, id  responseObject) {
        // do success - server replies with empty array so no need to parse anything
        callback(task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(task, error);
    }];
}




@end
