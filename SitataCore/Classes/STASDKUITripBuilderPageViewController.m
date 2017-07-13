//
//  STASDKUITripBuilderPageViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-06-19.
//
//

#import "STASDKUITripBuilderPageViewController.h"

#import "STASDKDataController.h"
#import "STASDKMTrip.h"
#import "STASDKUITripBuildItinViewController.h"
#import "STASDKUITripMetaCollectionViewController.h"
#import "STASDKDefines.h"

#import <Realm/Realm.h>


@interface STASDKUITripBuilderPageViewController () <UIPageViewControllerDelegate>


@property int currentIndex;
@property RLMRealm *theRealm;
@property STASDKMTrip *trip;

@end



@implementation STASDKUITripBuilderPageViewController

const int pageCount = 3;


- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.currentIndex = 0;

    [self loadTrip];

    self.delegate = self;


    [self setActionButtons];

    [self setViewControllers:@[[self viewControllerAtIndex:self.currentIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// if we don't already have a trip, create a new one for the purposes of sending to the server
- (void) loadTrip {
    self.trip = [STASDKMTrip findBy:self.tripId];

    if (self.trip == NULL) {

        // querying on destinations and such won't work unless the trip is persisted into
        // a realm, but we don't want to put it into our default disk based realm... so
        // we create a temporary in-memory store instead.
        RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
        config.inMemoryIdentifier = @"TBMemoryRealm";
        self.theRealm = [RLMRealm realmWithConfiguration:config error:NULL];

        self.trip = [[STASDKMTrip alloc] init];
        [self.theRealm transactionWithBlock:^{
            [self.theRealm addObject:self.trip];
        }];
    } else {
        // trip is existing so we use the default realm
        self.theRealm = [RLMRealm defaultRealm];
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setActionButtons {
    if (self.currentIndex == 0) {
        // first page
        [self setCloseButton];
        [self setNextButton];
    } else if (self.currentIndex == pageCount-1) {
        // last page
        [self setPreviousButton];
        [self setSaveButton];
    } else {
        // in between pages
        [self setPreviousButton];
        [self setNextButton];
    }
}

- (void)setCloseButton {
    // Back button in nav
    NSString *close = [[STASDKDataController sharedInstance] localizedStringForKey:@"CLOSE"];
    self.manualParentViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:close
                                                                                                        style:UIBarButtonItemStylePlain
                                                                                                       target:self
                                                                                                       action:@selector(close)];
}
- (void)setNextButton {
    // next button in nav
    NSString *next = [[STASDKDataController sharedInstance] localizedStringForKey:@"NEXT"];
    self.manualParentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:next
                                                                                                         style:UIBarButtonItemStylePlain
                                                                                                        target:self
                                                                                                        action:@selector(nextPage)];
}
- (void)setPreviousButton {
    NSString *prev = [[STASDKDataController sharedInstance] localizedStringForKey:@"PREVIOUS"];
    self.manualParentViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:prev
                                                                                                         style:UIBarButtonItemStylePlain
                                                                                                        target:self
                                                                                                        action:@selector(prevPage)];
}
- (void)setSaveButton {
    // next button in nav
    NSString *next = [[STASDKDataController sharedInstance] localizedStringForKey:@"SAVE"];
    self.manualParentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:next
                                                                                                         style:UIBarButtonItemStylePlain
                                                                                                        target:self
                                                                                                        action:@selector(doSave)];
}



- (void)doSave {
    // TODO:
    //  - swap button with activity indicator... ensure we can handle failed case and put button back
    //  - do saving and sync process
    NSLog(@"TODO: DO SAVE TRIP!");
}




- (void)close {
    [self.manualParentViewController dismissViewControllerAnimated:YES completion:NULL];
}


- (void)nextPage {
    if ([self checkAllowedNextPage]) {
        self.currentIndex++;
        [self setActionButtons];
        [self setViewControllers:@[[self viewControllerAtIndex:self.currentIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    }
}

- (void)prevPage {
    self.currentIndex--;
    [self setActionButtons];
    [self setViewControllers:@[[self viewControllerAtIndex:self.currentIndex]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:NULL];
}

- (bool)checkAllowedNextPage {
    if (self.currentIndex == 0) {
        // trip building, trip must have destinations
        if ([[self.trip destinations] count] > 0) {
            return YES;
        } else {
            UIAlertController *alertCtrl = [UIAlertController
                                            alertControllerWithTitle:[[STASDKDataController sharedInstance] localizedStringForKey:@"TB_MUST_HAVE_DEST_TTL"]
                                            message:[[STASDKDataController sharedInstance] localizedStringForKey:@"TB_MUST_HAVE_DEST_MSG"]
                                            preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:[[STASDKDataController sharedInstance] localizedStringForKey:@"OK"]
                                       style:UIAlertActionStyleDefault
                                       handler:NULL];
            [alertCtrl addAction:okAction];

            [self presentViewController:alertCtrl animated:YES completion:nil];
            return NO;
        }
    } else {
        return YES;
    }
}


#pragma mark - Page View Ctrl

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    int index = self.currentIndex;
    if (index <= 0) {
        return NULL;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {

    int index = self.currentIndex;
    if (index == pageCount-1) {
        return NULL;
    }
    index++;
    return [self viewControllerAtIndex:index];

}

- (UIViewController*)viewControllerAtIndex:(int)index {

    UIViewController *page;
    
    switch(index) {
        case 0:
        {
            // tripBuilderMap
            STASDKUITripBuildItinViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"tripBuilderMap"];
            vc.trip = self.trip;
            vc.theRealm = self.theRealm;
            page = vc;
            break;
        }
        case 1:
        {
            // tripBuilderType
            STASDKUITripMetaCollectionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"tripBuilderMeta"];
            enum TripMetaType mode = TripPurpose;
            vc.trip = self.trip;
            vc.mode = mode;
            vc.theRealm = self.theRealm;
            page = vc;
            break;
        }
        case 2:
            // tripBuilderAct
        {
            STASDKUITripMetaCollectionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"tripBuilderMeta"];
            enum TripMetaType mode = TripActivities;
            vc.trip = self.trip;
            vc.mode = mode;
            vc.theRealm = self.theRealm;
            page = vc;
            break;
        }
    }

    return page;
}




@end
