//
//  STADataController.h
//  STACore
//
//  Created by Adam St. John on 2016-10-02.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLMRealm;


@interface STASDKDataController : NSObject



/**
 Shared instance singleton

 @return Shared instance
 */
+ (STASDKDataController*)sharedInstance;


// Setup the database. Called on sdk start.
- (void)setupRealm;

// Returns the bundle for this sdk
- (NSBundle*)sdkBundle;

// Returns a translated string for a given key
- (NSString*)localizedStringForKey:(NSString*)key;

- (bool)isConnected;

- (RLMRealm*)theRealm;


@end





