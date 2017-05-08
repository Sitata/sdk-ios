//
//  STASDKModelAlertLocation.h
//  Pods
//
//  Created by Adam St. John on 2017-02-25.
//
//

@interface STASDKMAlertLocation : NSObject



@property double latitude;
@property double longitude;

// Creates a new alert location model from the given nsdictionary representation
- (instancetype)initWith:(NSDictionary*)dict NS_DESIGNATED_INITIALIZER;






@end
