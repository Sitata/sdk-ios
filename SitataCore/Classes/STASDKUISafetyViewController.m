//
//  STASDKUISafetyViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-03-09.
//
//

#import "STASDKUISafetyViewController.h"
#import "STASDKMTrip.h"
#import "STASDKMDestination.h"
#import "STASDKMCountry.h"
#import "STASDKUICountrySwitcherViewController.h"
#import "STASDKUISafetyPageViewController.h"
#import "STASDKUINullStateHandler.h"
#import "STASDKDataController.h"
#import "STASDKUIUtility.h"
#import "STASDKUI.h"

#import "STASDKDefines.h"
#import "STASDKMEvent.h"

@interface STASDKUISafetyViewController ()

@property STASDKMCountry *country;
@property STASDKMTrip *currentTrip;
@property RLMResults *destinations;
@property NSMutableArray *countries;
@property int pageIndex;
@property int pageCount;


@end

@implementation STASDKUISafetyViewController


// needs a local reference otherwise it can't close because it will go out of scope
STASDKUINullStateHandler *nullStateView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pageIndex = 0;
    self.pageCount = 0;


    // Back button in nav
    NSString *close = [[STASDKDataController sharedInstance] localizedStringForKey:@"CLOSE"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:close
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(close:)];
    self.navigationItem.title = [[STASDKDataController sharedInstance]localizedStringForKey:@"SAFETY_TITLE"];

    // Colors
    [STASDKUIUtility applyStylesheetToNavigationController:self.navigationController];


    if (self.currentTrip != NULL) {
        [self setupForTrip];

        if ([self.currentTrip isEmpty]) {
            [STASDKUI showTripBuilder:self.currentTrip.identifier];
        }
    } else {
        // NO Trip, no safety info
        // The other views should load up blank without issues. We just
        // need to place a view on top to display a statement to the user.
        NSString *msg = [[STASDKDataController sharedInstance] localizedStringForKey:@"SEC_NONE_AVAIL"];
        nullStateView = [[STASDKUINullStateHandler alloc] initWith:msg parent:self];
        [nullStateView displayNullState];
    }

}

-(void)viewDidAppear:(BOOL)animated {
    [STASDKMEvent trackEvent:TrackPageOpen name:EventSafety];
}
-(void)viewDidDisappear:(BOOL)animated {
    [STASDKMEvent trackEvent:TrackPageClose name:EventSafety];
}

-(void)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// This structure is necessary because this stuff has to be ready for the
// embedded country switcher which is loaded before viewDidLoad above.
- (void)setupForTrip {
    if (self.countries != NULL) {
        return;
    } else {
        self.countries = [[NSMutableArray alloc] init];
    }

    if (self.currentTrip == NULL) {
        self.currentTrip = [STASDKMTrip currentTrip];

        self.destinations = [self.currentTrip sortedDestinations];
        for (STASDKMDestination *dest in self.destinations) {
            STASDKMCountry *country = [STASDKMCountry findBy:[dest countryId]];
            if (country != NULL) {
                [self.countries addObject:country];
            }
        }
        self.pageCount = (int)[self.countries count];
    } else {
        return;
    }
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

    if ([[segue identifier] isEqualToString:@"embedCountrySwitcher"]) {
        STASDKUICountrySwitcherViewController *vc = [segue destinationViewController];
        vc.pageCount = self.pageCount;
        vc.pageIndex = self.pageIndex;
        vc.countries = self.countries;
    } else if ([[segue identifier] isEqualToString:@"embedSafetyPager"]) {
        STASDKUISafetyPageViewController *vc = [segue destinationViewController];
        vc.countries = self.countries;
    }
}


@end
