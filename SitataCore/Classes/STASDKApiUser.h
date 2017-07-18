//
//  STASDKApiUser.h
//  Pods
//
//  Created by Adam St. John on 2017-07-18.
//
//

@class STASDKMUser;

@interface STASDKApiUser : NSObject


// Request profile for current user
+(void)getUserProfile:(void(^)(STASDKMUser*, NSURLSessionDataTask*, NSError*))callback;

// Update profile for current user
+(void)updateUser:(STASDKMUser*)user onFinished:(void(^)(STASDKMUser*, NSURLSessionDataTask*, NSError*))callback;

@end
