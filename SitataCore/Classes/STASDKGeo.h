//
//  STASDKGeo.h
//  Pods
//
//  Created by Adam St. John on 2017-02-27.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>



@interface STASDKGeo : NSObject



// Convert a given topoJSON dictionary and object to GeoJson
+ (NSDictionary*)feature:(NSDictionary*)topology obj:(NSDictionary*)obj;

// Returns a MKMapRect object given a topojson dictionary
+ (MKMapRect)regionFromTopoBBox:(NSDictionary*)topology;

// Given a topoJSON dictionary and mapView, will perform necessary
// conversions and add polygons to the map
+ (void)handleTopoJSON:(NSDictionary*)topoJSON mapView:(MKMapView*)mapView;






@end










@interface STASDKGeoTransformer : NSObject


@property double xVal;
@property double yVal;

- (NSArray*)doTransform:(NSDictionary*)topology point:(NSArray*)point;


@end
