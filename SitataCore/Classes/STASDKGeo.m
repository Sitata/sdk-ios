//
//  STASDKGeo.m
//  Pods
//
//  Created by Adam St. John on 2017-02-27.
//
//

#import "STASDKGeo.h"
#import "STASDKController.h"


@implementation STASDKGeo


NSString *const COLL_FEATURE = @"FeatureCollection";
NSString *const COLL_GEO = @"GeometryCollection";

NSString *const TYPE_POINT = @"Point";
NSString *const TYPE_MULTIPOINT = @"MultiPoint";
NSString *const TYPE_LINESTRING = @"LineString";
NSString *const TYPE_MULTILINESTRING = @"MultiLineString";
NSString *const TYPE_POLYGON = @"Polygon";
NSString *const TYPE_MULTIPOLYGON = @"MultiPolygon";



+ (NSDictionary*)feature:(NSDictionary*)topology obj:(NSDictionary*)obj {
    if ([[obj valueForKey:@"type"] isEqualToString:COLL_GEO]) {
        NSArray *allGeometries = [obj valueForKey:@"geometries"];

        NSMutableArray *mapped = [NSMutableArray arrayWithCapacity:[allGeometries count]];
        [allGeometries enumerateObjectsUsingBlock:^(id geometry, NSUInteger idx, BOOL *stop) {
            NSDictionary *dict = [self convertToGeoJson:topology obj:geometry];
            [mapped addObject:dict];
        }];
        return @{@"type": @"FeatureCollection", @"features": mapped};

    } else {
        return [self convertToGeoJson:topology obj:obj];
    }
}





+ (NSDictionary*)convertToGeoJson:(NSDictionary*)topology obj:(NSDictionary*)obj {
    NSString *identifier = [obj valueForKey:@"id"];
    NSDictionary *bbox = [obj valueForKey:@"bbox"];
    NSDictionary *properties = [obj valueForKey:@"properties"];
    if (properties == NULL) {
        properties = [[NSDictionary alloc] init];
    }
    NSDictionary *geometry = [self transformToGeoJson:topology obj:obj];

    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setValue:@"Feature" forKey:@"type"];
    [result setValue:properties forKey:@"properties"];
    [result setValue:geometry forKey:@"geometry"];

    if (identifier != NULL) {
        [result setValue:identifier forKey:@"id"];
    }
    if (bbox != NULL) {
        [result setValue:bbox forKey:@"bbox"];
    }


    return result;
}



+ (NSDictionary*)transformToGeoJson:(NSDictionary*)topology obj:(NSDictionary*)obj {

    return [self geometry:topology obj:obj];
}



+ (NSDictionary*)geometry:(NSDictionary*)topology obj:(NSDictionary*)obj {
    NSString *type = [obj valueForKey:@"type"];
    NSMutableArray *coordinates = [[NSMutableArray alloc] init];

    if ([type isEqualToString:COLL_GEO]) {
        NSArray *allGeometries = [obj valueForKey:@"geometries"];

        NSMutableArray *mapped = [NSMutableArray arrayWithCapacity:[allGeometries count]];
        [allGeometries enumerateObjectsUsingBlock:^(id geometry, NSUInteger idx, BOOL *stop) {
            NSDictionary *dict = [self geometry:topology obj:geometry];
            [mapped addObject:dict];
        }];
        return @{@"type": type, @"geometries": mapped};


    } else if ([type isEqualToString:TYPE_POINT]) {
        NSArray *oldCoords = [obj valueForKey:@"coordinates"];
        STASDKGeoTransformer *transformer = [[STASDKGeoTransformer alloc] init];
        if (oldCoords != NULL) {
            coordinates = [[transformer doTransform:topology point:oldCoords] mutableCopy];
        }


    } else if ([type isEqualToString:TYPE_MULTIPOINT]) {
        NSArray *oldCoords = [obj valueForKey:@"coordinates"];
        STASDKGeoTransformer *transformer = [[STASDKGeoTransformer alloc] init];

        NSMutableArray *mapped = [NSMutableArray arrayWithCapacity:[oldCoords count]];
        [oldCoords enumerateObjectsUsingBlock:^(id point, NSUInteger idx, BOOL *stop) {
            NSArray *newPoint = [transformer doTransform:topology point:point];
            [mapped addObject:[newPoint copy]];
        }];
        coordinates = mapped;

    } else if ([type isEqualToString:TYPE_LINESTRING]) {
        NSArray *arcs = [obj valueForKey:@"arcs"];
        coordinates = [self handleLine:topology arcs:arcs];

    } else if ([type isEqualToString:TYPE_MULTILINESTRING]) {
        NSArray *allArcs = [obj valueForKey:@"arcs"];

        NSMutableArray *mapped = [NSMutableArray arrayWithCapacity:[allArcs count]];
        [allArcs enumerateObjectsUsingBlock:^(id arcs, NSUInteger idx, BOOL *stop) {
            NSArray *arcCoords = [self handleLine:topology arcs:arcs];
            [mapped addObject:[arcCoords copy]];
        }];
        coordinates = mapped;

    } else if ([type isEqualToString:TYPE_POLYGON]) {
        NSArray *arcs = [obj valueForKey:@"arcs"];
        coordinates = [[self handlePolygon:topology arcs:arcs] mutableCopy];

    } else if ([type isEqualToString:TYPE_MULTIPOLYGON]) {
        NSArray *allArcs = [obj valueForKey:@"arcs"];

        NSMutableArray *mapped = [NSMutableArray arrayWithCapacity:[allArcs count]];
        [allArcs enumerateObjectsUsingBlock:^(id arcs, NSUInteger idx, BOOL *stop) {
            NSArray *arcCoords = [self handlePolygon:topology arcs:arcs];
            [mapped addObject:[arcCoords copy]];
        }];
        coordinates = mapped;

    } else {
        return NULL;
    }

    return [[NSDictionary alloc] initWithObjectsAndKeys:type,@"type",
            coordinates,@"coordinates",nil];

}






// the 'arcs' passed in here could be:
//   Line - [0]
+ (NSMutableArray*)handleLine:(NSDictionary*)topology arcs:(NSArray*)arcs {
    NSMutableArray *points = [[NSMutableArray alloc] init];

    for (int i=0; i < [arcs count]; i++) {
        int arcIndex = [arcs[i] intValue];
        [self handleArc:topology index:arcIndex points:points];
    }

    // [Adam] - I guess this is a safeguard for lines that could have less than 2 points...?
    if ([points count] < 2) {
        [points addObject:[[points objectAtIndex:0] copy]];
    }

    return points;
}





+ (void)handleArc:(NSDictionary*)topology index:(int)index points:(NSMutableArray*)points {
    NSArray *topologyArcs = [topology valueForKey:@"arcs"];

    // [Adam] - Not sure why original always removes last element with 'pop'
    // https://github.com/topojson/topojson-client/blob/master/src/feature.js#L25
    if ([points count] > 0) {
        [points removeLastObject];
    }

    int arcIndex = index;
    if (arcIndex < 0) {
        // This is what the tilde operator does on integers in javascript
        arcIndex = -1 * (arcIndex + 1);
    }
    NSArray *arc = [topologyArcs objectAtIndex:arcIndex];
    int arcCount = (int) [arc count];
    if (arc != NULL) {

        STASDKGeoTransformer *transformer = [[STASDKGeoTransformer alloc] init];
        for (int k=0; k < arcCount; k++) {
            NSArray *arcPoint = [arc objectAtIndex:k];
            NSArray *newPoint = [transformer doTransform:topology point:[arcPoint copy]];
            [points addObject:newPoint];
        }
    }

    if (index < 0) {
        [self reverse:points number:arcCount];
    }
}


// reverse the objects in an array according to the number given.
// i.e. if 2 is specified as 'number' for the given array of 3 objects,
//      it will swap the last two objects in the array
//      [0, 1, 2] => [0, 2, 1]
+ (void)reverse:(NSMutableArray*)array number:(int)number {
    int j = (int) [array count];
    int i = j - number;

    while (i < --j) {
        id t = array[i];
        array[i++] = array[j];
        array[j] = t;
    }
}



// the 'arcs' passed in here could be:
//   Polygon - [[0]]
+ (NSArray*)handlePolygon:(NSDictionary*)topology arcs:(NSArray*)arcs {

    NSMutableArray *mapped = [NSMutableArray arrayWithCapacity:[arcs count]];
    [arcs enumerateObjectsUsingBlock:^(id innerArc, NSUInteger idx, BOOL *stop) {
        NSArray *arcCoords = [self handleRing:topology arcs:innerArc];
        [mapped addObject:[arcCoords copy]];
    }];

    return mapped;
}

+ (NSArray*)handleRing:(NSDictionary*)topology arcs:(NSArray*)arcs {
    NSMutableArray *points = [self handleLine:topology arcs:arcs];
    // [Adam] - I guess this is protection if points is less than 4 in size...?
    while ([points count] < 4) {
        [points addObject:[[points objectAtIndex:0] copy]];
    }
    return points;
}










#pragma mark - mapView / polygon utilities


+ (MKMapRect)regionFromTopoBBox:(NSDictionary*)topology {

//    bbox =     (
//    "103.832892",
//    "8.563332000000001",
//    "106.79056",
//    "11.03086"
//    );
    NSArray *bbox = [topology objectForKey:@"bbox"];
    if (bbox == NULL || [bbox count] != 4) {
        // closest thing to returning an empty/null object
        return MKMapRectNull;
    }

    double lng1 = [[bbox objectAtIndex:0]doubleValue];
    double lat1 = [[bbox objectAtIndex:1]doubleValue];
    double lng2 = [[bbox objectAtIndex:2]doubleValue];
    double lat2 = [[bbox objectAtIndex:3]doubleValue];

//    MKCoordinateSpan span = MKCoordinateSpanMake(lat2 - lat1, lng2 - lng1);

//    double centerLng = (lng2 - lng1) / 2.0 + lng1;
//    double centerLat = (lat2 - lat1) / 2.0 + lat1;

    MKMapPoint point1 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(lat1, lng1));
    MKMapPoint point2 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(lat2, lng2));

    MKMapRect rect1 = MKMapRectMake(point1.x, point1.y, 0.1, 0.1);
    MKMapRect rect2 = MKMapRectMake(point2.x, point2.y, 0.1, 0.1);

    return MKMapRectUnion(rect1, rect2);

//    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(centerLat, centerLng);
//    return MKCoordinateRegionMake(coord, span);

}




// This function ensures that the proper topojson structure is present,
// converts it to geoJSON, and then processes the geoJSON.
+ (void)handleTopoJSON:(NSDictionary*)topoJSON mapView:(MKMapView*)mapView {
    if (topoJSON == NULL) { return; }

    NSDictionary *objects = [topoJSON objectForKey:@"objects"];
    if (objects != NULL) {
        NSDictionary *targetObj = [objects objectForKey:@"geometry"];
        if (targetObj != NULL) {
            NSDictionary *geoJSON = [STASDKGeo feature:topoJSON obj:targetObj];
            [self handleGeoJSON:geoJSON mapView:mapView];
        }
    }
}

// This function checks that the proper geoJSON structure is present,
// generates polygons from the geoJSON, and then adds them to the mapView.
+ (void)handleGeoJSON:(NSDictionary*)geoJSON mapView:(MKMapView*)mapView {
    if (geoJSON == NULL || [[geoJSON allKeys] count] < 1) {
        return;
    }

    NSDictionary *geometry = [geoJSON objectForKey:@"geometry"];
    if (geometry == NULL) {return;}

    NSArray *coords = [geometry objectForKey:@"coordinates"];
    if (coords == NULL || [coords count] < 1) {return;}

    NSString *type = [geometry objectForKey:@"type"];
    if ([type isEqualToString:TYPE_MULTIPOLYGON]) {

        for (NSArray *polyRow in coords) {
            MKPolygon *poly = [self mkPolygonFromGeoJSONCoords:polyRow];
            [mapView addOverlay:poly];
        }
    } else if ([type isEqualToString:TYPE_POLYGON]) {
        MKPolygon *poly = [self mkPolygonFromGeoJSONCoords:coords];
        [mapView addOverlay:poly];
    } else {
        NSLog(@"Unable to handle geometry type: '%@'", type);
    }
}


// This function takes an array of coordiante points and transforms them into
// a polygon (with or without 'holes').
+ (MKPolygon*)mkPolygonFromGeoJSONCoords:(NSArray*)geoJSONCoords {
    //MKPolygon holes[[geoJSONCoords count]-1]; // first row is solid portion, rest is holes
    NSMutableArray *holes = [[NSMutableArray alloc] init];

    // have to pull out some of the first row (polygon solid region) properties here
    MKPolygon *finalPolygon;
    NSArray *firstRow = [geoJSONCoords objectAtIndex:0];
    int polygonCount = (int) [firstRow count];
    CLLocationCoordinate2D polygonPoints[polygonCount];

    for (int i=0; i < [geoJSONCoords count]; i++) {
        NSArray *row = [geoJSONCoords objectAtIndex:i];

        if (i == 0) {
            // first row is solid polygon - 2D array of lng/lat points
            for (int j=0; j < [row count]; j++) {
                NSArray *p = row[j];
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([p[1] doubleValue], [p[0] doubleValue]);
                polygonPoints[j] = coord;
            }
        } else {
            CLLocationCoordinate2D points[[row count]];
            // other rows represent holes - 2D array of lng/lat points
            for (int j=0; j < [row count]; j++) {
                NSArray *p = row[j];
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([p[1] doubleValue], [p[0] doubleValue]);
                points[j] = coord;
            }
            MKPolygon *hole = [MKPolygon polygonWithCoordinates:points count:[row count]];
            [holes addObject:hole];
        }
    }

    finalPolygon = [MKPolygon polygonWithCoordinates:polygonPoints count:polygonCount interiorPolygons:holes];
    return finalPolygon;
}





@end





// A small object to perform transforms on topojson points.
// Keeps track of x and y point sums necessary to translate across series
// of points.
@implementation STASDKGeoTransformer


//https://github.com/topojson/topojson-client/blob/master/src/transform.js
//export default function(topology) {
//    if ((transform = topology.transform) == null) return identity;
//    var transform,
//    x0,
//    y0,
//    kx = transform.scale[0],
//    ky = transform.scale[1],
//    dx = transform.translate[0],
//    dy = transform.translate[1];
//    return function(point, i) {
//        if (!i) x0 = y0 = 0;
//        point[0] = (x0 += point[0]) * kx + dx;
//        point[1] = (y0 += point[1]) * ky + dy;
//        return point;
//    };
//}
- (NSArray*)doTransform:(NSDictionary*)topology point:(NSArray*)point {
    NSDictionary *transform = [topology valueForKey:@"transform"];

    // If transform is null...  then default values below should
    // return an array with the same values... so perhaps we don't need this 'identity'
    // transform which is used in transform.js and identity.js
    //    if (transform == NULL) {
    //        // TODO - DO IDENTITY TRANSFORM...returns???
    //        return @[];
    //    }

    NSArray *scale = [transform valueForKey:@"scale"];
    NSArray *translate = [transform valueForKey:@"translate"];
    double kx = 1.0;
    double ky = 1.0;
    double dx = 0.0;
    double dy = 0.0;

    // initial/previous point
    self.xVal += [point[0] doubleValue];
    self.yVal += [point[1] doubleValue];

    if (scale != NULL) {
        kx = [scale[0] doubleValue];// || 1.0; // eg. 1.961496149614927e-05
        ky = [scale[1] doubleValue];// || 1.0;
    }
    if (translate != NULL) {
        dx = [translate[0] doubleValue];// || 0.0; // eg. -58.53127
        dy = [translate[1] doubleValue];// || 0.0;
    }

    double x = self.xVal * kx + dx;
    double y = self.yVal * ky + dy;

    return @[[NSNumber numberWithDouble:x], [NSNumber numberWithDouble:y]];
}









@end
