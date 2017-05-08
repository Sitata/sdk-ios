//
//  STASDKApiCountry.h
//  Pods
//
//  Created by Adam St. John on 2016-12-21.
//
//


#import <Foundation/Foundation.h>

@class STASDKModelCountry;

@class STASDKMCountry;


@interface STASDKApiCountry : NSObject


// Request a country from the server by country id. 
+(void)getById:(NSString*)countryId onFinished:(void(^)(STASDKMCountry*, NSURLSessionDataTask*, NSError*))callback;


// Request all countries (in their short form)
+(void)getAllShortForm:(void(^)(NSArray<STASDKMCountry*>*, NSURLSessionDataTask*, NSError*))callback;


@end
