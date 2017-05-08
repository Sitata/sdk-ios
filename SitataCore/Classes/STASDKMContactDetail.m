//
//  STASDKMContactDetail.m
//  Pods
//
//  Created by Adam St. John on 2017-03-15.
//
//

#import "STASDKMContactDetail.h"

@implementation STASDKMContactDetail


- (instancetype)init {
    return [self initWith:@{}];
}

- (instancetype)initWith:(NSDictionary*)dict {
    self = [super init];
    if(self) {
        _typ = [[dict objectForKey:@"typ"] intValue];
        _val = [dict objectForKey:@"val"];
        _note = [dict objectForKey:@"note"];
        if (_note == NULL) {
            _note = @"";
        }
        _order = [[dict objectForKey:@"order"] intValue];
    }
    return self;
}


@end
