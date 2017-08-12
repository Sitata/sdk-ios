//
//  STASDKMEvent.h
//  Pods
//
//  Created by Adam St. John on 2017-08-11.
//
//

#import <Realm/Realm.h>


@interface STASDKMEvent : RLMObject

@property (retain) NSString *identifier;
@property int eventType;
@property int name;
@property double latitude;
@property double longitude;
@property (retain) NSDate *occurredAt;


+(STASDKMEvent*)findBy:(NSString *)eventId;

// Save an event and attempt to send it to the server
// using a background job.
+(void)trackEvent:(int)eventType name:(int)name;


+(void)destroy:(NSString*)identifier;


@end
