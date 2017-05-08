//
//  STASDKApiCountry.m
//  Pods
//
//  Created by Adam St. John on 2017-01-06.
//
//

#import <AFNetworking/AFNetworking.h>
#import <YYModel/YYModel.h>

#import "STASDKApiHealth.h"
#import "STASDKApiRoutes.h"
#import "STASDKApiUtils.h"
#import "STASDKMDisease.h"
#import "STASDKMVaccination.h"
#import "STASDKMMedication.h"





@implementation STASDKApiDisease

+(void)getAll:(void(^)(NSArray<STASDKMDisease*>*, NSURLSessionDataTask*, NSError*))callback {
    NSString *url = [STASDKApiRoutes diseases];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // do success
        NSArray *diseases = [NSArray yy_modelArrayWithClass:[STASDKMDisease class] json:responseObject];
        callback(diseases, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}


+(void)getById:(NSString*)diseaseId onFinished:(void(^)(STASDKMDisease*, NSURLSessionDataTask*, NSError*))callback {

    NSString *url = [STASDKApiRoutes disease:diseaseId];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // do success
        STASDKMDisease *disease = [STASDKMDisease yy_modelWithJSON:responseObject];
        callback(disease, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}

@end


@implementation STASDKApiVaccination

+(void)getAll:(void(^)(NSArray<STASDKMVaccination*>*, NSURLSessionDataTask*, NSError*))callback {
    NSString *url = [STASDKApiRoutes vaccinations];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // do success
        NSArray *vaccinations = [NSArray yy_modelArrayWithClass:[STASDKMVaccination class] json:responseObject];
        callback(vaccinations, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}


+(void)getById:(NSString*)vaccinationId onFinished:(void(^)(STASDKMVaccination*, NSURLSessionDataTask*, NSError*))callback {

    NSString *url = [STASDKApiRoutes vaccination:vaccinationId];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // do success
        STASDKMVaccination *vaccination = [STASDKMVaccination yy_modelWithJSON:responseObject];
        callback(vaccination, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}

@end



@implementation STASDKApiMedication


+(void)getAll:(void(^)(NSArray<STASDKMMedication*>*, NSURLSessionDataTask*, NSError*))callback {
    NSString *url = [STASDKApiRoutes medications];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // do success
        NSArray *medications = [NSArray yy_modelArrayWithClass:[STASDKMMedication class] json:responseObject];
        callback(medications, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}

+(void)getById:(NSString*)medicationId onFinished:(void(^)(STASDKMMedication*, NSURLSessionDataTask*, NSError*))callback {

    NSString *url = [STASDKApiRoutes medication:medicationId];
    AFHTTPSessionManager *manager = [STASDKApiUtils defaultSessionManager];

    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // do success
        STASDKMMedication *medication = [STASDKMMedication yy_modelWithJSON:responseObject];
        callback(medication, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // do failure
        NSLog(@"Error: %@", error);
        callback(nil, task, error);
    }];
}

@end
