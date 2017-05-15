//
//  STASDKMAddress.h
//  Pods
//
//  Created by Adam St. John on 2017-03-15.
//
//

#import <Foundation/Foundation.h>

@interface STASDKMAddress : NSObject


@property (retain) NSString *address1;
@property (retain) NSString *address2;
@property (retain) NSString *city;
@property (retain) NSString *postalCode;
@property (retain) NSString *province;
@property (retain) NSString *countryCode;



// Creates a new contact detail model from the given nsdictionary representation
- (instancetype)initWith:(NSDictionary*)dict NS_DESIGNATED_INITIALIZER;

// Returns a pre-formatted address string.
- (NSString*)addressString;


@end
