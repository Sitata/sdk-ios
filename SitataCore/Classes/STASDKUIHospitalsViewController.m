//
//  STASDKUIHospitalsViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-03-10.
//
//

#import "STASDKDataController.h"
#import "STASDKUIHospitalsViewController.h"
#import "STASDKMCountry.h"
#import "STASDKMTrip.h"
#import "STASDKMDestination.h"
#import "STASDKUICountrySwitcherViewController.h"
#import "STASDKUIHospitalsPageViewController.h"
#import "STASDKUINullStateHandler.h"
#import "STASDKUIUtility.h"

@interface STASDKUIHospitalsViewController ()

@property STASDKMTrip *currentTrip;
@property RLMResults *destinations;
@property NSMutableArray *countries;
@property int pageIndex;
@property int pageCount;

@end

@implementation STASDKUIHospitalsViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Back button in nav
    NSString *close = [[STASDKDataController sharedInstance] localizedStringForKey:@"CLOSE"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:close
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(close:)];

    self.navigationItem.title = [[STASDKDataController sharedInstance] localizedStringForKey:@"HOSPITALS"];

    [STASDKUIUtility applyStylesheetToNavigationController:self.navigationController];

    self.pageIndex = 0;
    self.pageCount = 0;

    // setup for trip is called first by embed controllers
    if (self.currentTrip != NULL) {
        [self setupForTrip];
    } else {
        // NO TRIP - NO HOSPITALS
        // The other views should load up blank without issues. We just
        // need to place a view on top to display a statement to the user.
        NSString *msg = [[STASDKDataController sharedInstance] localizedStringForKey:@"NO_HOSPITALS_NO_TRIP"];
        [STASDKUINullStateHandler displayNullStateWith:msg parentView:self.view];
    }

}


-(void)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}



// This structure is necessary because this stuff has to be ready for the
// embedded country switcher which is loaded before viewDidLoad above.
- (void)setupForTrip {

    if (self.currentTrip == NULL) {
        self.currentTrip = [STASDKMTrip currentTrip];
    }
    
    if (self.countries != NULL) {
        return;
    } else {
        self.countries = [[NSMutableArray alloc] init]; // must stay here
    }

    self.destinations = [self.currentTrip sortedDestinations];
    for (STASDKMDestination *dest in self.destinations) {
        STASDKMCountry *country = [STASDKMCountry findBy:[dest countryId]];
        if (country != NULL) {
            [self.countries addObject:country];
        }
    }
    self.pageCount = (int) [self.countries count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (IBAction)onClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    // need this for countries
    [self setupForTrip];

    if ([[segue identifier] isEqualToString:@"embedCountrySwitcherForHospitals"]) {
        STASDKUICountrySwitcherViewController *vc = [segue destinationViewController];
        vc.pageCount = self.pageCount;
        vc.pageIndex = self.pageIndex;
        vc.countries = self.countries;
    } else if ([[segue identifier] isEqualToString:@"embedHospitalList"]) {
        STASDKUIHospitalsPageViewController *vc = [segue destinationViewController];
        vc.countries = self.countries;
    }
}

@end
