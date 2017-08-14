//
//  STADataController.m
//  STACore
//
//  Created by Adam St. John on 2016-10-02.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//


#import "STASDKDataController.h"

#import "STASDKReachability.h"
#import <Realm/Realm.h>


@interface STASDKDataController()

@property RLMRealmConfiguration *realmConfig;

@end


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
    NSString *lString = NULL;
    NSLocale *locale = [NSLocale autoupdatingCurrentLocale];
    NSString *languageCode = [locale objectForKey:NSLocaleIdentifier];

    // languageCode might be en_GB, but on disk is en-GB
    languageCode = [languageCode stringByReplacingOccurrencesOfString:@"_" withString:@"-"];

    NSBundle *bundle = [self sdkBundle];
    NSString *path = [bundle pathForResource:languageCode ofType:@"lproj"];
    if (path != NULL) {
        lString = NSLocalizedStringWithDefaultValue(key, localizedTablename, [NSBundle bundleWithPath:path], kLocalizedStringNotFound, @"");
    }

    if (lString == NULL || [lString isEqualToString:kLocalizedStringNotFound]) {
        // fallback to english
        path = [bundle pathForResource:@"en" ofType:@"lproj"];
        lString = NSLocalizedStringWithDefaultValue(key, localizedTablename, [NSBundle bundleWithPath:path], kLocalizedStringNotFound, @"");
    }
    if ([lString isEqualToString:kLocalizedStringNotFound])
    {
        NSLog(@"No localized string for '%@' in '%@'", key, localizedTablename);
    }
    return lString;
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



- (void)setupRealm {
    self.realmConfig = [RLMRealmConfiguration defaultConfiguration];
    NSURL *folderPathURL = [[[self.realmConfig.fileURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"sitata"] URLByAppendingPathExtension:@"realm"];
    NSString *folderPath = folderPathURL.path;
    self.realmConfig.fileURL = folderPathURL;

    // Disable file protection for this directory - otherwise, we will not be able to access
    // the Realm database in the background on iOS 8 and above
    [[NSFileManager defaultManager] setAttributes:@{NSFileProtectionKey: NSFileProtectionCompleteUntilFirstUserAuthentication}
                                     ofItemAtPath:folderPath error:nil];
}

- (RLMRealm*)theRealm {
    return [RLMRealm realmWithConfiguration:self.realmConfig error:NULL];
}




@end




