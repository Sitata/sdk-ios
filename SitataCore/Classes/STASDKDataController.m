//
//  STADataController.m
//  STACore
//
//  Created by Adam St. John on 2016-10-02.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//


#import "STASDKDataController.h"

#import "STASDKReachability.h"


@implementation STASDKDataController

NSString * const kLocalizedStringNotFound = @"kLocalizedStringNotFound";
NSString * const localizedTablename = @"Translations";

#pragma mark Singleton
+ (id)sharedInstance {
    static STASDKDataController *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}



- (id)init
{
    self = [super init];
    if (!self) return nil;

    return self;
}




- (NSBundle*)sdkBundle {
    // This framework's bundle in the context of the parent app
    NSBundle *thisBundle = [NSBundle bundleForClass:[self classForCoder]];
    // Cocoapods creates a bundle inside this framework's bundle for our resources
    // as per the name defined in the podspec.
    NSString *bundlePath = [thisBundle pathForResource:@"SitataCore" ofType:@"bundle"];
    return [NSBundle bundleWithPath:bundlePath];
}


- (NSString*)localizedStringForKey:(NSString*)key {
    NSBundle *bundle = [self sdkBundle];

    NSString *str =  [bundle localizedStringForKey:key value:kLocalizedStringNotFound table:localizedTablename];
    // Not found?
    if ([str isEqualToString:kLocalizedStringNotFound])
    {
        NSLog(@"No localized string for '%@' in '%@'", key, localizedTablename);
    }

    return str;
}


- (bool)isConnected {
    STASDKReachability *reach = [STASDKReachability reachabilityForInternetConnection];
    bool reachable = [reach currentReachabilityStatus] != NotReachable;
    if (reachable) {
        NSLog(@"Device is connected to the internet");
    } else {
        NSLog(@"Device is not connected to the internet");
    }
    return reachable;
}





@end




