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

#import <Realm/Realm.h>


@interface STASDKUIHealthTableViewController ()

    // An array of all tripMedicationComments or tripVaccinationComments
    @property RLMResults *allDataObjects;

    // To store an array for display such as [ [medicationId, medicationName], etc... ]
    @property NSArray *uniqueDataObjects;

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
    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    [STASDKUIUtility applyStylesheetToNavigationController:self.navigationController];


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

    if ([self.uniqueDataObjects count] <= 0) {
        NSString *str = [self stringForNoData];
        [STASDKUINullStateHandler displayNullStateWith:str parentView:self.view];
    }

}

-(void)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
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



- (void)loadVaccinations {
    STASDKMTrip *trip = [STASDKMTrip currentTrip];

    if (trip != NULL) {
        self.allDataObjects = [[trip tripVaccinationComments] sortedResultsUsingKeyPath:@"vaccinationName" ascending:YES];
        self.uniqueDataObjects = [self uniqueObjectsArray:@"vaccinationId" nameMethodName:@"vaccinationName"];
    }
}

- (void)loadMedications {
    STASDKMTrip *trip = [STASDKMTrip currentTrip];

    if (trip != NULL) {
        self.allDataObjects = [[trip tripMedicationComments] sortedResultsUsingKeyPath:@"medicationName" ascending:YES];
        self.uniqueDataObjects = [self uniqueObjectsArray:@"medicationId" nameMethodName:@"medicationName"];
    }
}

- (void)loadDiseases {
    STASDKMTrip *trip = [STASDKMTrip currentTrip];

    if (trip != NULL) {
        self.allDataObjects = [[trip tripDiseaseComments] sortedResultsUsingKeyPath:@"diseaseName" ascending:YES];
        self.uniqueDataObjects = [self uniqueObjectsArray:@"diseaseId" nameMethodName:@"diseaseName"];
    }
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
        // "no items" row
        return 1;
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
