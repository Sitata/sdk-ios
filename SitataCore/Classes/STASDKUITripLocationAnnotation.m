//
//  STASDKUITripLocationAnnotation.m
//  Pods
//
//  Created by Adam St. John on 2017-07-11.
//
//

#import "STASDKUITripLocationAnnotation.h"

#import "STASDKMDestinationLocation.h"



@implementation STASDKUITripLocationAnnotation


- (id)initWith:(STASDKMDestinationLocation*)location {
    self.location = location;
    self.identifier = location.identifier;
    self.titleStr = location.friendlyName;
    self.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    return self;
}

- (NSString *)title {
    return self.titleStr;
}

- (NSString *)subtitle {
    return @"";
}

@end
