//
//  STASDKUIHospitalDetailViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-03-15.
//
//

#import "STASDKUIHospitalDetailViewController.h"
#import "STASDKMHospital.h"
#import "STASDKUIHospitalPin.h"
#import "STASDKDataController.h"
#import "STASDKLocationHandler.h"
#import "STASDKMContactDetail.h"
#import "STASDKMAddress.h"
#import "STASDKUIContactDetailTableViewCell.h"
#import "STASDKUIHospitalExtrasTableViewCell.h"
#import "STASDKUI.h"
#import "STASDKUIUtility.h"
#import "STASDKUIStylesheet.h"

#import <MapKit/MapKit.h>

@interface STASDKUIHospitalDetailViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *distanceLbl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property BOOL deferringUpdates;
@property CLLocationManager *locManager;
@property CLLocation* currentLocation;


@property NSMutableArray *contacts;
@property NSString *addressStr;
@property BOOL hasAddress;


@end



@implementation STASDKUIHospitalDetailViewController

static NSString* const kCellIdentifier = @"detailCell";
static NSString* const kExtrasCellIndent = @"extrasCell";
static CGFloat const kExtraRowHeight = 108.0;
static CGFloat kContactDetailRowHeight;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    kContactDetailRowHeight = UITableViewAutomaticDimension;

    self.deferringUpdates = NO;

    self.nameLbl.text = self.hospital.name;


    [self.distanceLbl setAlpha:0.0]; // has to be hidden until location shows up
    [STASDKLocationHandler requestPermissionsWhenNecessary];
    [self setupLocationManager];

    [self setupMapData];
    [self setupDetails];

    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    self.view.backgroundColor = styles.hospitalPageBackgroundColor;
    self.tableView.backgroundColor = styles.hospitalPageBackgroundColor;
    self.nameLbl.textColor = styles.hospitalNameLblColor;
    self.distanceLbl.textColor = styles.hospitalDistanceLblColor;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupDetails {
    self.contacts = [[NSMutableArray alloc] init];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = kContactDetailRowHeight;
    self.tableView.estimatedRowHeight = 55.0;
    self.tableView.allowsSelection = NO;
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    [self.tableView registerNib:[UINib nibWithNibName:@"ContactDetailRowCell" bundle:bundle] forCellReuseIdentifier:kCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"HospitalExtrasRowCell" bundle:bundle] forCellReuseIdentifier:kExtrasCellIndent];

    self.contacts = [[self.hospital contactDetailsArray] mutableCopy];

    STASDKMAddress *address = [self.hospital addressObj];
    if (address != NULL) {
        self.addressStr = [address addressString];
        self.hasAddress = self.addressStr.length > 0;
    } else {
        self.hasAddress = NO;
    }


    // sort contact details by order property ascending
    if ([self.contacts count] > 0) {
        [self.contacts sortUsingComparator:^NSComparisonResult(STASDKMContactDetail *obj1, STASDKMContactDetail *obj2) {
            if (obj1.order > obj2.order) {
                return NSOrderedDescending;
            }
            if (obj1.order < obj2.order) {
                return NSOrderedAscending;
            }
            return NSOrderedSame;
        }];
    }

}

#pragma mark - TableView Delegates

- (STASDKMContactDetail*)contactDetailForIndexPath:(NSIndexPath*)indexPath {
    if ([indexPath row] == 0) {return NULL;}
    int contactIndex = (int)[indexPath row] - 1; // address has first spot
    return [self.contacts objectAtIndex:contactIndex];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        // HIGHLIGHT DETAILS
        return 1;
    } else if (section == 1) {
        // CONTACT DETAILS
        // The number of rows for display is going to be the address plus the number of contact details
        // that the hospital has.
        int count = (int)[self.contacts count];
        if (self.hasAddress) {
            count++;
        }
        
        return count;
    } else {
        return 0;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    if (section == 0) {
        // HIGHLIGHT DETAILS
        return kExtraRowHeight;
    } else {
        return kContactDetailRowHeight;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;

    NSInteger section = [indexPath section];
    if (section == 0) {
        // HIGHLIGHT DETAILS
        STASDKUIHospitalExtrasTableViewCell *detailCell = [tableView dequeueReusableCellWithIdentifier:kExtrasCellIndent forIndexPath:indexPath];
        [detailCell setForHospital:self.hospital];
        cell = detailCell;
    } else if (section == 1) {
        // CONTACT DETAILS
        STASDKUIContactDetailTableViewCell *contactCell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
        if ([indexPath row] == 0 && self.hasAddress) {
            // address should be shown first
            [contactCell setForAddress:self.addressStr];
            [contactCell setHospital:self.hospital];
        } else {
            // pre-sorted above by 'order' attribute
            [contactCell setForContactDetail:[self contactDetailForIndexPath:indexPath]];
        }

        STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
        contactCell.valueLbl.textColor = styles.hospitalContactLblColor;
        contactCell.noteLbl.textColor = styles.hospitalContactNoteLblColor;
        contactCell.actionBtn.tintColor = styles.hospitalContactBtnLblColor;

        cell = contactCell;


    }

    [STASDKUIUtility applyZebraStripeToTableCell:cell indexPath:indexPath];

    return cell;
}




#pragma mark - Location
- (void)setupLocationManager {
    if (![CLLocationManager locationServicesEnabled]) {
        [self.distanceLbl removeFromSuperview]; // remove distane display
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

        // Calculate and set distance
        CLLocation *hospitalLocation = [[CLLocation alloc] initWithLatitude:self.hospital.latitude longitude:self.hospital.longitude];
        CLLocationDistance distance = [self.currentLocation distanceFromLocation:hospitalLocation];

        NSString *distStr = [STASDKUI formattedDistance:distance];
        self.distanceLbl.text = distStr;
        [self.distanceLbl setAlpha:1.0]; // because it starts off hidden
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








#pragma mark - Map Stuff
- (void)setupMapData {


    self.mapView.delegate = self;

    STASDKUIHospitalPin *annotation = [[STASDKUIHospitalPin alloc] initWith:self.hospital];

    [self.mapView addAnnotation:annotation];

    // zoom to hospital coordinates
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
    MKCoordinateRegion region = MKCoordinateRegionMake(annotation.coordinate, span);
    [self.mapView setRegion:region animated:YES];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    NSString *identifier = @"pinAnnotation";

    if ([annotation isKindOfClass:[STASDKUIHospitalPin class]]) {
        STASDKUIHospitalPin *hospitalPin = (STASDKUIHospitalPin*)annotation;

        MKAnnotationView *pinAnnotation = [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (pinAnnotation) {
            pinAnnotation.annotation = hospitalPin;
        } else {
            pinAnnotation = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }

        STASDKMHospital *hospital = hospitalPin.hospital;
        NSString *imgName;
        if ([hospital isAccredited]) {
            imgName = @"MapPinHospitalAccredited";
        } else {
            imgName = @"MapPinHospital";
        }
        NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
        pinAnnotation.image = [UIImage imageNamed:imgName inBundle:bundle compatibleWithTraitCollection:NULL];
        return pinAnnotation;
    }
    
    return nil;
}


@end
