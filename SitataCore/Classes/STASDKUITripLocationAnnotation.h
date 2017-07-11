//
//  STASDKUITripLocationAnnotation.h
//  Pods
//
//  Created by Adam St. John on 2017-07-11.
//
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

@class STASDKMDestinationLocation;

@interface STASDKUITripLocationAnnotation : NSObject <MKAnnotation>


@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

// Keeping a reference to the location is important so we can switch
// easily remove annotations when needed
@property (nonatomic, assign) STASDKMDestinationLocation *location;
@property (nonatomic, assign) NSString *titleStr;
@property (nonatomic, assign) NSString *identifier;

- (id)initWith:(STASDKMDestinationLocation*)location;

- (NSString *)title;

@end
