//
//  STASDKMAddress.m
//  Pods
//
//  Created by Adam St. John on 2017-03-15.
//
//

#import "STASDKMAddress.h"

@implementation STASDKMAddress



- (instancetype)init {
    return [self initWith:@{}];
}

- (instancetype)initWith:(NSDictionary*)dict {
    self = [super init];
    if(self) {
        _address1 = [dict objectForKey:@"address1"];
        _address2 = [dict objectForKey:@"address2"];
        _city = [dict objectForKey:@"city"];
        _postalCode = [dict objectForKey:@"postal_code"];
        _province = [dict objectForKey:@"province"];
        _countryCode = [dict objectForKey:@"country_code"];
    }
    return self;
}

- (NSString*)addressString {
    NSMutableString *finalStr = [[NSMutableString alloc] initWithString:@""];

    if (self.address1.length) {
        [finalStr appendString:[NSString stringWithFormat:@"%@\r", self.address1]];
    }

    if (self.address2.length) {
        [finalStr appendString:[NSString stringWithFormat:@"%@\r", self.address2]];
    }

    if (self.city.length) {
        [finalStr appendString:[NSString stringWithFormat:@"%@", self.city]];
        if (self.province.length > 0 || self.postalCode.length > 0) {
            [finalStr appendString:@", "];
        }
    }

    if (self.province.length) {
        [finalStr appendString:[NSString stringWithFormat:@"%@", self.province]];
        if (self.postalCode.length > 0) {
            [finalStr appendString:@", "];
        }
    }

    if (self.postalCode.length) {
        [finalStr appendString:[NSString stringWithFormat:@"%@", self.postalCode]];
    }

    return [finalStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end

