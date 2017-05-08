//
//  STASDKApiUtils.m
//  STASDK
//
//  Created by Adam St. John on 2016-10-04.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//

#import "STASDKApiUtils.h"

#import <AFNetworking/AFNetworking.h>
#import "STASDKController.h"




@implementation STASDKApiUtils



// Format date times from rails server
+ (NSDateFormatter *)dateTimeFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    return dateFormatter;
}

// Format dates from rails server
+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return dateFormatter;
}

+ (NSString*)etagFromUrlTask:(NSURLSessionDataTask*)task {
    NSHTTPURLResponse *response = ((NSHTTPURLResponse *)[task response]);
    NSDictionary *headers = [response allHeaderFields];
    return [headers objectForKey:@"Etag"];
}



+ (AFHTTPSessionManager *) defaultSessionManager {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[STASDKController sharedInstance].apiToken forHTTPHeaderField:@"Authorization"];

    return manager;
}



@end
