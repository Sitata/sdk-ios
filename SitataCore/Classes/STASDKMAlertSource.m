//
//  STASDKMAlertSource.m
//  Pods
//
//  Created by Adam St. John on 2017-02-25.
//
//

#import <Foundation/Foundation.h>
#import "STASDKMAlertSource.h"

@implementation STASDKMAlertSource

- (instancetype)init {
    return [self initWith:@{}];
}

- (instancetype)initWith:(NSDictionary*)dict {
    self = [super init];
    if(self) {
        _url = [dict objectForKey:@"url"];
        _host = [dict objectForKey:@"host"];
    }
    return self;
}




@end
