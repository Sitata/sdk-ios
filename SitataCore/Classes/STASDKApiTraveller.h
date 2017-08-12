//
//  STASDKApiTraveller.h
//  Pods
//
//  Created by Adam St. John on 2017-07-18.
//
//

@class STASDKMTraveller;

@interface STASDKApiTraveller : NSObject


// Request profile for current user / traveller
+(void)getProfile:(void(^)(STASDKMTraveller*, NSURLSessionDataTask*, NSError*))callback;

// Update profile for given traveller
+(void)update:(STASDKMTraveller*)user onFinished:(void(^)(STASDKMTraveller*, NSURLSessionDataTask*, NSError*))callback;

@end
