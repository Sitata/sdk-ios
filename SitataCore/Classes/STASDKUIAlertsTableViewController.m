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

#import <Realm/Realm.h>


@interface STASDKUIAlertsTableViewController ()

@property (nonatomic, strong) RLMArray<STASDKMAlert*> *alerts;
@property (nonatomic, strong) RLMArray<STASDKMAdvisory*> *advisories;
@property (nonatomic, strong) RLMNotificationToken *notification;
@property (nonatomic) BOOL hasData;



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
    NSError *error;
    STASDKMTrip *trip = [STASDKMTrip currentTrip];

    if (trip != NULL && error == NULL) {

        if (self.mode == Alerts) {
            [self loadAlerts:trip];
        } else {
            [self loadAdvisories:trip];
        }

    }

    if (!self.hasData) {
        NSString *msgKey;
        if (self.mode == Alerts) {
            msgKey = @"NO_ALERTS";
        } else {
            msgKey = @"NO_ADVISORIES";
        }
        NSString *msg = [[STASDKDataController sharedInstance] localizedStringForKey:msgKey];
        [STASDKUINullStateHandler displayNullStateWith:msg parentView:self.view];
    }
}

- (void)loadAlerts:(STASDKMTrip*)trip {
    self.alerts = [trip alerts];
    self.hasData = self.alerts.count > 0;
    [self addRealmNotifications:self.alerts];
}

- (void)loadAdvisories:(STASDKMTrip*)trip {
    self.advisories = [trip advisories];
    self.hasData = self.advisories.count > 0;
    [self addRealmNotifications:self.advisories];
}

// This is to update the table on changes to our result set
- (void)addRealmNotifications:(RLMArray*)realmObjs {
    __weak typeof(self) weakSelf = self;
    self.notification = [realmObjs addNotificationBlock:^(RLMArray *data, RLMCollectionChange *changes, NSError *error) {
        if (error) {
            NSLog(@"Failed to open Realm on background worker: %@", error);
            return;
        }

        UITableView *tv = weakSelf.tableView;
        if (!changes) {
            [tv reloadData];
            return;
        }

        // changes is non-nil, so we just need to update the tableview
        [tv beginUpdates];
        [tv deleteRowsAtIndexPaths:[changes deletionsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tv insertRowsAtIndexPaths:[changes insertionsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tv reloadRowsAtIndexPaths:[changes modificationsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tv endUpdates];
    }];
}





#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.hasData) {
        long counter;
        if (self.mode == Alerts) {
            counter = [self.alerts count];
        } else {
            counter = [self.advisories count];
        }

        return counter;
    } else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STASDKUIAlertTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlertCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)configureCell:(STASDKUIAlertTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (self.hasData) {

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
    [self performSegueWithIdentifier:@"showAlert" sender:[tableView cellForRowAtIndexPath:indexPath]];
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
