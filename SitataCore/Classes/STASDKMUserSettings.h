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


// Relationships
@property (readonly) RLMLinkingObjects *users;




// Find stored settings by identifier
+(STASDKMUserSettings*)findBy:(NSString *)settingsId;


// save the settings locally and create a background job
// to post the changes to the server as soon as possible.
-(void)backgroundUpdate:(NSError **)error;


@end



// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMUserSettings *><STASDKMUserSettings>
RLM_ARRAY_TYPE(STASDKMUserSettings)
