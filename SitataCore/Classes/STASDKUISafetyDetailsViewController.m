//
//  STASDKUISafetyDetailsViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-03-09.
//
//

#import "STASDKUISafetyDetailsViewController.h"

#import "STASDKMCountry.h"
#import "STASDKDataController.h"
#import "STASDKUICardTableViewCell.h"
#import "STASDKUIStylesheet.h"


@interface STASDKUISafetyDetailsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *props;
@property (strong, nonatomic) NSMutableArray *availableProps;
@property (strong, nonatomic) NSDictionary *propTitles;
@property (strong, nonatomic) NSMutableSet *expandedIndexPaths;

@end

@implementation STASDKUISafetyDetailsViewController

static NSString* const kSafetyCellIdentifier = @"SafetyCell";

static CGFloat const kSafetyDefaultRowHeight = 50.f;
static CGFloat const kSectionSeparatorDistance = 20.f;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.expandedIndexPaths = [NSMutableSet set];

    self.props = @[@"secPersonal", @"secExtViol", @"secPolUnr", @"secAreas"];

    NSString *secPerTitle = [[STASDKDataController sharedInstance] localizedStringForKey:@"SEC_PERSONAL"];
    NSString *secExtTitle = [[STASDKDataController sharedInstance] localizedStringForKey:@"SEC_EXT_VIOL"];
    NSString *secPolTitle = [[STASDKDataController sharedInstance] localizedStringForKey:@"SEC_POL_UNR"];
    NSString *secAreasTitle = [[STASDKDataController sharedInstance] localizedStringForKey:@"SEC_AREAS"];

    self.propTitles = [[NSDictionary alloc] initWithObjectsAndKeys:secPerTitle, @"secPersonal",
                  secExtTitle, @"secExtViol",
                  secPolTitle, @"secPolUnr",
                  secAreasTitle, @"secAreas",
                  nil];

    self.availableProps = [[NSMutableArray alloc] init];
    [self setSections];


    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = kSafetyDefaultRowHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;


    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    self.view.backgroundColor = styles.countrySafetyPageBackgroundColor;


    // This is necessary because our xib files are in a separate bundle for the sdk
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    [self.tableView registerNib:[UINib nibWithNibName:@"CardTableViewCell" bundle:bundle] forCellReuseIdentifier:kSafetyCellIdentifier];

}


// Personal Security, Extreme Violence, Political Unrest, Areas To Avoid
// Not all of these sections always have content. This handles that fact by
// removing sections that shouldn't be displayed.
// field :sec_personal,  type: String, localize: true
// field :sec_ext_viol,  type: String, localize: true
// field :sec_pol_unr,   type: String, localize: true
// field :sec_areas,     type: String, localize: true
- (void)setSections {
    for (NSString *prop in self.props) {
        if ([self hasContentFor:prop]) {
            [self.availableProps addObject:prop];
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
    return [self.availableProps count];
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
    view.backgroundColor = styles.countrySafetyPageBackgroundColor;
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    view.backgroundColor = styles.countrySafetyPageBackgroundColor;
    return view;
}


- (BOOL)hasContentFor:(NSString*)prop {
    if (self.country == NULL) {return false;}
    
    SEL selector = NSSelectorFromString(prop);
    IMP imp = [self.country methodForSelector:selector];
    NSString* (*func)(id, SEL) = (void *)imp;
    NSString *val = func(self.country, selector);

    if (val == NULL) {return false;}

    NSString *trimmedString = [val stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];

    return [trimmedString length] > 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    STASDKUICardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSafetyCellIdentifier forIndexPath:indexPath];
    NSInteger sectionIndex = [indexPath section]; // only one row per section so this works fine
    NSString *prop = [self.availableProps objectAtIndex:sectionIndex];
    NSString *title = [self.propTitles objectForKey:prop];

    SEL selector = NSSelectorFromString(prop);
    IMP imp = [self.country methodForSelector:selector];
    NSString* (*func)(id, SEL) = (void *)imp;
    NSString *content = func(self.country, selector);

    cell.titleLbl.text = title;
    cell.bodyLbl.text = content;

    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    cell.backgroundColor = styles.countrySafetyPageBackgroundColor;
    cell.titleLbl.textColor = styles.countrySafetyPageSectionHeaderLblColor;
    cell.bodyLbl.textColor = styles.countrySafetyPageSectionContentLblColor;
    cell.containerView.backgroundColor = styles.countrySafetyPageSectionCardBackgroundColor;

    return cell;
}


@end
