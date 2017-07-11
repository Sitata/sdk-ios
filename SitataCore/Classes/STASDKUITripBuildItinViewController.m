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


@interface STASDKUITripBuildItinViewController () <UITableViewDelegate, UITableViewDataSource, STASDKUIItineraryCountryHeaderViewDelegate, STASDKUIItineraryCityHeaderViewDelegate,
    UIPopoverPresentationControllerDelegate, STASDKUITBDestinationPickerDelegate, UISearchControllerDelegate, STASDKUILocationSearchDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property UISearchController *searchController;


@property (nonatomic) RLMRealm *memoryRealm;

@end

@implementation STASDKUITripBuildItinViewController

static NSString* const kHeaderIdentifier = @"countryHeader";
static NSString* const kCellIdentifier = @"cityCell";
static CGFloat const kHeaderFooterHeight = 50.0f;
static CGFloat const kCityRowHeight = 25.0f;
static CGFloat const kTimelineEdgeSpacing = 31.0f; // TODO: Start using this

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self loadSearchController];
    [self loadTrip];

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


// if we don't already have a trip, create a new one for the purposes of sending to the server
- (void) loadTrip {
    if (self.trip == NULL) {

        // querying on destinations and such won't work unless the trip is persisted into
        // a realm, but we don't want to put it into our default disk based realm... so
        // we create a temporary in-memory store instead.
        RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
        config.inMemoryIdentifier = @"TBMemoryRealm";
        self.memoryRealm = [RLMRealm realmWithConfiguration:config error:NULL];

        self.trip = [[STASDKMTrip alloc] init];
        [self.memoryRealm transactionWithBlock:^{
            [self.memoryRealm addObject:self.trip];
        }];
    }
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

- (void)onSelectedLocation:(STASDKMDestinationLocation *)location forDestination:(STASDKMDestination *)destination {
    [self fetchLatLngFor:location onFinished:^{
        [self.memoryRealm transactionWithBlock:^{
            location.identifier = [[NSUUID UUID] UUIDString]; // temporary id
            [destination.destinationLocations addObject:location];
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
        bool isLastDest = section == [self numberOfSectionsInTableView:self.tableView]-2; // just before last section
        STASDKUIItineraryCountryHeaderView *view = [[STASDKUIItineraryCountryHeaderView alloc] initWithDestination:dest isLast:isLastDest];
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



#pragma - mark UIItineraryCountryHeaderViewDelegate

// launch the destination picker
- (void) onAddCountry:(id)sender {
    [self performSegueWithIdentifier:@"destinationPicker" sender:sender];
}

// we only allow removal of the last destination at any given time
- (void) onRemoveCountry:(id)sender {
    STASDKMDestination *destination = [[self destinations] lastObject];

    [self.memoryRealm transactionWithBlock:^{
        // destination might not be last in order
        int index = [self.trip.destinations indexOfObject:destination];
        [self.trip.destinations removeObjectAtIndex:index];
    }];
    [self.tableView reloadData];
}


#pragma - mark UIItineraryCityHeaderViewDelegate

// launch the city picker
- (void) onAddCity:(id)sender destination:(STASDKMDestination*)destination {

    STASDKUILocationSearchTableViewController *searchTable = (STASDKUILocationSearchTableViewController*) self.searchController.searchResultsUpdater;
    searchTable.currentDestination = destination;
    [self.mapView addSubview:self.searchController.searchBar];
    [self.searchController setActive:YES];
}


#pragma - mark STASDKUITBDestinationPickerDelegate

- (void) onPickedDestination:(STASDKMDestination *)destination {
    [self.memoryRealm transactionWithBlock:^{

        // new destinations need a unique id to save in temporary memory
        NSString *uuid = [[NSUUID UUID] UUIDString];
        destination.identifier = uuid;

        [[self.trip destinations] addObject:destination];
    }];
    [self.tableView reloadData];
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



@end
