//
//  STASDKAppDelegate.h
//  SitataCore
//
//  Created by Adam St. John on 12/20/2016.
//  Copyright (c) 2016 Adam St. John. All rights reserved.
//

@import UIKit;

#import <UserNotifications/UserNotifications.h>

@interface STASDKAppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
