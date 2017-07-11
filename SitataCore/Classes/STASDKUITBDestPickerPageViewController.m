//
//  STASDKUITBDestPickerPageViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-07-06.
//
//

#import "STASDKUITBDestPickerPageViewController.h"


#import "STASDKUITripBuildItinViewController.h"
#import "STASDKUICountryPickerPopoverViewController.h"
#import "STASDKMCountry.h"
#import "STASDKUITBDatePickerViewController.h"
#import "STASDKDataController.h"
#import "STASDKMDestination.h"


@interface STASDKUITBDestPickerPageViewController () <UIPageViewControllerDelegate, STASDKUICountryPickerPopoverDelegate, STASDKUITBDatePickerDelegate>

@property int currentIndex;
@property STASDKMCountry *country;
@property NSDate* entryDate;
@property NSDate* exitDate;


@end



@implementation STASDKUITBDestPickerPageViewController


const int destPageCount = 3;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Do any additional setup after loading the view.
    self.currentIndex = 0;

    self.entryDate = [[NSDate alloc] init];
    self.exitDate = [[NSDate alloc] init];

    self.delegate = self;

    [self setViewControllers:@[[self viewControllerAtIndex:self.currentIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)nextPage {
    self.currentIndex++;
    [self setViewControllers:@[[self viewControllerAtIndex:self.currentIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
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
    if (index == destPageCount-1) {
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
            // country picking
            STASDKUICountryPickerPopoverViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"countryPickerPopup"];
            vc.delegate = self;
            [vc setForMultiStage];
            page = vc;
            break;
        }
        case 1:
        {
            // entry date picking
            STASDKUITBDatePickerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"tbDatePicker"];

            // TODO: If trip is present, min date could be anything, otherwise, min date is today
            vc.minDate = self.entryDate;
            vc.titleBarLblText = [[STASDKDataController sharedInstance] localizedStringForKey:@"TB_ARRIVAL_TITLE"];
            vc.delegate = self;
            page = vc;
            break;
        }
        case 2:
        {
            // exit date picking
            STASDKUITBDatePickerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"tbDatePicker"];

            vc.minDate = self.entryDate;
            vc.titleBarLblText = [[STASDKDataController sharedInstance] localizedStringForKey:@"TB_LEAVE_TITLE"];
            vc.delegate = self;
            page = vc;
            break;
        }
    }

    return page;
}



#pragma - mark STASDKUICountryPickerPopoverDelegate


// This is called from the popover VC when a country is picked.
- (void)onChangeCountry:(STASDKMCountry*)country {
    if (country != NULL) {
        self.country = country;
        // proceed to next page for date picking
        [self nextPage];
    }
}

#pragma - mark STASDKUITBDatePickerDelegate
- (void)onPickedDate:(NSDate *)date {
    if (self.currentIndex == 1) {
        // picking entry date
        self.entryDate = date;
        [self nextPage];
    } else {
        // picking exit date
        self.exitDate = date;

        // Callback result to parent view controller
        STASDKMDestination *dest = [[STASDKMDestination alloc] init];
        dest.departureDate = self.entryDate;
        dest.returnDate = self.exitDate;
        dest.countryId = self.country.identifier;
        dest.countryCode = self.country.countryCode;
        [self.destPickerDelegate onPickedDestination:dest];

        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}





@end
