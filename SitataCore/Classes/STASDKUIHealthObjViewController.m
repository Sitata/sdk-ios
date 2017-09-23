//
//  STASDKUIHealthObjViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-03-05.
//
//

#import "STASDKUIHealthObjViewController.h"

#import "STASDKUIDiseaseDetailViewController.h"
#import "STASDKMTripHealthComment.h"
#import "STASDKMTrip.h"
#import "STASDKUIHealthCommentTableViewCell.h"
#import "STASDKDataController.h"
#import "STASDKMCountry.h"
#import "STASDKMDisease.h"
#import "STASDKUIStylesheet.h"

#import "STASDKDefines.h"
#import "STASDKMEvent.h"

@interface STASDKUIHealthObjViewController ()

@property RLMResults *dataObjects;
@property (weak, nonatomic) IBOutlet UIButton *readMoreBtn;


@end

@implementation STASDKUIHealthObjViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.readMoreBtn setAlpha:0.0];

    STASDKMTrip *trip = [STASDKMTrip currentTrip];
    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    if (trip != NULL) {
        switch (self.healthMode) {
            case Vaccinations:
                [self loadVaccinations:trip];
                self.view.backgroundColor = styles.vaccinationPageBackgroundColor;
                self.tableView.backgroundColor = styles.vaccinationPageBackgroundColor;
                break;
            case Medications:
                [self loadMedications:trip];
                self.view.backgroundColor = styles.medicationPageBackgroundColor;
                self.tableView.backgroundColor = styles.medicationPageBackgroundColor;
                break;
            case Diseases:
                [self.readMoreBtn setAlpha:1.0];
                [self loadDiseases:trip];
                self.view.backgroundColor = styles.diseasePageBackgroundColor;
                self.tableView.backgroundColor = styles.diseasePageBackgroundColor;
                break;
            default:
                NSLog(@"Trying to present an unknown health type!");
                [self dismissViewControllerAnimated:YES completion:NULL];
                break;
        }
    }


    [self.healthObjTitle setFont:styles.headingFont];
    [self.healthObjTitle setTextColor:styles.headingTextColor];

    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    [self.tableView registerNib:[UINib nibWithNibName:@"HealthCommentCell" bundle:bundle] forCellReuseIdentifier:@"commentCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
            return EventVaccinationDetails;
        case Medications:
            return EventMedicationDetails;
        case Diseases:
            return EventDiseaseDetails;
    }
}

-(void)loadVaccinations:(STASDKMTrip*)trip {
    self.dataObjects = [STASDKMTripVaccinationComment commentsForVaccination:self.healthObjId trip:trip];
    STASDKMTripVaccinationComment *vcomment = [self.dataObjects firstObject];
    if (vcomment != NULL) {
        [self.healthObjTitle setText:vcomment.vaccinationName];
    }
}

-(void)loadMedications:(STASDKMTrip*)trip {
    self.dataObjects = [STASDKMTripMedicationComment commentsForMedication:self.healthObjId trip:trip];
    STASDKMTripMedicationComment *mcomment = [self.dataObjects firstObject];
    if (mcomment != NULL) {
        [self.healthObjTitle setText:mcomment.medicationName];
    }
}

-(void)loadDiseases:(STASDKMTrip*)trip {
    self.dataObjects = [STASDKMTripDiseaseComment commentsForDisease:self.healthObjId trip:trip];
    STASDKMTripDiseaseComment *dcomment = [self.dataObjects firstObject];
    if (dcomment != NULL) {
        [self.healthObjTitle setText:dcomment.diseaseName];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    STASDKUIHealthCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];

    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    switch (self.healthMode) {
        case Vaccinations:
            cell.backgroundColor = styles.vaccinationPageBackgroundColor;
            break;
        case Medications:
            cell.backgroundColor = styles.medicationPageBackgroundColor;
            break;
        case Diseases:
            cell.backgroundColor = styles.diseasePageBackgroundColor;
            break;
        default:
            NSLog(@"Trying to present an unknown health type!");
            break;
    }


    id obj = [self.dataObjects objectAtIndex:[indexPath row]];

    SEL selector = NSSelectorFromString(@"comment");
    IMP imp = [obj methodForSelector:selector];
    NSString* (*func)(id, SEL) = (void *)imp;
    NSString *comment = func(obj, selector);

    SEL idSelector = NSSelectorFromString(@"countryId");
    IMP imp2 = [obj methodForSelector:idSelector];
    NSString* (*func2)(id, SEL) = (void *)imp2;
    NSString *countryId = func2(obj, idSelector);


    STASDKMCountry *country = [STASDKMCountry findBy:countryId];
    if (country != NULL) {
        [cell.countryNameLbl setText:[country name]];
        [cell.countryNameLbl setFont:styles.titleFont];
        [cell.countryNameLbl setTextColor:styles.titleTextColor];
    }

    [cell.commentLbl setFont:styles.bodyFont];
    [cell.commentLbl setText:comment];
    [cell.commentLbl setTextColor:styles.bodyTextColor];

    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}


# pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDisease"]) {
        // find disease
        STASDKMDisease *disease = [STASDKMDisease findBy:self.healthObjId];
        STASDKUIDiseaseDetailViewController *vc = [segue destinationViewController];
        vc.disease = disease;
    }
}


@end
