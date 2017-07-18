//
//  STASDKMUserSettings.h
//  Pods
//
//  Created by Adam St. John on 2017-07-18.
//
//

#import <Realm/Realm.h>

@interface STASDKMUserSettings : RLMObject

@property (retain) NSString *identifier;

@property BOOL sendTripAlertEmail;
@property BOOL sendAllGoodEmail;
@property BOOL sendTripAlertPush;
@property BOOL sendAllGoodPush;

//@property BOOL checkInWithLocation;


@end



// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMUserSettings *><STASDKMUserSettings>
RLM_ARRAY_TYPE(STASDKMUserSettings)
