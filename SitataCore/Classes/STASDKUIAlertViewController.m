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
#import "STASDKMCountry.h"
#import "STASDKUIAlertPin.h"
#import "STASDKUI.h"
#import "STASDKMDisease.h"
#import "STASDKUIDiseaseDetailViewController.h"

#import "STASDKGeo.h"

#import "STASDKUIStylesheet.h"
#import "STASDKDataController.h"
#import "STASDKUIModalLoadingWindow.h"
#import "STASDKSync.h"

#import "STASDKDefines.h"
#import "STASDKMEvent.h"

#import <Contacts/Contacts.h>




@interface STASDKUIAlertViewController ()

@property STASDKUIModalLoadingWindow *loadingWin;
@property (weak, nonatomic) IBOutlet UILabel *attributionLbl;

@end

@implementation STASDKUIAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // setup view for alert or advisory or syncing
    if (self.alert == NULL && self.advisory == NULL) {

        // No alert or advisory so we display a loading window
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDismissLoadingWindow:) name:NotifyAlertSynced object:NULL];

        // must still be syncing the alert and/or advisory
        self.loadingWin = [[STASDKUIModalLoadingWindow alloc] initWithFrame:self.view.bounds];
        [self.loadingWin setSubTitleText:[STASDKDataController.sharedInstance localizedStringForKey:@"STILL_DOWNLOADING"]];
        [self.view addSubview:self.loadingWin];

    } else if (self.alert != NULL) {
        [self setupForAlert];
    } else {
        [self setupForAdvisory];
    }
    [self addAttribution];


    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    self.view.backgroundColor = styles.alertPageBackgroundColor;
}

-(void)viewDidAppear:(BOOL)animated {
    [STASDKMEvent trackEvent:TrackPageOpen name:[self eventPageType]];
}
-(void)viewDidDisappear:(BOOL)animated {
    [STASDKMEvent trackEvent:TrackPageClose name:[self eventPageType]];
}
-(int)eventPageType {
    if (self.alert != NULL) {
        return EventAlertDetails;
    } else {
        return EventAdvisoryDetails;
    }
}

- (void)viewDidLayoutSubviews {

    // adjust attribution label constraints to force label to bottom of view
    if (self.containerView.frame.size.height < self.view.frame.size.height) {
        [self.attributionLbl.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-5.0].active = YES;
    }
}

- (void)handleDismissLoadingWindow:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *alertId = [userInfo valueForKey:NotifyKeyAlertId];
    if (self.loadingWin != NULL && [self.alertId isEqualToString:alertId]) {
        // match so we can dismiss loading window
        dispatch_async(dispatch_get_main_queue(), ^{
            // must do in main thread

            // Currently, we only do this for alerts and so we
            // simply setup for the alert.
            STASDKMAlert *alert = [STASDKMAlert findBy:alertId];
            if (alert != NULL) {
                self.alert = alert;
                [self setupForAlert];
                [self.loadingWin hide];
            }
        });
    }
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

        // only display the first 5 sources
        int count = (int)sources.count;
        if (count > 5) { count = 5; }
        for (int i=0; i < count; i++) {
            STASDKMAlertSource *as = [sources objectAtIndex:i];
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

- (void)addAttribution {
    NSString *attribution = [[STASDKDataController sharedInstance] localizedStringForKey:@"POWERED_BY"];
    NSRange range = [attribution rangeOfString:@"Sitata"];


    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:attribution];
    [str addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
    UIColor *sitBlue = [UIColor colorWithRed:93/255.0 green:144/255.0 blue:192/255.0 alpha:1.0];
    [str addAttribute:NSForegroundColorAttributeName value:sitBlue range:range];
    self.attributionLbl.textColor = [UIColor lightGrayColor];
    self.attributionLbl.font = [UIFont systemFontOfSize:12];
    self.attributionLbl.attributedText = str;
    self.attributionLbl.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(onSitata)];
    [self.attributionLbl addGestureRecognizer:tapGesture];
}

- (void)onSitata {
    NSURL *url = [NSURL URLWithString:@"https://www.sitata.com"];
    [[UIApplication sharedApplication] openURL:url];
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
    btn.titleLabel.font = [UIFont systemFontOfSize:12.0];
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

    // full country polygons
    NSArray *countriesArr;
    if (self.alert != NULL) {
        countriesArr = [self.alert countriesArr];
    } // ADVISORIES currently do not have full country polygons
    for (NSDictionary *country in countriesArr) {
        NSDictionary *topoJSON = [country objectForKey:@"topo_json"];
        if (![topoJSON  isEqual:[NSNull null]]) {
            // countries object will always be there, but topo_json may be null
            // in the case that the alert is not a full country alert.

            [STASDKGeo handleTopoJSON:topoJSON mapView:self.mapView];
            hasPolygons = YES;

            // expanding total bounds by polygon bounds
            MKMapRect countryBounds = [STASDKGeo regionFromTopoBBox:topoJSON];
            if (MKMapRectIsNull(bounds)) {
                bounds = countryBounds;
            } else {
                bounds = MKMapRectUnion(bounds, countryBounds);
            }
        }
    }

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

    // Custom topojson
    NSDictionary *topoObj;
    if (self.alert != NULL) {
        topoObj = [self.alert topoJsonObj];
    } else {
        topoObj = [self.advisory topoJsonObj];
    }
    if (topoObj) {
        [STASDKGeo handleTopoJSON:topoObj mapView:self.mapView];
        hasPolygons = YES;
        // expanding total bounds by polygon bounds
        MKMapRect regionBounds = [STASDKGeo regionFromTopoBBox:topoObj];
        if (MKMapRectIsNull(bounds)) {
            bounds = regionBounds;
        } else {
            bounds = MKMapRectUnion(bounds, regionBounds);
        }
    }


    // set map to bounds
    [self.mapView setVisibleMapRect:bounds edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
    if (self.alert != NULL && alertLocations.count <= 1 && !hasPolygons) {
        [self zoomWayOut];
    }

    if (self.advisory != NULL && !hasPolygons) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];

        STASDKMCountry *country = [STASDKMCountry findBy:self.advisory.countryId];
        if (country != NULL) {
            NSDictionary *addDict = @{CNPostalAddressISOCountryCodeKey : country.countryCode};
            [geocoder geocodeAddressDictionary:addDict completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
                if (placemarks.count >= 1) {
                    CLPlacemark *place = [placemarks objectAtIndex:0];
                    CLLocation *loc = place.location;
                    MKCoordinateSpan span = MKCoordinateSpanMake(20.0, 20.0);
                    MKCoordinateRegion region = MKCoordinateRegionMake(loc.coordinate, span);
                    [self.mapView setRegion:region animated:YES];
                } else {
                    [self zoomWayOut];
                }
            }];
        } else {
            [self zoomWayOut];
        }


    }

}

- (void)zoomWayOut {
    // if there's one map pin or less and no polygons, then zoom out to country-wide
    MKCoordinateSpan span = MKCoordinateSpanMake(20.0, 20.0);
    MKCoordinateRegion region = MKCoordinateRegionMake([self.mapView centerCoordinate], span);
    [self.mapView setRegion:region];
}








- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    NSString *identifier = @"mapPin";

    if ([annotation isKindOfClass:[STASDKUIAlertPin class]]) {
        STASDKUIAlertPin *alertPin = (STASDKUIAlertPin*) annotation;
        MKAnnotationView *pinAnnotation = [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];

        if (pinAnnotation) {
            pinAnnotation.annotation = alertPin;
        } else {
            pinAnnotation = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
        pinAnnotation.image = [UIImage imageNamed:@"MapPinAlert" inBundle:bundle compatibleWithTraitCollection:NULL];

        return pinAnnotation;
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
