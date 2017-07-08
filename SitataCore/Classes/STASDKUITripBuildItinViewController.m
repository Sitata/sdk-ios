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
#import "STASDKUITBDestPickerPageViewController.h"


@interface STASDKUITripBuildItinViewController () <UITableViewDelegate, UITableViewDataSource, UIItineraryCountryHeaderViewDelegate, UIPopoverPresentationControllerDelegate, STASDKUITBDestinationPickerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) RLMRealm *memoryRealm;

@end

@implementation STASDKUITripBuildItinViewController

static NSString* const kHeaderIdentifier = @"countryHeader";
static NSString* const kCellIdentifier = @"cityCell";
static CGFloat const kHeaderFooterHeight = 50.0f;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self loadTrip];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];


    // register xibs for table
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    [self.tableView registerNib:[UINib nibWithNibName:@"TBItineraryCountryHeader" bundle:bundle] forHeaderFooterViewReuseIdentifier:kHeaderIdentifier];

//    [self.tableView registerNib:[UINib nibWithNibName:@"HospitalRowCell" bundle:bundle] forCellReuseIdentifier:kCellIdentifier];
    self.tableView.rowHeight = 65.0;

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
            // TODO: RETURN NUMBER OF CITIES WITHIN EACH DESTINATION
            return 1;
        }
    } else {
        return 0; // fancy itinerary header only
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: TEMP
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor yellowColor];

    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];

    if (section == 0) { return cell; } // TODO

    // needs to have cities listed
    if (self.hasDestinations) {

    } else {

    }


    return cell;
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
        STASDKMDestination *dest = [[self destinations] objectAtIndex:section-1];
        STASDKUIItineraryCountryHeaderView *view = [[STASDKUIItineraryCountryHeaderView alloc] initWithDestination:dest];
        return view;
    }


}

- (nullable UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *emptyView = [[UIView alloc] init];
    emptyView.backgroundColor = [UIColor redColor];


    if (section == 0 || section == [self numberOfSectionsInTableView:self.tableView]-1) {
        return NULL;
    }

    return emptyView; // TODO: return add city footer
}

- (UIView*)addCountryRow {
    STASDKUIItineraryCountryHeaderView *view = [[STASDKUIItineraryCountryHeaderView alloc] init];
    view.delegate = self;
    view.titleLbl.text = [[STASDKDataController sharedInstance] localizedStringForKey:@"TB_ADD_COUNTRY"];
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
    CGFloat barHeight = kHeaderFooterHeight - barStart;
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

    return base;

}



#pragma - mark UIItineraryCountryHeaderViewDelegate

// launch the destination picker
- (void) onAddCountry:(id)sender {
    [self performSegueWithIdentifier:@"destinationPicker" sender:sender];
}


#pragma - mark STASDKUITBDestinationPickerDelegate

- (void) onPickedDestination:(STASDKMDestination *)destination {
    NSLog(@"PICKED DESTINATION %@", destination);
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