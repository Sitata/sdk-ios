//
//  STASDKUIAlertViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-02-25.
//
//

#import "STASDKUIAlertViewController.h"
#import "STASDKMAlert.h"
#import "STASDKMAdvisory.h"
#import "STASDKMAlertSource.h"
#import "STASDKMAlertLocation.h"
#import "STASDKUIAlertPin.h"
#import "STASDKUI.h"
#import "STASDKMDisease.h"
#import "STASDKUIDiseaseDetailViewController.h"

#import "STASDKGeo.h"

#import "STASDKUIStylesheet.h"




@interface STASDKUIAlertViewController ()

@end

@implementation STASDKUIAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // setup view for alert or advisory
    if (self.alert != NULL) {
        [self setupForAlert];
    } else {
        [self setupForAdvisory];
    }


    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    self.view.backgroundColor = styles.alertPageBackgroundColor;
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupForAlert {
    [self.alert setRead];
    
    self.headlineLbl.text = self.alert.headline;
    self.bodyLbl.text = self.alert.body;
    self.dateLbl.text = [STASDKUI dateDisplayString:self.alert.updatedAt];
    self.adviceBodyLbl.text = self.alert.bodyAdvice;
    [self handleAlertSources];
    [self handleAlertType];
    [self handleMap];
}

- (void)setupForAdvisory {
    self.headlineLbl.text = self.advisory.headline;
    self.bodyLbl.text = self.advisory.body;
    self.dateLbl.text = [STASDKUI dateDisplayString:self.advisory.updatedAt];

    [self handleMap];

    // remove references and advice section and read more
    [self.readMoreBtn removeFromSuperview];
    [self.adviceBodyLbl removeFromSuperview];
    [self.adviceHeaderLbl removeFromSuperview];
    [self.referencesHeaderLbl removeFromSuperview];

    // Adjust constraints so that view container is at least as high as the screen height and at least 24 points from
    // bottom of body text
    [self.containerView.bottomAnchor constraintGreaterThanOrEqualToAnchor:self.bodyLbl.bottomAnchor constant:24.0].active = YES;
    [self.containerView.heightAnchor constraintGreaterThanOrEqualToAnchor:[self.containerView superview].heightAnchor constant:0.0].active = YES;
}

// Insert buttons for each alert source that allow user
// to click on link and go to website.
- (void)handleAlertSources {
    NSArray *sources = [self.alert alertSourcesArr];
    if ([sources count] > 0) {
        UIView *lastView = self.referencesHeaderLbl;
        for (STASDKMAlertSource *as in sources) {
            // returning the previously made label view so that we can
            // evenly space them apart from each other
            lastView = [self addAlertSourceToView:as lastView:lastView];
        }

        // set constraint of parent view so that scroll view allows for full page
        self.windowHeightStubConstraint.active = NO;
        UIView *container = [lastView superview];
        [container.bottomAnchor constraintEqualToAnchor:lastView.bottomAnchor constant:24.0].active = YES;
    } else {
        // remove reference section and adjust spacing to bottom of view
        [self.referencesHeaderLbl removeFromSuperview];
        UIView *container = [self.adviceBodyLbl superview];
        [container.bottomAnchor constraintEqualToAnchor:self.adviceBodyLbl.bottomAnchor constant:24.0].active = YES;

    }
}

// If alert is of disease type, then create button link
// to navigate to that disease
- (void)handleAlertType {
    if (self.alert == NULL || ![self.alert isDiseaseType]) {
        [self.readMoreBtn removeFromSuperview];
        [self.adviceHeaderLbl.topAnchor constraintEqualToAnchor:self.bodyLbl.bottomAnchor constant:24.0].active = YES;
    }

}



// add each alert source as a label to parent of the given view and return the newly created one
- (UIView*)addAlertSourceToView:(STASDKMAlertSource*)source lastView:(UIView*)lastView {

    UIView *parent = [lastView superview];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:source.url forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(openAlertSource:) forControlEvents:UIControlEventTouchUpInside];
    [[btn titleLabel] setTextAlignment:NSTextAlignmentLeft];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [btn sizeToFit];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [parent addSubview:btn];

    UILayoutGuide *margins = parent.layoutMarginsGuide;
    [btn.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor].active = YES;
    [btn.trailingAnchor constraintEqualToAnchor:margins.trailingAnchor].active = YES;
    [btn.topAnchor constraintEqualToAnchor:lastView.bottomAnchor constant:5.0].active = YES;

    return btn;
}

- (void)openAlertSource:(UIButton*)sender {
    NSString *urlStr = [sender currentTitle];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlStr]];
}



#pragma mark - MapKit Handlers

- (void) handleMap {
    self.mapView.delegate = self;

    MKMapRect bounds = MKMapRectNull;

    // ADVISORIES CURRENTLY DO NOT HAVE MAP PIN LOCATIONS
    NSArray *alertLocations = [[NSArray alloc] init];
    if (self.alert != NULL) {
        alertLocations = [self.alert alertLocationsArr];

        for (STASDKMAlertLocation *loc in alertLocations) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(loc.latitude, loc.longitude);
            STASDKUIAlertPin *annotation = [[STASDKUIAlertPin alloc] initWithType:self.alert.category coordinate:coord];
            [self.mapView addAnnotation:annotation];

            // for bounds
            MKMapPoint point = MKMapPointForCoordinate(coord);
            MKMapRect pointRect = MKMapRectMake(point.x, point.y, 0.1, 0.1);
            if (MKMapRectIsNull(bounds)) {
                bounds = pointRect;
            } else {
                bounds = MKMapRectUnion(bounds, pointRect);
            }
        }
    }

    BOOL hasPolygons = NO;
    // country division polygons
    NSArray *divisionsArr;
    if (self.alert != NULL) {
        divisionsArr = [self.alert countryDivisionsArr];
    } else {
        divisionsArr = [self.advisory countryDivisionsArr];
    }

    for (NSDictionary *division in divisionsArr) {
        NSDictionary *topoJSON = [division objectForKey:@"topo_json"];
        [STASDKGeo handleTopoJSON:topoJSON mapView:self.mapView];
        hasPolygons = YES;

        // expanding total bounds by polygon bounds
        MKMapRect divisionBounds = [STASDKGeo regionFromTopoBBox:topoJSON];
        if (MKMapRectIsNull(bounds)) {
            bounds = divisionBounds;
        } else {
            bounds = MKMapRectUnion(bounds, divisionBounds);
        }
    }


    // country region polygons
    NSArray *regionsArr;
    if (self.alert != NULL) {
        regionsArr = [self.alert countryRegionsArr];
    } else {
        regionsArr = [self.advisory countryRegionsArr];
    }

    for (NSDictionary *region in regionsArr) {
        NSDictionary *topoJSON = [region objectForKey:@"topo_json"];
        [STASDKGeo handleTopoJSON:topoJSON mapView:self.mapView];
        hasPolygons = YES;

        // expanding total bounds by polygon bounds
        MKMapRect regionBounds = [STASDKGeo regionFromTopoBBox:topoJSON];
        if (MKMapRectIsNull(bounds)) {
            bounds = regionBounds;
        } else {
            bounds = MKMapRectUnion(bounds, regionBounds);
        }
    }

    // set map to bounds
    [self.mapView setVisibleMapRect:bounds edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
    if (self.alert != NULL && alertLocations.count <= 1 && !hasPolygons) {
        // if there's one map pin or less and no polygons, then zoom out to country-wide
        MKCoordinateSpan span = MKCoordinateSpanMake(5.0, 5.0);
        MKCoordinateRegion region = MKCoordinateRegionMake([self.mapView centerCoordinate], span);
        [self.mapView setRegion:region];
    }

}








- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    NSString *identifier = @"mapPin";

    if ([annotation isKindOfClass:[STASDKUIAlertPin class]]) {
        MKPinAnnotationView *pin = (MKPinAnnotationView*) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];

        if (pin == nil) {
            pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            pin.pinTintColor = [UIColor redColor];
            pin.animatesDrop = NO;
            pin.enabled = YES;
            pin.canShowCallout = NO;
//            pin.image = [UIImage imageNamed:@"whatever"];
        } else {
            pin.annotation = annotation;
        }
        return pin;
    }

    return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:MKPolygon.class]) {
        MKPolygonRenderer *polygonView = [[MKPolygonRenderer alloc] initWithOverlay:overlay];

        polygonView.strokeColor = [UIColor colorWithRed:247/255.0 green:4/255.0 blue:33/255.0 alpha:0.5];
        polygonView.fillColor = [UIColor colorWithRed:196/255.0 green:0.0 blue:23/255.0 alpha:0.4];
        polygonView.lineWidth = 3.0;

        return polygonView;
    }


    return nil;
}


#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {


    if ([segue.identifier isEqualToString:@"showDisease"]) {
        if ([self.alert isDiseaseType]) {
            // find disease - usually only one disease per alert
            NSString *diseaseId = [[self.alert diseaseIdsArr] firstObject];
            STASDKMDisease *disease = [STASDKMDisease findBy:diseaseId];
            STASDKUIDiseaseDetailViewController *vc = [segue destinationViewController];
            vc.disease = disease;
        }
    }
}




@end
