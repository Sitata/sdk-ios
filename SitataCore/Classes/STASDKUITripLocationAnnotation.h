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

// Keeping a reference to the location is important so we can
// easily remove annotations when needed
@property (nonatomic, assign) STASDKMDestinationLocation *location;
@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, copy) NSString *identifier; // necessary because location not referenced properly

- (id)initWith:(STASDKMDestinationLocation*)location;

- (NSString *)title;

@end
