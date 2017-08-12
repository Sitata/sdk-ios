//
//  STASDKApiTraveller.m
//  Pods
//
//  Created by Adam St. John on 2017-07-18.
//
//

#import "STASDKApiTraveller.h"

#import <AFNetworking/AFNetworking.h>
#import <YYModel/YYModel.h>
#import "STASDKApiRoutes.h"
#import "STASDKApiUtils.h"

#import "STASDKMTraveller.h"

@implementation STASDKApiTraveller



// Request profile for current user / traveller
+(void)getProfile:(void(^)(STASDKMTraveller*, NSURLSessionDataTask*, NSError*))callback {
    NSString *url = [STASDKApiRoutes userProfile];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        // do success
        STASDKMTraveller *user = [STASDKMTraveller yy_modelWithJSON:responseObject];
        callback(user, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}

// Update profile for given traveller
+(void)update:(STASDKMTraveller*)user onFinished:(void(^)(STASDKMTraveller*, NSURLSessionDataTask*, NSError*))callback {
    NSString *url = [STASDKApiRoutes user:user.identifier];

    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    NSDictionary *userDict = [user yy_modelToJSONObject];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:userDict, @"user", nil];


    [manager PUT:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        STASDKMTraveller *user = [STASDKMTraveller yy_modelWithJSON:responseObject];
        callback(user, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}



@end
