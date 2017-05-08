//
//  STASDKApiDisease.h
//  Pods
//
//  Created by Adam St. John on 2017-01-06.
//
//


#import <Foundation/Foundation.h>

@class STASDKMDisease;
@class STASDKMVaccination;
@class STASDKMMedication;


@interface STASDKApiDisease : NSObject

// Request full list of diseases from the server
+(void)getAll:(void(^)(NSArray<STASDKMDisease*>*, NSURLSessionDataTask*, NSError*))callback;

// Request a disease from the server by disease id. 
+(void)getById:(NSString*)diseaseId onFinished:(void(^)(STASDKMDisease*, NSURLSessionDataTask*, NSError*))callback;


@end


@interface STASDKApiVaccination : NSObject

// Request full list of vaccinations from the server
+(void)getAll:(void(^)(NSArray<STASDKMVaccination*>*, NSURLSessionDataTask*, NSError*))callback;

// Request a vaccination from the server by id.
+(void)getById:(NSString*)vaccinationId onFinished:(void(^)(STASDKMVaccination*, NSURLSessionDataTask*, NSError*))callback;


@end

@interface STASDKApiMedication : NSObject

// Request full list of medications from the server
+(void)getAll:(void(^)(NSArray<STASDKMMedication*>*, NSURLSessionDataTask*, NSError*))callback;

// Request a medication from the server by id.
+(void)getById:(NSString*)medicationId onFinished:(void(^)(STASDKMMedication*, NSURLSessionDataTask*, NSError*))callback;


@end
