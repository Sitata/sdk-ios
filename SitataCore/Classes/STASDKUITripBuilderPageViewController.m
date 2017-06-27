//
//  STASDKUITripBuilderPageViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-06-19.
//
//

#import "STASDKUITripBuilderPageViewController.h"

@interface STASDKUITripBuilderPageViewController ()

@end

@implementation STASDKUITripBuilderPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.delegate = self;
    self.dataSource = self;
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


#pragma mark - 

@end
