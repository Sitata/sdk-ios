//
//  STASDKUITBIntroViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-07-24.
//
//

#import "STASDKUITBIntroViewController.h"

@interface STASDKUITBIntroViewController ()
@property (weak, nonatomic) IBOutlet UILabel *headerLbl;

@end

@implementation STASDKUITBIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.headerLbl.textColor = [UIColor darkGrayColor];
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

@end
