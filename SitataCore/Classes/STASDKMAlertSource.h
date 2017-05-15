//
//  STASDKMAlertSource.h
//  Pods
//
//  Created by Adam St. John on 2017-02-25.
//
//

@interface STASDKMAlertSource : NSObject



@property (retain) NSString *url;
@property (retain) NSString *host;


// Creates a new alert source model from the given nsdictionary representation
- (instancetype)initWith:(NSDictionary*)dict NS_DESIGNATED_INITIALIZER;





@end
