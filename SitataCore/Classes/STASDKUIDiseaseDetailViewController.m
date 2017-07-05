//
//  STASDKUIDiseaseDetailViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-03-17.
//
//

#import "STASDKUIDiseaseDetailViewController.h"

#import "STASDKDataController.h"
#import "STASDKMDisease.h"
#import "STASDKUICardTableViewCell.h"
#import "STASDKUIStylesheet.h"



@interface STASDKUIDiseaseDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *diseaseLbl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (strong, nonatomic) NSArray *diseaseProps;
@property (strong, nonatomic) NSMutableArray *diseaseAvailableProps;
@property (strong, nonatomic) NSDictionary *diseasePropTitles;
@property (strong, nonatomic) NSMutableSet *expandedIndexPaths;


@end




@implementation STASDKUIDiseaseDetailViewController

static NSString* const kDiseaseCellIdentifier = @"DiseaseCell";

static CGFloat const kDiseaseDefaultRowHeight = 50.f;
static CGFloat const kSectionSeparatorDistance = 20.f;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.expandedIndexPaths = [NSMutableSet set];

    self.diseaseLbl.text = self.disease.name;

    self.diseaseProps = @[@"description", @"transmission", @"susceptibility", @"symptoms", @"prevention", @"treatment", @"occursWhere"];

    NSString *secPerDesc = [[STASDKDataController sharedInstance] localizedStringForKey:@"DISEASE_WHAT"];
    NSString *secTrans = [[STASDKDataController sharedInstance] localizedStringForKey:@"DISEASE_HOW"];
    NSString *secSusc = [[STASDKDataController sharedInstance] localizedStringForKey:@"DISEASE_RES"];
    NSString *secSymp = [[STASDKDataController sharedInstance] localizedStringForKey:@"DISEASE_SYM"];
    NSString *secPrev = [[STASDKDataController sharedInstance] localizedStringForKey:@"DISEASE_PRE"];
    NSString *secTreat = [[STASDKDataController sharedInstance] localizedStringForKey:@"DISEASE_TRT"];
    NSString *secWhere = [[STASDKDataController sharedInstance] localizedStringForKey:@"DISEASE_WHR"];

    self.diseasePropTitles = [[NSDictionary alloc] initWithObjectsAndKeys:secPerDesc, @"description",
                  secTrans, @"transmission",
                  secSusc, @"susceptibility",
                  secSymp, @"symptoms",
                  secPrev, @"prevention",
                  secTreat, @"treatment",
                  secWhere, @"occursWhere",
                  nil];

    self.diseaseAvailableProps = [[NSMutableArray alloc] init];
    [self setSections];


    self.tableView.delegate = self;
    self.tableView.dataSource = self;


    self.tableView.estimatedRowHeight = kDiseaseDefaultRowHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    self.view.backgroundColor = styles.diseaseAboutPageBackgroundColor;


    // This is necessary because our xib files are in a separate bundle for the sdk
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    [self.tableView registerNib:[UINib nibWithNibName:@"CardTableViewCell" bundle:bundle] forCellReuseIdentifier:kDiseaseCellIdentifier];


}

// Personal Security, Extreme Violence, Political Unrest, Areas To Avoid
// Not all of these sections are guaranteed to have content. This handles that fact by
// removing sections that shouldn't be displayed.
- (void)setSections {
    for (NSString *prop in self.diseaseProps) {
        if ([self hasContentFor:prop]) {
            [self.diseaseAvailableProps addObject:prop];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - UITableViewDataSource / UITableViewDelegate




- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.diseaseAvailableProps count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return kSectionSeparatorDistance;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kSectionSeparatorDistance;
}

// The header and footer in each section are necessary so we can have a space between
// content cells to allow the shadow to be properly displayed & to control colors.
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    view.backgroundColor = styles.diseaseAboutPageBackgroundColor;
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    view.backgroundColor = styles.diseaseAboutPageBackgroundColor;
    return view;
}


- (BOOL)hasContentFor:(NSString*)prop {
    SEL selector = NSSelectorFromString(prop);
    IMP imp = [self.disease methodForSelector:selector];
    NSString* (*func)(id, SEL) = (void *)imp;
    NSString *val = func(self.disease, selector);

    if (val == NULL) {return false;}

    NSString *trimmedString = [val stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];

    return [trimmedString length] > 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    STASDKUICardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDiseaseCellIdentifier forIndexPath:indexPath];

    NSInteger sectionIndex = [indexPath section]; // only one row per section so this works fine

    NSString *prop = [self.diseaseAvailableProps objectAtIndex:sectionIndex];
    NSString *title = [self.diseasePropTitles objectForKey:prop];

    SEL selector = NSSelectorFromString(prop);
    IMP imp = [self.disease methodForSelector:selector];
    NSString* (*func)(id, SEL) = (void *)imp;
    NSString *content = func(self.disease, selector);

    cell.titleLbl.text = title;
    cell.bodyLbl.text = content;

    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    cell.backgroundColor = styles.diseaseAboutPageBackgroundColor;
    cell.titleLbl.textColor = styles.diseaseAboutPageSectionHeaderLblColor;
    cell.bodyLbl.textColor = styles.diseaseAboutPageSectionContentLblColor;
    cell.containerView.backgroundColor = styles.diseaseAboutPageSectionCardBackgroundColor;

    return cell;
}




@end
