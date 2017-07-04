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


@interface STASDKUITripBuilderPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>


@property int currentIndex;

@end



@implementation STASDKUITripBuilderPageViewController

const int pageCount = 3;


- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.currentIndex = 0;

    self.delegate = self;
    self.dataSource = self;


    [self setViewControllers:@[[self viewControllerAtIndex:self.currentIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



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
            page = vc;
            break;
        }
        case 1:
            // tripBuilderType
            page = [self.storyboard instantiateViewControllerWithIdentifier:@"tripBuilderType"];
            break;
        case 2:
            // tripBuilderAct
            page = [self.storyboard instantiateViewControllerWithIdentifier:@"tripBuilderAct"];
            break;
    }

    return page;
}




@end
