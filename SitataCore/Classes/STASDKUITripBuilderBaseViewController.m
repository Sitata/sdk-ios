//
//  STASDKUITripBuilderBaseViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-07-03.
//
//

#import "STASDKUITripBuilderBaseViewController.h"

#import "STASDKUITripBuilderPageViewController.h"
#import "STASDKDataController.h"
#import "STASDKUIUtility.h"
#import "STASDKMTrip.h"

@interface STASDKUITripBuilderBaseViewController ()

@property (nonatomic) STASDKMTrip *trip;

@end

@implementation STASDKUITripBuilderBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.


    // next and close buttons are set in child page view controller

    // Colors
    [STASDKUIUtility applyStylesheetToNavigationController:self.navigationController];

    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"embedTripBuilder"]) {

        STASDKUITripBuilderPageViewController *vc = [segue destinationViewController];
        vc.manualParentViewController = self;
        vc.tripId = self.tripId;
    }
}


@end
