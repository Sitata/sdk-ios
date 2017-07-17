//
//  STASDKUITBSuccessViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-07-17.
//
//

#import "STASDKUITBSuccessViewController.h"
#import "STASDKUIStylesheet.h"
#import "STASDKDataController.h"

@interface STASDKUITBSuccessViewController ()
@property (weak, nonatomic) IBOutlet UILabel *headerLbl;
@property (weak, nonatomic) IBOutlet UIImageView *successImg;
@property (weak, nonatomic) IBOutlet UIView *wrapView;

@end

@implementation STASDKUITBSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.


    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.wrapView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.successImg.tintColor = styles.tripSuccessIconColor;


    self.headerLbl.text = [[STASDKDataController sharedInstance] localizedStringForKey:@"TB_SUCCESS"];
    
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
