//
//  STASDKUITripBuilderPageViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-06-19.
//
//

#import "STASDKUITripBuilderPageViewController.h"

#import "STASDKController.h"
#import "STASDKDataController.h"
#import "STASDKMTrip.h"
#import "STASDKUITripBuildItinViewController.h"
#import "STASDKUITripMetaCollectionViewController.h"
#import "STASDKUITBSuccessViewController.h"
#import "STASDKUITBIntroViewController.h"
#import "STASDKDefines.h"
#import "STASDKApiTrip.h"
#import "STASDKSync.h"

#import <Realm/Realm.h>


@interface STASDKUITripBuilderPageViewController () <UIPageViewControllerDelegate>


@property int currentIndex;
@property RLMRealm *theRealm;
@property STASDKMTrip *trip;
@property int pageCount;

@end



@implementation STASDKUITripBuilderPageViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.currentIndex = 0;

    self.pageCount = 5;
    STASDKController *ctrl = [STASDKController sharedInstance];
    if (ctrl.skipTBTypes) {
        self.pageCount--;
    }
    if (ctrl.skipTBActivities) {
        self.pageCount--;
    }

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
        self.theRealm = [[STASDKDataController sharedInstance] theRealm];
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
    } else if (self.currentIndex == self.pageCount-2) {
        // second last page
        [self setPreviousButton];
        [self setSaveButton];
    } else if (self.currentIndex == self.pageCount-1) {
        // last page - only close button
        [self setFinishButton];
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

- (void)setActivityButton {
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    self.manualParentViewController.navigationItem.rightBarButtonItem = barButton;
    [activityIndicator startAnimating];
}

- (void)setFinishButton {
    self.manualParentViewController.navigationItem.leftBarButtonItem = NULL;
    NSString *finish = [[STASDKDataController sharedInstance] localizedStringForKey:@"FINISH"];
    self.manualParentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:finish
                                                                                                         style:UIBarButtonItemStylePlain
                                                                                                        target:self
                                                                                                        action:@selector(close)];
}


- (void)doSave {

    [self setActivityButton];

    if ([self isNewTrip]) {
        [self sendTrip:YES];
    } else {
        [self sendTrip:NO];
    }
}

- (bool) isNewTrip {
    return self.theRealm.configuration.inMemoryIdentifier != NULL;
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
    if (self.currentIndex == 1) {
        // trip building, trip must have destinations
        if ([[self.trip destinations] count] > 0) {
            return YES;
        } else {
            [self presentAlert:[[STASDKDataController sharedInstance] localizedStringForKey:@"TB_MUST_HAVE_DEST_TTL"] msg:[[STASDKDataController sharedInstance] localizedStringForKey:@"TB_MUST_HAVE_DEST_MSG"]];
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
    if (index == self.pageCount-1) {
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
            // intro screen
            STASDKUITBIntroViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"tripBuilderIntro"];
            page = vc;
            break;
        }
        case 1:
        {
            // tripBuilderMap
            STASDKUITripBuildItinViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"tripBuilderMap"];
            vc.trip = self.trip;
            vc.theRealm = self.theRealm;
            page = vc;
            break;
        }
        case 2:
        {
            STASDKController *ctrl = [STASDKController sharedInstance];
            if (!ctrl.skipTBTypes) {
                // tripBuilderType
                page = [self pageForTripBuilderType];
            } else {
                if (!ctrl.skipTBActivities) {
                    page = [self pageForTripBuilderActivities];
                } else {
                    page = [self pageForTripBuilderSuccess];
                }
            }
            break;
        }
        case 3:
        {
            STASDKController *ctrl = [STASDKController sharedInstance];
            if (!ctrl.skipTBTypes && !ctrl.skipTBActivities) {
                // tripBuilderAct
                page = [self pageForTripBuilderActivities];
            } else {
                page = [self pageForTripBuilderSuccess];
                
            }
            break;
        }
        case 4:
        {
            // success page - can't navigate backwards, just close button
            page = [self pageForTripBuilderSuccess];
            break;
        }
    }

    return page;
}

- (UIViewController*) pageForTripBuilderType {
    STASDKUITripMetaCollectionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"tripBuilderMeta"];
    enum TripMetaType mode = TripPurpose;
    vc.trip = self.trip;
    vc.mode = mode;
    vc.theRealm = self.theRealm;
    return vc;
}

- (UIViewController*) pageForTripBuilderActivities {
    STASDKUITripMetaCollectionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"tripBuilderMeta"];
    enum TripMetaType mode = TripActivities;
    vc.trip = self.trip;
    vc.mode = mode;
    vc.theRealm = self.theRealm;
    return vc;
}

- (UIViewController*) pageForTripBuilderSuccess {
    STASDKUITBSuccessViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"tripBuilderSuccess"];
    return vc;
}



#pragma mark - Save Trip



- (void)sendTrip:(bool)newTrip {
    if (newTrip) {
        [STASDKApiTrip createTrip:self.trip onFinished:^(STASDKMTrip *trip, NSURLSessionTask *task, NSError *error) {
            [self handleTripResponse:trip error:error];
        }];
    } else {
        [STASDKApiTrip updateTrip:self.trip onFinished:^(STASDKMTrip *trip, NSURLSessionTask *task, NSError *error) {
            [self handleTripResponse:trip error:error];
        }];
    }
}

- (void)handleTripResponse:(STASDKMTrip*)trip error:(NSError*)error {
    if (!error) {
        NSError *writeError;
        [trip resave:&writeError];

        if (writeError != nil) {
            NSLog(@"Failed to save new trip - error: %@", [writeError localizedDescription]);
            [self handleSendTripError];
        } else {
            [STASDKSync syncExtrasFor:trip];
            NSLog(@"Finshed saving trip.");
            [self handleSendTripSuccess];
        }

    } else {
        NSLog(@"Failed to post new trip - error: %@", [error localizedDescription]);
        [self handleSendTripError];
    }
}

- (void)handleSendTripError {
    [self setSaveButton];
    [self presentAlert:[[STASDKDataController sharedInstance] localizedStringForKey:@"TB_SAVE_ERROR_TTL"] msg:[[STASDKDataController sharedInstance] localizedStringForKey:@"TB_SAVE_ERROR_MSG"]];

}

- (void)handleSendTripSuccess {
    NSLog(@"Trip save success!");
    [self nextPage];
}


- (void)presentAlert:(NSString*)title msg:(NSString*)msg {
    UIAlertController *alertCtrl = [UIAlertController
                                    alertControllerWithTitle:title
                                    message:msg
                                    preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:[[STASDKDataController sharedInstance] localizedStringForKey:@"OK"]
                               style:UIAlertActionStyleDefault
                               handler:NULL];
    [alertCtrl addAction:okAction];

    [self presentViewController:alertCtrl animated:YES completion:nil];
}





@end
