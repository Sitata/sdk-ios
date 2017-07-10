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











+(void)googleFetchCitySuggestions:(NSString*)query inCountry:(NSString*)countryCode onFinished:(void(^)(NSMutableArray*, NSURLSessionDataTask*, NSError*)) callback  {

    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSString *url = [STASDKApiRoutes googleSearchForCityNamed:query inCountry:countryCode];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        NSDictionary *jsonResults = (NSDictionary*) responseObject;
        NSArray *predictions = [jsonResults objectForKey:@"predictions"];
        NSString *status = [jsonResults objectForKey:@"status"];

        if ([status isEqualToString:@"OK"] || [status isEqualToString:@"ZERO_RESULTS"] ) {
            for (NSDictionary *pred in predictions) {
                STASDKMDestinationLocation *loc = [STASDKMDestinationLocation initFromGoogleResult:pred];
                [results addObject:loc];
            }
            callback(results, task, nil);
        } else {
            NSString *errorMessage = [jsonResults objectForKey:@"error_message"];
            NSString *fullMessage = [NSString stringWithFormat:@"Error querying google: '%@'", errorMessage];
            NSDictionary *details = [[NSDictionary alloc] initWithObjectsAndKeys:fullMessage, NSLocalizedDescriptionKey, nil];
            NSError *error = [NSError errorWithDomain:@"sitata.com" code:99 userInfo:details];
            callback(nil, task, error);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}


@end
