//
//  STASDKApiUser.m
//  Pods
//
//  Created by Adam St. John on 2017-07-18.
//
//

#import "STASDKApiUser.h"

#import <AFNetworking/AFNetworking.h>
#import <YYModel/YYModel.h>
#import "STASDKApiRoutes.h"
#import "STASDKApiUtils.h"

#import "STASDKMUser.h"

@implementation STASDKApiUser



// Request profile for current user
+(void)getUserProfile:(void(^)(STASDKMUser*, NSURLSessionDataTask*, NSError*))callback {
    NSString *url = [STASDKApiRoutes userProfile];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        // do success
        STASDKMUser *user = [STASDKMUser yy_modelWithJSON:responseObject];
        callback(user, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}

// Update profile for current user
+(void)updateUser:(STASDKMUser*)user onFinished:(void(^)(STASDKMUser*, NSURLSessionDataTask*, NSError*))callback {
    NSString *url = [STASDKApiRoutes user:user.identifier];

    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:user, @"user", nil];

    [manager PUT:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        STASDKMUser *user = [STASDKMUser yy_modelWithJSON:responseObject];
        callback(user, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}



@end
