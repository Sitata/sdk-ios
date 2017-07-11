//
//  STASDKUILocationSearchTableViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-07-10.
//
//

#import "STASDKUILocationSearchTableViewController.h"

#import <MapKit/MapKit.h>

#import "STASDKDataController.h"
#import "STASDKApiMisc.h"
#import "STASDKMDestinationLocation.h"
#import "STASDKMDestination.h"

@interface STASDKUILocationSearchTableViewController ()

@property NSMutableArray *matchingItems;
@property NSTimer *searchTimer;

@end

@implementation STASDKUILocationSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.matchingItems = [[NSMutableArray alloc] init];

    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.matchingItems.count > 0) {
        return self.matchingItems.count;
    } else {
        return 1; // not found row
    }

}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    UIImage *img = [UIImage imageNamed:@"PoweredByGoogle" inBundle:bundle compatibleWithTraitCollection:nil];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:imgView];


    [imgView.rightAnchor constraintEqualToAnchor:view.rightAnchor constant:-5].active = TRUE;
    [imgView.centerYAnchor constraintEqualToAnchor:view.centerYAnchor].active = TRUE;


    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 50.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    if (self.matchingItems.count > 0) {
        STASDKMDestinationLocation *loc = [self.matchingItems objectAtIndex:[indexPath row]];
        cell.textLabel.text = loc._longName;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        cell.textLabel.text = [[STASDKDataController sharedInstance] localizedStringForKey:@"TB_NO_CITIES"];
        cell.textLabel.font = [UIFont systemFontOfSize:10.0];
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }
    
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.matchingItems.count > 0) {
        // sending back to delegate
        STASDKMDestinationLocation *loc = [self.matchingItems objectAtIndex:[indexPath row]];
        [self.delegate onSelectedLocation:loc forDestination:self.currentDestination];

        // reset results
        [self.matchingItems removeAllObjects];
        [self.tableView reloadData];
    } else {
        // can't select 'no results' row
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}





#pragma mark - UISearchResultsUpdating
- (void) updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *text = searchController.searchBar.text;
    if (text && text.length > 1) {

        NSTimeInterval interval = 0.3;

        if (self.searchTimer) {
            [self.searchTimer invalidate];
            self.searchTimer = NULL;
        }

        self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(doSearch:) userInfo:searchController repeats:NO];
    }
}

- (void)doSearch:(NSTimer *)timer {
    UISearchController *searchCtrl = (UISearchController*) [timer userInfo];
    NSString *query = searchCtrl.searchBar.text;


    [STASDKApiMisc googleFetchCitySuggestions:query inCountry:self.currentDestination.countryCode onFinished:^(NSMutableArray *results, NSURLSessionDataTask *task, NSError *error) {
        if (!error) {
            self.matchingItems = results;
            [self.tableView reloadData];
        }
    }];
}

@end
