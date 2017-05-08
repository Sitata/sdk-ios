//
//  STASDKModelAlertLocation.m
//  Pods
//
//  Created by Adam St. John on 2017-02-25.
//
//

#import <Foundation/Foundation.h>
#import "STASDKMAlertLocation.h"

@implementation STASDKMAlertLocation

- (instancetype)init {
    return [self initWith:@{}];
}

- (instancetype)initWith:(NSDictionary*)dict {
    self = [super init];
    if(self) {
        
        NSArray *location = [dict objectForKey:@"location"];
        _longitude = [[location objectAtIndex:0] doubleValue];
        _latitude = [[location objectAtIndex:1] doubleValue];

    }
    return self;
}




@end
