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
#import "STASDKSuperFoldCell.h"
#import "STASDKUIStylesheet.h"


@interface STASDKUISafetyDetailsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *props;
@property (strong, nonatomic) NSMutableArray *availableProps;
@property (strong, nonatomic) NSDictionary *propTitles;
@property (strong, nonatomic) NSMutableSet *expandedIndexPaths;

@end

@implementation STASDKUISafetyDetailsViewController

static NSString* const kSafetyCellIdentifier = @"AccordionSafetyCell";

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
    self.tableView.backgroundColor = styles.countrySafetyPageBackgroundColor;
    self.view.backgroundColor = styles.countrySafetyPageBackgroundColor;


    // This is necessary because our xib files are in a separate bundle for the sdk
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    [self.tableView registerNib:[UINib nibWithNibName:@"STASDKSuperFoldCell" bundle:bundle] forCellReuseIdentifier:kSafetyCellIdentifier];

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

// The header and footer in each section are necessary so we can have a space between
// content cells to allow the shadow to be properly displayed.
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return kSectionSeparatorDistance;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kSectionSeparatorDistance;
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



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if ([self.expandedIndexPaths containsObject:indexPath]) {
        STASDKSuperFoldCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
        [cell animateClosed];
        [self.expandedIndexPaths removeObject:indexPath];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [self.expandedIndexPaths addObject:indexPath];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

        STASDKSuperFoldCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
        [cell animateOpen];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    STASDKSuperFoldCell *cell = [tableView dequeueReusableCellWithIdentifier:kSafetyCellIdentifier forIndexPath:indexPath];

    NSInteger sectionIndex = [indexPath section]; // only one row per section so this works fine
    NSString *prop = [self.availableProps objectAtIndex:sectionIndex];
    NSString *title = [self.propTitles objectForKey:prop];

    SEL selector = NSSelectorFromString(prop);
    IMP imp = [self.country methodForSelector:selector];
    NSString* (*func)(id, SEL) = (void *)imp;
    NSString *content = func(self.country, selector);

    cell.withDetails = [self.expandedIndexPaths containsObject:indexPath];
    cell.sectionLbl.text = title;
    cell.contentLbl.text = content;
    [cell setShadow];

    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    cell.backgroundColor = styles.countrySafetyPageBackgroundColor;
    cell.sectionLbl.textColor = styles.countrySafetyPageSectionHeaderLblColor;
    cell.contentLbl.textColor = styles.countrySafetyPageSectionContentLblColor;
    cell.titleContainer.backgroundColor = styles.countrySafetyPageSectionHeaderBackgroundColor;
    cell.detailContainerView.backgroundColor = styles.countrySafetyPageSectionBackgroundColor;

    return cell;
}


@end
