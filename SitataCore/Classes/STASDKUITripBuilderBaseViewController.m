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


    // Back button in nav
    NSString *close = [[STASDKDataController sharedInstance] localizedStringForKey:@"CLOSE"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:close
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(close:)];

    // Colors
    [STASDKUIUtility applyStylesheetToNavigationController:self.navigationController];

    self.trip = [STASDKMTrip findBy:self.tripId];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"embedTripBuilder"]) {

        STASDKUITripBuilderPageViewController *vc = [segue destinationViewController];
        vc.trip = self.trip;
    }
}


@end
