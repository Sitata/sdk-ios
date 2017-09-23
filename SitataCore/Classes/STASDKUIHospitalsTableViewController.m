//
//  STASDKUIHospitalsTableViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-03-10.
//
//

#import "STASDKUIHospitalsTableViewController.h"

#import "STASDKMHospital.h"
#import "STASDKMCountry.h"
#import "STASDKLocationHandler.h"
#import "STASDKUIHospitalPin.h"
#import "STASDKUIHospitalClusterView.h"
#import "STASDKDataController.h"
#import "STASDKUIHospitalRowTableViewCell.h"
#import "STASDKUIHospitalDetailViewController.h"

#import "CCHMapClusterController.h"
#import "CCHMapClusterControllerDelegate.h"
#import "CCHMapClusterAnnotation.h"
#import "CCHNearCenterMapClusterer.h"

#import "STASDKUIUtility.h"
#import "STASDKUIStylesheet.h"


@interface STASDKUIHospitalsTableViewController () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CCHMapClusterControllerDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CCHMapClusterController *mapClusterController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


// Because we want to show / order by closest hospitals first, AND we can't do
// fetching with computed properties (in a query) in Realm, then we must store all hospitals in
// an array in memory. Not ideal.
// https://github.com/realm/realm-cocoa/issues/1265
@property NSMutableArray *hospitals;

@property CLLocationManager *locManager;
@property BOOL deferringUpdates;
@property CLLocation* currentLocation;


@end



// Display hospitals on map with table below. When a map cluster "is unique" it means that all the
// objects within it have the same location. In this case, we toggle the image for the object from
// the cluster image to the singular map pin image.
@implementation STASDKUIHospitalsTableViewController

static double const kMaxClusterZoom = 8.0;
static NSString* const kCellIdentifier = @"hospitalCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.hospitals = [[NSMutableArray alloc] init];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    
    // This is necessary because our xib files are in a separate bundle for the sdk
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    [self.tableView registerNib:[UINib nibWithNibName:@"HospitalRowCell" bundle:bundle] forCellReuseIdentifier:kCellIdentifier];
    self.tableView.rowHeight = 65.0;


    [STASDKLocationHandler requestPermissionsWhenNecessary];
    [self setupLocationManager];
    self.mapView.showsUserLocation = YES;

    if (self.country != NULL) {
        [self loadData];
        [self setupMapData];
    } // country should never be null

    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    self.view.backgroundColor = styles.hospitalListPageBackgroundColor;
    self.tableView.backgroundColor = styles.hospitalListPageBackgroundColor;
}


- (void)loadData {
    RLMResults *results = [STASDKMHospital findForCountry:self.country.identifier];
    for (RLMObject *object in results) {
        [self.hospitals addObject:object];
    }
}

- (void)sortData {
    if (self.hospitals != NULL && [self.hospitals count] > 0) {
        [self.hospitals sortUsingComparator:^NSComparisonResult(STASDKMHospital *obj1, STASDKMHospital *obj2) {
            CLLocation *obj1Loc = [[CLLocation alloc] initWithLatitude:obj1.latitude longitude:obj1.longitude];
            CLLocationDistance distanceObj1 = [self.currentLocation distanceFromLocation:obj1Loc];
            CLLocation *obj2Loc = [[CLLocation alloc] initWithLatitude:obj2.latitude longitude:obj2.longitude];
            CLLocationDistance distanceObj2 = [self.currentLocation distanceFromLocation:obj2Loc];

            if (distanceObj1 > distanceObj2) {
                return NSOrderedDescending;
            }

            if (distanceObj1 < distanceObj2) {
                return NSOrderedAscending;
            }
            return NSOrderedSame;
        }];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([sender isKindOfClass:[STASDKMHospital class]]) {
        STASDKUIHospitalDetailViewController *vc = [segue destinationViewController];
        vc.hospital = sender;
    }
}




#pragma mark - TableView Source & Delegate

- (void)reloadData {
    [self.tableView beginUpdates];
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:0];
    [self sortData];
    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.hospitals count] > 0) {
        return [self.hospitals count];
    } else {
        return 1; // no hospitals row
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];

    UITableViewCell *cell;

    if ([self.hospitals count] > 0) {
        STASDKUIHospitalRowTableViewCell *hospitalCell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];

        STASDKMHospital *hospital = [self.hospitals objectAtIndex:[indexPath row]];

        // If distance is available, use it.
        if (self.currentLocation != NULL) {
            CLLocation *hospitalLocation = [[CLLocation alloc] initWithLatitude:hospital.latitude longitude:hospital.longitude];
            CLLocationDistance distance = [self.currentLocation distanceFromLocation:hospitalLocation];
            [hospitalCell setForHospital:hospital distance:distance];
        } else {
            // If distance is not available, don't use it and this will hide the label.
            [hospitalCell setForHospital:hospital];
        }
        cell = hospitalCell;
    } else {
        // TODO: No data cell
        cell = [[UITableViewCell alloc] init];
        cell.textLabel.text = [[STASDKDataController sharedInstance] localizedStringForKey:@"NO_HOSPITALS"];
        cell.textLabel.numberOfLines = 0;
    }
    [cell.textLabel setFont:styles.rowTextFont];
    [cell.textLabel setTextColor:styles.bodyTextColor];

    [STASDKUIUtility applyZebraStripeToTableCell:cell indexPath:indexPath];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // passing hospital to performSegue because that's how we have to do it if user
    // clicks on map pin callout
    STASDKMHospital *hospital = [self.hospitals objectAtIndex:[indexPath row]];
    [self performSegueWithIdentifier:@"showHospital" sender:hospital];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - mapView

- (void)setupMapData {
    self.mapView.delegate = self;

    MKMapRect bounds = MKMapRectNull;

    NSMutableArray *annotations = [[NSMutableArray alloc] init];

    for (STASDKMHospital *hospital in self.hospitals) {

        STASDKUIHospitalPin *annotation = [[STASDKUIHospitalPin alloc] initWith:hospital];

        [annotations addObject:annotation];

        // for bounds
        MKMapPoint point = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(point.x, point.y, 0.1, 0.1);
        if (MKMapRectIsNull(bounds)) {
            bounds = pointRect;
        } else {
            bounds = MKMapRectUnion(bounds, pointRect);
        }
    }


    self.mapClusterController = [[CCHMapClusterController alloc] initWithMapView:self.mapView];
    self.mapClusterController.delegate = self;
    self.mapClusterController.maxZoomLevelForClustering = kMaxClusterZoom;
//    self.mapClusterController.debuggingEnabled = YES;

    [self.mapClusterController addAnnotations:annotations withCompletionHandler:NULL];

    // set map to bounds
    [self.mapView setVisibleMapRect:bounds edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    NSString *clusterIdentifier = @"clusterAnnotation";

    if ([annotation isKindOfClass:[CCHMapClusterAnnotation class]]) {
        CCHMapClusterAnnotation *clusterAnnotation = (CCHMapClusterAnnotation *)annotation;

        STASDKUIHospitalClusterView *clusterAnnotationView = (STASDKUIHospitalClusterView *) [mapView dequeueReusableAnnotationViewWithIdentifier:clusterIdentifier];
        if (clusterAnnotationView) {
            clusterAnnotationView.annotation = annotation;
        } else {
            clusterAnnotationView = [[STASDKUIHospitalClusterView alloc] initWithAnnotation:annotation reuseIdentifier:clusterIdentifier];
        }

        [clusterAnnotationView setUnique:clusterAnnotation.isUniqueLocation];
        return clusterAnnotationView;
    }

    return nil;
}


- (void)mapClusterController:(CCHMapClusterController *)mapClusterController willReuseMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    STASDKUIHospitalClusterView *clusterAnnotationView = (STASDKUIHospitalClusterView *) [self.mapView viewForAnnotation:mapClusterAnnotation];
    [clusterAnnotationView setUnique:mapClusterAnnotation.isUniqueLocation];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:CCHMapClusterAnnotation.class]) {


        CCHMapClusterAnnotation *clusterAnnotation = (CCHMapClusterAnnotation *)view.annotation;
        if (clusterAnnotation.isUniqueLocation) {
            // show hospital title with info side icon
            view.canShowCallout = YES; // had to re-set to YES here for some reason.
            view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        } else {
            // Zoom in on cluster / pins if not unique
            MKMapRect mapRect = [clusterAnnotation mapRect];
            UIEdgeInsets edgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
            [mapView setVisibleMapRect:mapRect edgePadding:edgeInsets animated:YES];
        }
    }
}

- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController titleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation {
    if (mapClusterAnnotation.isUniqueLocation) {

        STASDKMHospital *hospital = [self firstHospitalFromMapClusterAnnotation:mapClusterAnnotation];
        if (hospital != NULL) {
            return hospital.name;
        }
    }
    return NULL;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSLog(@"accessory button tapped for annotation %@", view.annotation);

    if ([view.annotation isKindOfClass:[CCHMapClusterAnnotation class]]) {
        STASDKMHospital *hospital = [self firstHospitalFromMapClusterAnnotation:view.annotation];
        [self performSegueWithIdentifier:@"showHospital" sender:hospital];
    }
}

// Returns first hospital from map cluster annotation
- (STASDKMHospital*)firstHospitalFromMapClusterAnnotation:(CCHMapClusterAnnotation*)mapClusterAnnotation {
    NSSet *annotations = mapClusterAnnotation.annotations;
    for (id annotation in annotations) {
        if ([annotation isKindOfClass:[STASDKUIHospitalPin class]]) {
            STASDKUIHospitalPin *hospitalPin = (STASDKUIHospitalPin*) annotation;
            return hospitalPin.hospital;
        }
    }
    return NULL;
}



#pragma mark - Location Manager

- (void)setupLocationManager {

    if (![CLLocationManager locationServicesEnabled]){
        return;
    }
    self.deferringUpdates = NO;

    self.locManager = [[CLLocationManager alloc] init];
    self.locManager.delegate = self;
    self.locManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locManager.distanceFilter = 100; // meters
    self.locManager.pausesLocationUpdatesAutomatically = YES;
    self.locManager.activityType = CLActivityTypeFitness;
    [self.locManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {

    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];

    // throws away any events that are more than fifteen seconds old under
    // the assumption that events up to that age are likely to be good enough.
    if (fabs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        self.currentLocation = location;
        [self reloadData];
    }


    // Defer updates until the user moves a certain distance
    // or when a certain amount of time has passed.
    if (!self.deferringUpdates) {
        CLLocationDistance distance = 100.0; // meters
        NSTimeInterval time = 120.0; // seconds
        [self.locManager allowDeferredLocationUpdatesUntilTraveled:distance
                                                           timeout:time];
        self.deferringUpdates = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
    self.deferringUpdates = NO;
}

@end
