//
//  STASDKUITBDatePickerViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-07-06.
//
//

#import "STASDKUITBDatePickerViewController.h"

#import "STASDKDataController.h"

@interface STASDKUITBDatePickerViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionBtn;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property NSDate *pickedDate;

@end

@implementation STASDKUITBDatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (self.minDate) {
        [self.datePicker setMinimumDate:self.minDate];
    }
    
    if (self.maxDate) {
        [self.datePicker setMaximumDate:self.maxDate];
    }

    self.pickedDate = [self.datePicker date];

    if (self.titleBarLblText) {
        self.navBar.topItem.title = self.titleBarLblText;
    }

    NSString *title;
    if (self.actionBtnTitle) {
        title = self.actionBtnTitle;
    } else {
        title = [[STASDKDataController sharedInstance] localizedStringForKey:@"NEXT"];
    }
    [self.actionBtn setTitle:title];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)onPickedRow:(id)sender {
    self.pickedDate = [self.datePicker date];
}

// finish
- (IBAction)onAction:(id)sender {
    [self.delegate onPickedDate:self.pickedDate];
}

@end
