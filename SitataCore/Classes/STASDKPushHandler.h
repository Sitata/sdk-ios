//
//  STASDKPushHandler.h
//  Pods
//
//  Created by Adam St. John on 2017-06-19.
//
//

#import <Foundation/Foundation.h>

@interface STASDKPushHandler : NSObject


// Handle the incoming push notification message
+ (void) handlePushData:(NSDictionary*)userInfo onFinished:(void (^)(UIBackgroundFetchResult))callback;

// Launch the correct user interface screen for the incoming push notification message
+ (void) launchPushScreen:(NSDictionary*)userInfo;


@end
