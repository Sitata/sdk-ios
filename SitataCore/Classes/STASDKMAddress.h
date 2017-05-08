//
//  STASDKMAddress.h
//  Pods
//
//  Created by Adam St. John on 2017-03-15.
//
//

#import <Foundation/Foundation.h>

@interface STASDKMAddress : NSObject


@property NSString *address1;
@property NSString *address2;
@property NSString *city;
@property NSString *postalCode;
@property NSString *province;
@property NSString *countryCode;



// Creates a new contact detail model from the given nsdictionary representation
- (instancetype)initWith:(NSDictionary*)dict NS_DESIGNATED_INITIALIZER;

// Returns a pre-formatted address string.
- (NSString*)addressString;


@end
