//
//  STASDKApiUtils.h
//  STASDK
//
//  Created by Adam St. John on 2016-10-04.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@class AFHTTPSessionManager;



@interface STASDKApiUtils : NSObject


// Format date times from rails server
+ (NSDateFormatter *)dateTimeFormatter;

// Format dates from rails server
+ (NSDateFormatter *)dateFormatter;


+ (NSString*)etagFromUrlTask:(NSURLSessionDataTask*)task;



// Return default session manager for http requests. Sets up the appropriate
// headers, content-type, authorization, etc.
+ (AFHTTPSessionManager *) defaultSessionManager;



@end
