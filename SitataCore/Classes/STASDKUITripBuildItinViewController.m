//
//  STASDKUITripBuildItinViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-07-03.
//
//

#import "STASDKUITripBuildItinViewController.h"

#import <MapKit/MapKit.h>
#import "STASDKDataController.h"
#import "STASDKMTrip.h"
#import "STASDKMCountry.h"
#import "STASDKUIItineraryCountryHeaderView.h"
#import "STASDKUIItineraryCityHeaderView.h"
#import "STASDKUITBDestPickerPageViewController.h"
#import "STASDKUILocationSearchTableViewController.h"
#import "STASDKApiMisc.h"
#import "STASDKUITripLocationAnnotation.h"

#import <Realm/Realm.h>
#import <Contacts/Contacts.h>


@interface STASDKUITripBuildItinViewController () <UITableViewDelegate, UITableViewDataSource, STASDKUIItineraryCountryHeaderViewDelegate, STASDKUIItineraryCityHeaderViewDelegate, MKMapViewDelegate,
    UIPopoverPresentationControllerDelegate, STASDKUITBDestinationPickerDelegate, UISearchControllerDelegate, STASDKUILocationSearchDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property UISearchController *searchController;




@end

@implementation STASDKUITripBuildItinViewController

static NSString* const kHeaderIdentifier = @"countryHeader";
static NSString* const kCellIdentifier = @"cityCell";
static CGFloat const kHeaderFooterHeight = 50.0f;
static CGFloat const kCityRowHeight = 35.0f;
static CGFloat const kTimelineEdgeSpacing = 31.0f; // TODO: Start using this

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self loadSearchController];

    self.mapView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];


    // register xibs for table
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    [self.tableView registerNib:[UINib nibWithNibName:@"TBItineraryCountryHeader" bundle:bundle] forHeaderFooterViewReuseIdentifier:kHeaderIdentifier];
    self.tableView.rowHeight = 65.0;


    self.tableView.backgroundColor = [self tableViewColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (RLMResults*)destinations {
    return [self.trip sortedDestinations];
}

- (bool)hasDestinations {
    return [[self destinations] count] > 0;
}

- (UIColor*)tableViewColor {
    return [UIColor groupTableViewBackgroundColor];
}


# pragma mark - Search Controller

- (void) loadSearchController {
    STASDKUILocationSearchTableViewController *searchTable = [self.storyboard instantiateViewControllerWithIdentifier:@"locationSearchTable"];
    searchTable.delegate = self;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController: searchTable];
    self.searchController.searchResultsUpdater = searchTable;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.delegate = self;
    // ensure that search bar does not remain on screen if user navigates to another view controller
    self.definesPresentationContext = YES;
}


- (void)didDismissSearchController:(UISearchController *)searchController {
    [self.searchController.searchBar removeFromSuperview];
}






#pragma mark - TableView


// Number of sections should be start header and then a section for each country
// in the destinations list
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self hasDestinations]) {
        return [[self destinations] count] + 2; // +1 for itinerary header and +1 for add country header
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if ([self hasDestinations]) {
        if (section == 0 || section == [self numberOfSectionsInTableView:self.tableView]-1) {
            return 0; // fancy itinerary header or add country header at end of all destination sections
        } else {
            STASDKMDestination *dest = [self destinationForSection:section];
            if (dest) {
                return [[dest destinationLocations] count];
            } else {
                return 0;
            }
        }
    } else {
        return 0; // fancy itinerary header only
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];

    if (section == 0) { return NULL; }

    // needs to have cities listed
    if (self.hasDestinations) {
        STASDKMDestination *dest = [self destinationForSection:section];
        STASDKMDestinationLocation *loc = [[dest destinationLocations] objectAtIndex:row];
        STASDKUIItineraryCityHeaderView *view = [[STASDKUIItineraryCityHeaderView alloc] initWithLocation:loc];
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell addSubview:view];
        view.frame = cell.frame;
        view.delegate = self;
        view.backgroundColor = [self tableViewColor];
        return cell;
    } else {
        return NULL;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCityRowHeight;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0 || section == [self numberOfSectionsInTableView:self.tableView]-1) {
        // when there are destinations, and we have fancy itinerary header as first section,
        // then a footer is not necessary and we need to hide it by setting height to zero
        return 0;
    }
    return kHeaderFooterHeight; // otherwise footer is used for add city

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeaderFooterHeight;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    if (section == 0) {
        return [self itineraryTitleHeaderView]; // fancy itinerary header
    } else if (section == [self numberOfSectionsInTableView:self.tableView]-1) {
        return [self addCountryRow]; // this is is the last section which should contain the add country header
    } else {
        STASDKMDestination *dest = [self destinationForSection:section];
        STASDKUIItineraryCountryHeaderView *view = [[STASDKUIItineraryCountryHeaderView alloc] initWithDestination:dest];
        view.delegate = self;
        view.backgroundColor = [self tableViewColor];
        return view;
    }
}



- (nullable UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {

    if (section == 0 || section == [self numberOfSectionsInTableView:self.tableView]-1) {
        return NULL;
    } else {
        STASDKMDestination *dest = [self destinationForSection:section];
        STASDKUIItineraryCityHeaderView *view = [[STASDKUIItineraryCityHeaderView alloc] init];
        view.delegate = self;
        view.parentDestination = dest;
        view.titleLbl.text = [[STASDKDataController sharedInstance] localizedStringForKey:@"TB_ADD_CITY"];
        view.backgroundColor = [self tableViewColor];
        [view removeRemoveBtn];
        return view;
    }

}

- (STASDKMDestination*)destinationForSection:(NSInteger)section {
    return [[self destinations] objectAtIndex:section-1];
}

- (UIView*)addCountryRow {
    STASDKUIItineraryCountryHeaderView *view = [[STASDKUIItineraryCountryHeaderView alloc] init];
    view.delegate = self;
    view.titleLbl.text = [[STASDKDataController sharedInstance] localizedStringForKey:@"TB_ADD_COUNTRY"];
    view.backgroundColor = [self tableViewColor];
    [view removeRemoveBtn];
    [view removeDateLbl];
    return view;
}



- (UIView*)itineraryTitleHeaderView {
    CGRect frame = self.tableView.frame;
    frame.size.height = kHeaderFooterHeight;
    UIView *base = [[UIView alloc] initWithFrame:frame];

    // Circle Image
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    UIImage *img = [UIImage imageNamed:@"PlusBtnEmpty" inBundle:bundle compatibleWithTraitCollection:NULL];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    CGFloat imgSize = 45.0;
    imgView.frame = CGRectMake(0, 0, imgSize, imgSize);
    [base addSubview:imgView];
    imgView.tintColor = [UIColor darkGrayColor];
    imgView.translatesAutoresizingMaskIntoConstraints = NO;
    [imgView.leftAnchor constraintEqualToAnchor:base.leftAnchor constant:10.0].active = true;
    [imgView.centerYAnchor constraintEqualToAnchor:base.centerYAnchor].active = true;
    [imgView.heightAnchor constraintEqualToConstant:imgSize].active = true;
    [imgView.widthAnchor constraintEqualToConstant:imgSize].active = true;


    // Timeline bar
    CGFloat ydiff = fabs(imgSize - kHeaderFooterHeight);
    CGFloat ypos = ydiff/2.0;
    CGFloat imageBottom = ypos + imgSize;
    CGFloat imageSpace = 10.0;
    CGFloat barStart = imageBottom - imageSpace;
    CGFloat barHeight = 35.0; // kHeaderFooterHeight - barStart;
    UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(31.0, barStart, 3.0, barHeight)];
    bar.backgroundColor = [UIColor darkGrayColor];
    [base addSubview:bar];

    // Title
    CGRect rect = CGRectMake(0, 0, 0, 0);
    UILabel *title = [[UILabel alloc] initWithFrame:rect];
    title.text = [[STASDKDataController sharedInstance] localizedStringForKey:@"TB_ITINERARY"];
    title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    title.textColor = [UIColor darkGrayColor];
    title.numberOfLines = 1;
    [title sizeToFit];

    [base addSubview:title];

    title.translatesAutoresizingMaskIntoConstraints = NO;
    [title.leftAnchor constraintEqualToAnchor:imgView.rightAnchor constant:10].active = true;
    [title.centerYAnchor constraintEqualToAnchor:base.centerYAnchor].active = true;

    base.backgroundColor = [self tableViewColor];

    return base;

}



#pragma mark - UIItineraryCountryHeaderViewDelegate

// launch the destination picker
- (void) onAddCountry:(id)sender {
    [self performSegueWithIdentifier:@"destinationPicker" sender:sender];
}


- (void) onRemoveCountry:(id)sender removed:(STASDKMDestination *)destination {
    
    [self.theRealm transactionWithBlock:^{
        // destination might not be last in order
        int index = (int) [self.trip.destinations indexOfObject:destination];
        [self.trip.destinations removeObjectAtIndex:index];
    }];
    [self.tableView reloadData];
}


#pragma mark - UIItineraryCityHeaderViewDelegate

// launch the city picker
- (void) onAddCity:(id)sender destination:(STASDKMDestination*)destination {

    STASDKUILocationSearchTableViewController *searchTable = (STASDKUILocationSearchTableViewController*) self.searchController.searchResultsUpdater;
    searchTable.currentDestination = destination;
    [self.mapView addSubview:self.searchController.searchBar];
    [self.searchController setActive:YES];
}

- (void) onRemoveCity:(id)sender removed:(STASDKMDestinationLocation *)location {
    int index;
    for (STASDKMDestination *dest in [self destinations]) {
        index = (int) [dest.destinationLocations indexOfObject:location];
        if (index != -1) {
            [self.theRealm transactionWithBlock:^{
                [dest.destinationLocations removeObjectAtIndex:index];
            }];
            [self.tableView reloadData];
            break;
        }
    }
}


#pragma mark - STASDKUITBDestinationPickerDelegate

- (void) onPickedDestination:(STASDKMDestination *)destination {
    [self.theRealm transactionWithBlock:^{

        // new destinations need a unique id to save in temporary memory
        NSString *uuid = [[NSUUID UUID] UUIDString];
        destination.identifier = uuid;

        [[self.trip destinations] addObject:destination];

    }];
    [self zoomToCountry:destination.countryCode];
    [self.tableView reloadData];
}


- (void)zoomToCountry:(NSString*)countryCode {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    NSDictionary *addDict = @{CNPostalAddressISOCountryCodeKey : countryCode};
    [geocoder geocodeAddressDictionary:addDict completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
        if (placemarks.count >= 1) {
            CLPlacemark *place = [placemarks objectAtIndex:0];
            CLLocation *loc = place.location;
            MKCoordinateSpan span = MKCoordinateSpanMake(20.0, 20.0);
            MKCoordinateRegion region = MKCoordinateRegionMake(loc.coordinate, span);
            [self.mapView setRegion:region animated:YES];
        }
    }];
}


#pragma mark - STASDKUILocationSearchDelegate

- (void)onSelectedLocation:(STASDKMDestinationLocation *)location forDestination:(STASDKMDestination *)destination {
    [self fetchLatLngFor:location onFinished:^{
        [self.theRealm transactionWithBlock:^{
            location.identifier = [[NSUUID UUID] UUIDString]; // temporary id
            [destination.destinationLocations addObject:location];
            [self dropMapPinFor:location];
        }];

        [self.searchController dismissViewControllerAnimated:YES completion:^{
            [self.searchController setActive:NO];
            [self.searchController.searchBar removeFromSuperview];
            [self.tableView reloadData];
        }];
    }];
}

- (void)fetchLatLngFor:(STASDKMDestinationLocation*)location onFinished:(void(^)()) callback {
    [STASDKApiMisc googleFetchPlace:location._googlePlaceId onFinished:^(NSDictionary *result, NSURLSessionDataTask *task, NSError *error) {
        if (result) {
            NSDictionary *geo = [result objectForKey:@"geometry"];
            if (geo) {
                NSDictionary *resultLoc = [geo objectForKey:@"location"];
                if (resultLoc) {
                    location.latitude = [[resultLoc objectForKey:@"lat"] doubleValue];
                    location.longitude  = [[resultLoc objectForKey:@"lng"] doubleValue];
                }
            }
        }
        callback();
    }];
}

- (void)dropMapPinFor:(STASDKMDestinationLocation*)location {
    STASDKUITripLocationAnnotation *ann = [[STASDKUITripLocationAnnotation alloc] initWith:location];
    [self.mapView addAnnotation:ann];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([[segue identifier] isEqualToString:@"destinationPicker"]) {
        STASDKUITBDestPickerPageViewController *vc = [segue destinationViewController];
        UIPopoverPresentationController *ctrl = vc.popoverPresentationController;
        if (ctrl != NULL) {
            // refer to adaptivePresentationStyleForPresentationController
            ctrl.delegate = self;

            // ensure arrow of popover is centered on button and not top left corner
            ctrl.sourceRect = ((UIView*) sender).bounds;

            // set size of window
            vc.preferredContentSize = CGSizeMake(300.0, 300.0);
        }
        vc.destPickerDelegate = self;
    }
    
    
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone; // necessary so it won't be full screen on phones
}




#pragma mark - MapView

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    NSString *identifier = @"pinAnnotation";

    if ([annotation isKindOfClass:[STASDKUITripLocationAnnotation class]]) {
        STASDKUITripLocationAnnotation *cityPin = (STASDKUITripLocationAnnotation*)annotation;

        MKPinAnnotationView *pinAnnotation = (MKPinAnnotationView*) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (pinAnnotation) {
            pinAnnotation.annotation = cityPin;
        } else {
            pinAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        pinAnnotation.animatesDrop = YES;
        pinAnnotation.canShowCallout = YES;
        [pinAnnotation setSelected:YES];

        return pinAnnotation;
    }

    return nil;
}



@end
