//
//  STASDKUITBDatePickerViewController.h
//  Pods
//
//  Created by Adam St. John on 2017-07-06.
//
//

#import <UIKit/UIKit.h>


@protocol STASDKUITBDatePickerDelegate <NSObject>

- (void)onPickedDate:(NSDate*)date;

@end






@interface STASDKUITBDatePickerViewController : UIViewController

@property (weak, nonatomic) id <STASDKUITBDatePickerDelegate> delegate;
@property (copy, nonatomic) NSString *actionBtnTitle;
@property (copy, nonatomic) NSString *titleBarLblText;
@property (copy, nonatomic) NSDate *minDate;
@property (copy, nonatomic) NSDate *maxDate;

@end
