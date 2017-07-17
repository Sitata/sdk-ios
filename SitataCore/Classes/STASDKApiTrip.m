//
//  STASDKApiTrip.m
//  STASDKApiTrip
//
//  Created by Adam St. John on 2016-10-02.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <YYModel/YYModel.h>

#import "STASDKApiUtils.h"
#import "STASDKApiTrip.h"
#import "STASDKMTrip.h"
#import "STASDKApiRoutes.h"



@implementation STASDKApiTrip



+(void)getTrips:(void(^)(NSArray<STASDKMTrip*>*, NSURLSessionDataTask*, NSError*))callback {
    NSString *url = [STASDKApiRoutes trips];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // do success
        NSArray *trips = [NSArray yy_modelArrayWithClass:[STASDKMTrip class] json:responseObject];
        callback(trips, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}

+(void)getCurrentTrip:(void(^)(STASDKMTrip*, NSURLSessionDataTask*, NSError*))callback {
    NSString *url = [STASDKApiRoutes currentTrip];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // do success
        STASDKMTrip *trip = [STASDKMTrip yy_modelWithJSON:responseObject];
        callback(trip, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}


+(void)getById:(NSString*)tripId onFinished:(void(^)(STASDKMTrip*, NSURLSessionDataTask*, NSError*))callback {
    NSString *url = [STASDKApiRoutes trip:tripId];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // do success
        STASDKMTrip *trip = [STASDKMTrip yy_modelWithJSON:responseObject];
        callback(trip, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}



// Create a new trip
+(void)createTrip:(STASDKMTrip*)trip onFinished:(void(^)(STASDKMTrip*, NSURLSessionTask*, NSError*))callback {
    NSString *url = [STASDKApiRoutes trips];

    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];
    NSDictionary *tripDict = [trip yy_modelToJSONObject];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tripDict, @"trip", nil];

    [manager POST:url parameters:params progress:NULL success:^(NSURLSessionDataTask *task, id responseObject) {
        // do success - server replies with new trip json
        STASDKMTrip *trip = [STASDKMTrip yy_modelWithJSON:responseObject];
        callback(trip, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];

}

// Update an existing trip
+(void)updateTrip:(STASDKMTrip*)trip onFinished:(void(^)(STASDKMTrip*, NSURLSessionTask*, NSError*))callback {
    NSString *url = [STASDKApiRoutes trip:trip.identifier];

    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];
    NSDictionary *tripDict = [trip yy_modelToJSONObject];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tripDict, @"trip", nil];

    [manager PATCH:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        // do success - server replies with full trip json, but it's not
        // entirely since client should have the trip's state anyway
        STASDKMTrip *trip = [STASDKMTrip yy_modelWithJSON:responseObject];
        callback(trip, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}



@end


