//
//  STASDKUISafetyPageViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-03-09.
//
//

#import "STASDKUISafetyPageViewController.h"

#import "STASDKUICountrySwitcherViewController.h"
#import "STASDKUISafetyDetailsViewController.h"

#import "STASDKMTrip.h"
#import "STASDKMDestination.h"
#import "STASDKMCountry.h"

@interface STASDKUISafetyPageViewController ()

@property int currentIndex;

@end

@implementation STASDKUISafetyPageViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.currentIndex = 0;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCountryChange:) name:NotifyCountrySwitcherChanged object:NULL];


    [self setViewControllers:@[[self viewControllerAtIndex:self.currentIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)handleCountryChange:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    int newIndex = [[userInfo valueForKey:NotifyKeyCountriesIndex] intValue];

    UIPageViewControllerNavigationDirection direction;
    if (newIndex > self.currentIndex) {
        direction = UIPageViewControllerNavigationDirectionForward;
    } else {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    [self setViewControllers:@[[self viewControllerAtIndex:newIndex]] direction:direction animated:YES completion:NULL];
    self.currentIndex = newIndex;
}



#pragma mark - PageViewController

- (UIViewController*)viewControllerAtIndex:(int)index {
    STASDKUISafetyDetailsViewController *page = (STASDKUISafetyDetailsViewController*) [self.storyboard instantiateViewControllerWithIdentifier:@"safetyDetailCtrl"];

    // If no countries, most likely haven't synced enough yet OR there isn't
    // a currentTrip at the moment.
    if ([self.countries count] > 0) {
        STASDKMCountry *country = [self.countries objectAtIndex:index];
        page.country = country;
        return page;
    } else {
        // TODO: Maybe a separate view controller to display no safety
        //       page to user
        return page;
    }
}



- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {

    int index = self.currentIndex;
    if (index <= 0) {
        return NULL;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController {

    int index = self.currentIndex;
    if (index == [self.countries count] -1 || index == NSNotFound) {
        return NULL;
    }
    index++;
    return [self viewControllerAtIndex:index];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
