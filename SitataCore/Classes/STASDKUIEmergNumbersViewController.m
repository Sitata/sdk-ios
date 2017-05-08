//
//  STASDKUIEmergNumbersViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-03-16.
//
//

#import "STASDKUIEmergNumbersViewController.h"

#import "STASDKDataController.h"
#import "STASDKMContactDetail.h"
#import "STASDKMCountry.h"
#import "STASDKMTrip.h"
#import "STASDKUIContactDetailTableViewCell.h"
#import "STASDKUICountryPickerPopoverViewController.h"
#import "STASDKUIUtility.h"
#import "STASDKUIStylesheet.h"
#import "Haneke.h"
#import "STASDKLocationHandler.h"

#import <MapKit/MapKit.h>


@interface STASDKUIEmergNumbersViewController () <UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *countryNameLbl;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *contacts;
@property STASDKMCountry *country;
@property STASDKMTrip *trip;
@property (weak, nonatomic) IBOutlet UIImageView *countryFlagImg;

@property BOOL deferringUpdates;
@property CLLocationManager *locManager;
@property NSString *geoCodedCountryCode;

@end

@implementation STASDKUIEmergNumbersViewController

static NSString* const kCellIdentifier = @"detailCell";
static CGFloat kContactDetailRowHeight;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.contacts = [[NSMutableArray alloc] init];


    kContactDetailRowHeight = UITableViewAutomaticDimension;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = kContactDetailRowHeight;
    self.tableView.estimatedRowHeight = 55.0;
    self.tableView.allowsSelection = NO;
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    [self.tableView registerNib:[UINib nibWithNibName:@"ContactDetailRowCell" bundle:bundle] forCellReuseIdentifier:kCellIdentifier];

    [STASDKUIUtility applyStylesheetToNavigationController:self.navigationController];

    // Back button in nav
    NSString *close = [[STASDKDataController sharedInstance] localizedStringForKey:@"CLOSE"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:close
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(close:)];


    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    self.view.backgroundColor = styles.emergNumbersPageBackgroundColor;
    self.tableView.backgroundColor = styles.emergNumbersPageBackgroundColor;
    self.countryNameLbl.textColor = styles.emergNumbersPageTitleColor;
    self.changeBtn.tintColor = styles.emergNumbersPageChangeBtnColor;

    // if there is no trip available, we still want the user to be able
    // to find emergency numbers manually to avoid negative experience.
    self.trip = [STASDKMTrip currentTrip];
    [self setupCountry];

    [STASDKLocationHandler requestPermissionsWhenNecessary];
    [self setupLocationManager];

}

-(void)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Determine country by current trip itinerary. In the future,
// perhaps we can make an external API request to set it from GPS. In the
// meantime, we still allow the user to pick it manually in case it's wrong.
- (void)setupCountry {

    if (self.geoCodedCountryCode != NULL) {
        self.country = [STASDKMCountry findByCountryCode:self.geoCodedCountryCode];
    } else {
        // Try to select country from trip
        if (self.trip != NULL) {
            self.country = [self.trip currentCountry];
        }
    }

    if (self.country != NULL) {
        [self setUIForCountry];
        [self setContacts];
    }
}

- (void)setUIForCountry {
    if (self.country == NULL) {
        [self.countryNameLbl setAlpha:0.0];
        [self.changeBtn setTitle:[[STASDKDataController sharedInstance] localizedStringForKey:@"PICK_COUNTRY"] forState:UIControlStateNormal];
        [self.countryFlagImg setAlpha:0.0];
    } else {
        [self.countryNameLbl setAlpha:1.0];
        self.countryNameLbl.text = self.country.name;
        [self.changeBtn setTitle:[[STASDKDataController sharedInstance] localizedStringForKey:@"CHANGE"] forState:UIControlStateNormal];

        NSString *flagUrlStr = [self.country flagURL];
        if (flagUrlStr != NULL && flagUrlStr.length > 0) {
            NSURL *flagUrl = [[NSURL alloc] initWithString:flagUrlStr];
            [self.countryFlagImg hnk_setImageFromURL:flagUrl];
            [self.countryFlagImg setAlpha:0.1];
        } else {
            [self.countryFlagImg setAlpha:0.0];
        }

    }
}


- (void)setContacts {
    if (self.country == NULL) {return;}

    self.contacts = [[self.country emergNumbersArray] mutableCopy];

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

        // reload data
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:0];
        [self.tableView reloadSections:set withRowAnimation:TRUE];
    }

}

#pragma mark - TableView Delegates

- (STASDKMContactDetail*)contactDetailForIndexPath:(NSIndexPath*)indexPath {
    NSInteger contactIndex = [indexPath row];
    return [self.contacts objectAtIndex:contactIndex];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.contacts count] > 0) {
        return [self.contacts count];
    } else {
        return 1; // null state row
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kContactDetailRowHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];

    if ([self.contacts count] > 0) {
        // CONTACT DETAILS
        STASDKUIContactDetailTableViewCell *contactCell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
        contactCell.forcePhone = YES;

        // pre-sorted above by 'order' attribute
        STASDKMContactDetail *detail = [self contactDetailForIndexPath:indexPath];
        [contactCell setForContactDetail:detail];

        contactCell.valueLbl.textColor = styles.emergNumberContactLblColor;
        contactCell.noteLbl.textColor = styles.emergNumberContactNoteLblColor;
        contactCell.actionBtn.tintColor = styles.emergNumberContactBtnLblColor;

        cell = contactCell;
    } else {
        cell = [[UITableViewCell alloc] init];
    }

    [STASDKUIUtility applyZebraStripeToTableCell:cell indexPath:indexPath];

    return cell;
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([[segue identifier] isEqualToString:@"countryPicker"]) {
        STASDKUICountryPickerPopoverViewController *vc = [segue destinationViewController];
        UIPopoverPresentationController *ctrl = vc.popoverPresentationController;
        if (ctrl != NULL) {
            // refer to adaptivePresentationStyleForPresentationController
            ctrl.delegate = self;

            // ensure arrow of popover is centered on button and not top left corner
            ctrl.sourceRect = ((UIView*) sender).bounds;

            // set size of window
            vc.preferredContentSize = CGSizeMake(300.0, 300.0);
        }
        vc.parentVC = self;
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone; // necessary so it won't be full screen on phones
}

// This is called from the popover VC when a country is picked.
- (void)onChangeCountry:(STASDKMCountry*)country {
    if (country != NULL) {
        self.geoCodedCountryCode = NULL;
        self.country = country;
        [self setupCountry];
    }
}






#pragma mark - Location
- (void)setupLocationManager {
    if (![CLLocationManager locationServicesEnabled]) {
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


        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            // find out country
            CLPlacemark *place = [placemarks objectAtIndex:0];
            if (place != NULL) {
                NSString *code = [place ISOcountryCode];
                if (self.geoCodedCountryCode != code) {
                    self.geoCodedCountryCode = code;
                    [self setupCountry];
                }
            }
        }];
    }

    // Defer updates until the user moves a certain distance
    // or when a certain amount of time has passed.
    if (!self.deferringUpdates) {
        CLLocationDistance distance = 1000.0; // meters
        NSTimeInterval time = 900.0; // seconds
        [self.locManager allowDeferredLocationUpdatesUntilTraveled:distance
                                                           timeout:time];
        self.deferringUpdates = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
    self.deferringUpdates = NO;
}





@end
