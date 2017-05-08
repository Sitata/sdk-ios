//
//  STASDKApiCountry.m
//  Pods
//
//  Created by Adam St. John on 2016-12-21.
//
//

#import <AFNetworking/AFNetworking.h>
#import <YYModel/YYModel.h>

#import "STASDKApiCountry.h"
#import "STASDKApiRoutes.h"
#import "STASDKApiUtils.h"

#import <Realm/Realm.h>
#import "STASDKMCountry.h"


@implementation STASDKApiCountry


+(void)getById:(NSString*)countryId onFinished:(void(^)(STASDKMCountry*, NSURLSessionDataTask*, NSError*))callback {

    NSString *url = [STASDKApiRoutes country:countryId];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // do success
        STASDKMCountry *country = [STASDKMCountry yy_modelWithJSON:responseObject];
        callback(country, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}


+(void)getAllShortForm:(void(^)(NSArray<STASDKMCountry*>*, NSURLSessionDataTask*, NSError*))callback {
    NSString *url = [STASDKApiRoutes countriesShortForm];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // do success
        NSArray *countries = [NSArray yy_modelArrayWithClass:[STASDKMCountry class] json:responseObject];
        callback(countries, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}





@end
