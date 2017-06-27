//
//  STASDKApiAlert.m
//  STASDKApiAlert
//
//  Created by Adam St. John on 2017-01-10.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <YYModel/YYModel.h>

#import "STASDKApiUtils.h"
#import "STASDKApiAlert.h"
#import "STASDKMAlert.h"
#import "STASDKApiRoutes.h"
#import "STASDKMAdvisory.h"



@implementation STASDKApiAlert


+(void)getTripAlerts:(NSString*)tripId onFinished:(void(^)(NSArray<STASDKMAlert*>*, NSURLSessionDataTask*, NSError*))callback {

    NSString *url = [STASDKApiRoutes tripAlerts:tripId];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // alerts are currently stored like:
        //  {trip_alerts: [], past_alerts: []}
        // past_alerts are simply an array of alerts, but
        // trip_alerts are not. trip_alerts are an array of trip_alert objects which contain an array of "alerts"
        // in addition to other meta-data

        NSDictionary *alertsResponse = (NSDictionary *)responseObject;
        NSMutableArray *allAlerts = [[NSMutableArray alloc] init];
        NSMutableArray *tripAlerts = [alertsResponse mutableArrayValueForKey:@"trip_alerts"];
        NSMutableArray *pastAlerts = [alertsResponse mutableArrayValueForKey:@"past_alerts"];

        for (NSDictionary* tripAlert in tripAlerts) {
            NSDictionary *alertJson = [tripAlert objectForKey:@"alert"];
            STASDKMAlert *alert = [STASDKMAlert yy_modelWithJSON:alertJson];
            [allAlerts addObject:alert];
        }

        [allAlerts addObjectsFromArray:pastAlerts];

        // do success
        NSArray *alerts = [NSArray yy_modelArrayWithClass:[STASDKMAlert class] json:allAlerts];

        callback(alerts, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}



+(void)getTripAdvisories:(NSString*)tripId onFinished:(void(^)(NSArray<STASDKMAdvisory*>*, NSURLSessionDataTask*, NSError*))callback {

    NSString *url = [STASDKApiRoutes tripAdvisories:tripId];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        // do success
        NSArray *advisories = [NSArray yy_modelArrayWithClass:[STASDKMAdvisory class] json:responseObject];

        callback(advisories, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}

+(void)markRead:(NSString*)alertId onFinished:(void(^)(NSURLSessionDataTask*, NSError*))callback {
    NSString *url = [STASDKApiRoutes alertMarkRead:alertId];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    [manager PUT:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        callback(task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(task, error);
    }];
}


+(void)fromPush:(NSString*)alertId onFinished:(void(^)(STASDKMAlert*, NSArray*, NSURLSessionDataTask*, NSError*))callback {

    NSString *url = [STASDKApiRoutes alertFromPush:alertId];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        // do success
        NSDictionary *alertsResponse = (NSDictionary *)responseObject;
        NSDictionary *alertJson = [alertsResponse objectForKey:@"alert"];
        NSMutableArray *tripIds = [alertsResponse objectForKey:@"trip_ids"];
        STASDKMAlert *alert = [STASDKMAlert yy_modelWithJSON:alertJson];

        callback(alert, tripIds, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, nil, task, error);
    }];
}



@end


