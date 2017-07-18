//
//  STASDKMUser.h
//  Pods
//
//  Created by Adam St. John on 2017-07-18.
//
//


#import <Realm/Realm.h>

@class STASDKMUserSettings;

@interface STASDKMUser : RLMObject

@property (retain) NSString *identifier;
@property (retain) NSString *firstName;
@property (retain) NSString *lastName;
@property (retain) NSString *email;
@property (retain) NSString *homeCountry;
@property (retain) NSString *language;

// DO not save authentication token - let parent company do that outside of our SDK
//@property (retain) NSString *authentication_token;

// Related models
@property STASDKMUserSettings *settings;


// Find stored user by identifier
+(STASDKMUser*)findBy:(NSString *)userId;


// Destroy all previous data and related models and resave to database.
-(void)resave:(NSError **)error;

// Removes associated models from the database. THIS MUST BE CALLED WITHIN A REALM TRANSACTION.
-(void)removeAssociated:(RLMRealm*)realm;


@end



// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMUser *><STASDKMUser>
RLM_ARRAY_TYPE(STASDKMUser)
