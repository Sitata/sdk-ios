//
//  STASDKUIHealthTableViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-03-02.
//
//

#import "STASDKUIHealthTableViewController.h"
#import "STASDKMTripHealthComment.h"
#import "STASDKMTrip.h"
#import "STASDKDataController.h"
#import "STASDKUIHealthObjViewController.h"
#import "STASDKUINullStateHandler.h"
#import "STASDKUIUtility.h"
#import "STASDKUIStylesheet.h"

#import "STASDKDefines.h"
#import "STASDKMEvent.h"

#import <Realm/Realm.h>


@interface STASDKUIHealthTableViewController ()

// An array of all tripMedicationComments or tripVaccinationComments
@property RLMResults *allDataObjects;

// To store an array for display such as [ [medicationId, medicationName], etc... ]
@property NSArray *uniqueDataObjects;

@property STASDKMTrip *trip;
@property STASDKUINullStateHandler *nullView;
@property (nonatomic, strong) RLMNotificationToken *notification;

@end

@implementation STASDKUIHealthTableViewController




- (void)viewDidLoad {
    [super viewDidLoad];

    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;


    // Back button in nav
    NSString *close = [[STASDKDataController sharedInstance] localizedStringForKey:@"CLOSE"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:close
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(close:)];
    self.navigationItem.title = [self windowTitle];

    // Colors
    [STASDKUIUtility applyStylesheetToNavigationController:self.navigationController];

    self.trip = [STASDKMTrip currentTrip];
    [self loadData];

    if ([self.uniqueDataObjects count] <= 0) {
        NSString *str = [self stringForNoData];
        self.nullView = [[STASDKUINullStateHandler alloc] initWith:str parent:self];
        [self.nullView displayNullState];
    }

    if (self.trip != NULL && [self.trip isEmpty]) {
        [STASDKUI showTripBuilder:self.trip.identifier];
    }

}

-(void)viewWillDisappear:(BOOL)animated {
    if (self.notification != NULL) {
        [self.notification stop];
    }
}

- (void)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)loadData {
    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    self.uniqueDataObjects = @[]; // empty array to start
    switch (self.healthMode) {
        case Vaccinations:
            [self loadVaccinations];
            self.view.backgroundColor = styles.vaccinationListPageBackgroundColor;
            break;
        case Medications:
            [self loadMedications];
            self.view.backgroundColor = styles.medicationListPageBackgroundColor;
            break;
        case Diseases:
            [self loadDiseases];
            self.view.backgroundColor = styles.diseaseListPageBackgroundColor;
            break;
        default:
            NSLog(@"Trying to present an unknown health type!");
            [self dismissViewControllerAnimated:YES completion:NULL];
            break;
    }
    [self addRealmNotifications:self.allDataObjects];
}

- (NSString*)stringForNoData {
    NSString *str;
    switch (self.healthMode) {
        case Vaccinations:
            str = [[STASDKDataController sharedInstance]localizedStringForKey:@"NO_VACC_COM"];
            break;
        case Medications:
            str = [[STASDKDataController sharedInstance]localizedStringForKey:@"NO_MED_COM"];
            break;
        case Diseases:
            str = [[STASDKDataController sharedInstance]localizedStringForKey:@"NO_DIS_COM"];
            break;
    }
    return str;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [STASDKMEvent trackEvent:TrackPageOpen name:[self eventPageType]];
}
-(void)viewDidDisappear:(BOOL)animated {
    [STASDKMEvent trackEvent:TrackPageClose name:[self eventPageType]];
}
-(int)eventPageType {
    switch(self.healthMode) {
        case Vaccinations:
            return EventVaccinationsIndex;
        case Medications:
            return EventMedicationsIndex;
        case Diseases:
            return EventDiseasesIndex;
    }
}



- (void)loadVaccinations {
    if (self.trip != NULL) {
        self.allDataObjects = [[self.trip tripVaccinationComments] sortedResultsUsingKeyPath:@"vaccinationName" ascending:YES];
        self.uniqueDataObjects = [self uniqueObjectsArray:@"vaccinationId" nameMethodName:@"vaccinationName"];
    }
}

- (void)loadMedications {
    if (self.trip != NULL) {
        self.allDataObjects = [[self.trip tripMedicationComments] sortedResultsUsingKeyPath:@"medicationName" ascending:YES];
        self.uniqueDataObjects = [self uniqueObjectsArray:@"medicationId" nameMethodName:@"medicationName"];
    }
}

- (void)loadDiseases {
    if (self.trip != NULL) {
        self.allDataObjects = [[self.trip tripDiseaseComments] sortedResultsUsingKeyPath:@"diseaseName" ascending:YES];
        self.uniqueDataObjects = [self uniqueObjectsArray:@"diseaseId" nameMethodName:@"diseaseName"];
    }
}


// This is to update the table on changes to our result set
- (void)addRealmNotifications:(RLMResults*)realmObjs {
    __weak typeof(self) weakSelf = self;

    self.notification = [realmObjs addNotificationBlock:^(RLMResults *data, RLMCollectionChange *changes, NSError *error) {
        if (error) {
            NSLog(@"Failed to open Realm on background worker: %@", error);
            return;
        }

        UITableView *tv = weakSelf.tableView;
        if (!changes) {
            [tv reloadData];
            return;
        } else {
            [weakSelf loadData];
            if (weakSelf.nullView != NULL) {
                [weakSelf.nullView dismiss];
            }
        }

        // changes are non-nil, so we just need to update the tableview
        [tv beginUpdates];
        [tv deleteRowsAtIndexPaths:[changes deletionsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tv insertRowsAtIndexPaths:[changes insertionsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tv reloadRowsAtIndexPaths:[changes modificationsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tv endUpdates];
    }];
}


// [{comment:"", vaccinationId: "", vaccinationName: "", countryId: ""}]
// Need to simply create a sorted array with unique medication names and ids
// Returns [ [medicationId, medicationName], [medicationId2, medicationName2] ]
- (NSArray*)uniqueObjectsArray:(NSString*)idMethodName nameMethodName:(NSString*)nameMethodName {
    NSMutableArray *listArr = [[NSMutableArray alloc] init];

    for (id comment in self.allDataObjects) {

        SEL selector = NSSelectorFromString(idMethodName);
        IMP imp = [comment methodForSelector:selector];
        NSString* (*func)(id, SEL) = (void *)imp;
        NSString *targetId = func(comment, selector); // e.g. comment.medicationId

        SEL nameSelector = NSSelectorFromString(nameMethodName);
        IMP imp2 = [comment methodForSelector:nameSelector];
        NSString* (*func2)(id, SEL) = (void *)imp2;
        NSString *targetName = func2(comment, selector); // e.g. comment.medicationName

        BOOL found = NO;
        for (NSArray *val in listArr) {
            NSString *identifier = [val objectAtIndex:0];

            if ([targetId isEqualToString:identifier]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            [listArr addObject:@[targetId, targetName]];
        }
    }
    return listArr;
}






#pragma mark - Table view data source
- (NSString*)nameForIndex:(int)index {
    // objects stored as [objectId, name]
    NSArray *values = [self.uniqueDataObjects objectAtIndex:index];
    return [values objectAtIndex:1];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.uniqueDataObjects count] > 0) {
        return [self.uniqueDataObjects count];
    } else {
        return 0;
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"healthCell" forIndexPath:indexPath];

    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    // For now, simply displaying the name of the vaccine or medication in each row
    if ([self.uniqueDataObjects count] > 0) {
        NSString *name = [self nameForIndex:(int)[indexPath row]];
        [cell.textLabel setText:name];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    } else {
        NSString *str;
        switch (self.healthMode) {
            case Vaccinations:
                str = [[STASDKDataController sharedInstance]localizedStringForKey:@"NO_VACC_COM"];
                break;
            case Medications:
                str = [[STASDKDataController sharedInstance]localizedStringForKey:@"NO_MED_COM"];
                break;
            case Diseases:
                str = [[STASDKDataController sharedInstance]localizedStringForKey:@"NO_DIS_COM"];
                break;
        }
        [cell.textLabel setText:str];
        [cell.textLabel setNumberOfLines:0];
        [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
        
    }

    switch (self.healthMode) {
        case Vaccinations:
            cell.textLabel.textColor = styles.vaccinationRowNameLblColor;
            break;
        case Medications:
            cell.textLabel.textColor = styles.medicationRowNameLblColor;
            break;
        case Diseases:
            cell.textLabel.textColor = styles.diseaseRowNameLblColor;
            break;
    }

    [STASDKUIUtility applyZebraStripeToTableCell:cell indexPath:indexPath];
    
    return cell;
}


#pragma mark - Misc

- (NSString*)windowTitle {
    switch (self.healthMode) {
        case Vaccinations:
            return [[STASDKDataController sharedInstance]localizedStringForKey:@"VAC_TITLE"];
        case Medications:
            return [[STASDKDataController sharedInstance]localizedStringForKey:@"MED_TITLE"];
        case Diseases:
            return [[STASDKDataController sharedInstance]localizedStringForKey:@"DIS_TITLE"];
    }
    return @"";
}





#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([[segue identifier] isEqualToString:@"showHealthObj"]) {

        NSIndexPath *path = [self.tableView indexPathForCell:sender];

        NSArray *chosen = [self.uniqueDataObjects objectAtIndex:[path row]];
        NSString *healthObjId = [chosen objectAtIndex:0]; // identifier of medication or vaccination
        STASDKUIHealthObjViewController *vc = [segue destinationViewController];
        vc.healthObjId = healthObjId;
        vc.healthMode = self.healthMode;
    }

}


@end
