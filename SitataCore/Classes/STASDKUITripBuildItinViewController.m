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


@interface STASDKUITripBuildItinViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic) RLMResults *destinations;
@property (nonatomic) bool hasDestinations;

@end

@implementation STASDKUITripBuildItinViewController

static NSString* const kHeaderIdentifier = @"countryHeader";
static NSString* const kCellIdentifier = @"cityCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (self.trip != NULL) {
        self.destinations = [self.trip sortedDestinations];
        self.hasDestinations = self.destinations.count > 0;
    }

    self.tableView.dataSource = self;
    self.tableView.delegate = self;


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




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - TableView


// Number of sections should be start header and then a section for each country
// in the destinations list
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.hasDestinations) {
        return self.destinations.count;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) { return 0;} // only fancy header in first section

    if (self.hasDestinations) {
        // TODO: RETURN NUMBER OF CITIES WITHIN EACH DESTINATION
        return 1;
    } else {
        return 1;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: TEMP
    UITableViewCell *cell = [[UITableViewCell alloc] init];


    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];

    if (section == 0) { return NULL; }


    if (self.hasDestinations) {

    } else {

    }


    return cell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        // fancy itinerary
        
    }
}



//- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;   // custom view for footer. will be adjusted to default or specified footer height


@end
