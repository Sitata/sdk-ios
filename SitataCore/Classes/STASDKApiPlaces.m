//
//  STASDKApiAlert.m
//  STASDKApiAlert
//
//  Created by Adam St. John on 2017-01-10.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <AFNetworking/AFNetworking.h>
#import <YYModel/YYModel.h>

#import "STASDKApiUtils.h"
#import "STASDKApiPlaces.h"
#import "STASDKMHospital.h"
#import "STASDKApiRoutes.h"




@implementation STASDKApiPlaces


+(void)getHospitalsForTrip:(NSString*)tripId onFinished:(void(^)(NSArray<STASDKMHospital*>*, NSURLSessionDataTask*, NSError*))callback {

    NSString *url = [STASDKApiRoutes tripHospitals:tripId];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        // do success
        NSArray *hospitals = [NSArray yy_modelArrayWithClass:[STASDKMHospital class] json:responseObject];

        callback(hospitals, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}

+(void)getHospitalsForCountry:(NSString*)countryId onFinished:(void(^)(NSArray<STASDKMHospital*>*, NSURLSessionDataTask*, NSError*))callback {

    NSString *url = [STASDKApiRoutes countryHospitals:countryId];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        // do success
        NSArray *hospitals = [NSArray yy_modelArrayWithClass:[STASDKMHospital class] json:responseObject];

        callback(hospitals, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}


+(void)getHospitalsNearby:(double)latitude longitude:(double)longitude onFinished:(void(^)(NSArray<STASDKMHospital*>*, NSURLSessionDataTask*, NSError*))callback {

    NSString *url = [NSString stringWithFormat:@"%@/?longitude=%f&latitude=%f", [STASDKApiRoutes hospitals], latitude, longitude];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        // do success
        NSArray *hospitals = [NSArray yy_modelArrayWithClass:[STASDKMHospital class] json:responseObject];

        callback(hospitals, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];

}






@end


