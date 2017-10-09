//
//  STASDKUIAlertsTableViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-02-05.
//
//

#import "STASDKUIAlertsTableViewController.h"

#import "STASDKDataController.h"
#import "STASDKMTrip.h"
#import "STASDKMAlert.h"
#import "STASDKMAdvisory.h"
#import "STASDKUIAlertTableViewCell.h"
#import "STASDKUIAlertViewController.h"
#import "STASDKUINullStateHandler.h"
#import "STASDKUIUtility.h"
#import "STASDKUIStylesheet.h"
#import "STASDKJobs.h"

#import "STASDKDefines.h"
#import "STASDKMEvent.h"

#import <Realm/Realm.h>


@interface STASDKUIAlertsTableViewController ()

@property (nonatomic, strong) RLMArray<STASDKMAlert*> *alerts;
@property (nonatomic, strong) RLMArray<STASDKMAdvisory*> *advisories;

@property STASDKUINullStateHandler *nullView;

@end


@implementation STASDKUIAlertsTableViewController




- (void)viewDidLoad {
    [super viewDidLoad];

    // This is necessary because our xib files are in a separate bundle for the sdk
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    [self.tableView registerNib:[UINib nibWithNibName:@"AlertCell" bundle:bundle] forCellReuseIdentifier:@"AlertCell"];
    self.tableView.rowHeight = 70.0;
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];


    // Back button in nav
    NSString *close = [[STASDKDataController sharedInstance] localizedStringForKey:@"CLOSE"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:close
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(close:)];
    NSString *title;
    if (self.mode == Alerts) {
        title = [[STASDKDataController sharedInstance] localizedStringForKey:@"ALERTS"];
    } else {
        title = [[STASDKDataController sharedInstance] localizedStringForKey:@"ADVISORIES"];
    }
    self.navigationItem.title = title;

    // Colors
    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    self.view.backgroundColor = styles.alertsAdvisoriesListPageBackgroundColor;

    [STASDKUIUtility applyStylesheetToNavigationController:self.navigationController];

    [self loadData];

    if (self.mode == Alerts) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataChange:) name:NotifyTripAlertsSaved object:NULL];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataChange:) name:NotifyTripAdvisoriesSaved object:NULL];
    }
}



-(void)viewDidAppear:(BOOL)animated {
    [STASDKMEvent trackEvent:TrackPageOpen name:[self eventPageType]];
}
-(void)viewDidDisappear:(BOOL)animated {
    [STASDKMEvent trackEvent:TrackPageClose name:[self eventPageType]];
}
-(int)eventPageType {
    if (self.mode == Alerts) {
        return EventAlertsIndex;
    } else {
        return EventAdvisoriesIndex;
    }
}

-(void)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadData {

    if (self.trip != NULL) {
        if (self.mode == Alerts) {
            [self loadAlerts];
        } else {
            [self loadAdvisories];
        }
    }

    if (![self hasData]) {
        NSString *msgKey;
        if (self.mode == Alerts) {
            msgKey = @"NO_ALERTS";
        } else {
            msgKey = @"NO_ADVISORIES";
        }
        NSString *msg = [[STASDKDataController sharedInstance] localizedStringForKey:msgKey];
        self.nullView = [[STASDKUINullStateHandler alloc] initWith:msg parent:self];
        [self.nullView displayNullState];
    }


    // launch trip builder if trip is empty
    if (self.trip != NULL) {
        [self setNotificationIcon];
        if ([self.trip isEmpty]) {
            [STASDKUI showTripBuilder:self.trip.identifier];
        }
    }
}

- (void)setNotificationIcon {
    NSString *imgName;
    if (self.trip.muted) {
        imgName = @"BellDisabled";
    } else {
        imgName = @"Bell";
    }
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    UIImage *img = [UIImage imageNamed:imgName inBundle:bundle compatibleWithTraitCollection:NULL];

    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(toggleMute:)];
    self.navigationItem.rightBarButtonItem = btn;
}

-(void)toggleMute:(id)sender {
    if (self.trip.muted) {
        [self doToggleMute];
    } else {
        // confirmation alert dialog
        STASDKDataController *ctrl = [STASDKDataController sharedInstance];
        UIAlertController *alertCtrl = [UIAlertController
                                        alertControllerWithTitle:[ctrl localizedStringForKey:@"DISABLE_TTL"]
                                        message:[ctrl localizedStringForKey:@"DISABLE_MSG"]
                                        preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:[ctrl localizedStringForKey:@"YES"]
                                   style:UIAlertActionStyleDestructive
                                   handler:^(UIAlertAction * action) {
                                       [self doToggleMute];
                                   }];
        [alertCtrl addAction:okAction];

        UIAlertAction *noAction = [UIAlertAction
                                   actionWithTitle:[ctrl localizedStringForKey:@"NO"]
                                   style:UIAlertActionStyleDefault
                                   handler:NULL];
        [alertCtrl addAction:noAction];

        [self presentViewController:alertCtrl animated:YES completion:nil];
    }
}

// This performs an eager request via background jobs to ensure the UI is spiffy.
-(void)doToggleMute {
    if (self.trip != NULL) {
        // Make request using background job
        NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:!self.trip.muted], @"muted", nil];
        [[STASDKJobs sharedInstance] addJob:JOB_CHANGE_TRIP_SETTINGS jobArgs:@{JOB_PARAM_TRIPID: [self.trip identifier], JOB_PARAM_SETTINGS: settings}];

        RLMRealm *realm = [[STASDKDataController sharedInstance] theRealm];
        [realm transactionWithBlock:^{
            self.trip.muted = !self.trip.muted;
        }];
        [self setNotificationIcon];
    }
}

- (void)loadAlerts {
    self.alerts = [self.trip alerts];
}

- (void)loadAdvisories {
    self.advisories = [self.trip advisories];
}


// This is to update the table on changes to our result set
- (void)handleDataChange:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *tripId = [userInfo valueForKey:NotifyTripId];
    if ([self.trip.identifier isEqualToString:tripId]) {
        [self loadData];
        [self.tableView reloadData];
        if (self.nullView) {
            [self.nullView dismiss];
        }
    }
}


- (bool)hasData {
    if (self.alerts != NULL) {
        return [self.alerts count] > 0;
    } else {
        return [self.advisories count] > 0;
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self hasData]) {
        long counter;
        if (self.mode == Alerts) {
            counter = [self.alerts count];
        } else {
            counter = [self.advisories count];
        }

        return counter;
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STASDKUIAlertTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlertCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)configureCell:(STASDKUIAlertTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if ([self hasData]) {

        switch (self.mode) {
            case Alerts:
                [self setCellForAlert:cell indexPath:indexPath];
                break;
            case Advisories:
                [self setCellForAdvisory:cell indexPath:indexPath];
                break;
            default:
                NSLog(@"Unknown mode.");
                break;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        [cell setForEmpty:self.mode];
    }

    [STASDKUIUtility applyZebraStripeToTableCell:cell indexPath:indexPath];
}

- (void)setCellForAlert:(STASDKUIAlertTableViewCell*)cell indexPath:(NSIndexPath*)indexPath {
    STASDKMAlert *alert = [self.alerts objectAtIndex:[indexPath row]];
    [cell setForAlert:alert];
}

- (void)setCellForAdvisory:(STASDKUIAlertTableViewCell*)cell indexPath:(NSIndexPath*)indexPath {
    STASDKMAdvisory *advisory = [self.advisories objectAtIndex:[indexPath row]];
    [cell setForAdvisory:advisory];
}



#pragma mark - TableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // alert view controller is used for both alerts and advisories
    STASDKUIAlertTableViewCell *cell = (STASDKUIAlertTableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
    [cell setRead];
    [self performSegueWithIdentifier:@"showAlert" sender:cell];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([[segue identifier] isEqualToString:@"showAlert"]) {
        NSIndexPath *path = [self.tableView indexPathForCell:sender];
        STASDKUIAlertViewController *vc = [segue destinationViewController];
        long index = [path row];
        if (self.mode == Alerts) {
            STASDKMAlert *alert = [self.alerts objectAtIndex:index];
            vc.alert = alert;
        } else {
            STASDKMAdvisory *advisory = [self.advisories objectAtIndex:index];
            vc.advisory = advisory;
        }

    }
    

}


@end
