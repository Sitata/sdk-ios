//
//  STASDKUICountryPickerPopoverViewController.h
//  Pods
//
//  Created by Adam St. John on 2017-03-17.
//
//

#import <UIKit/UIKit.h>

@class STASDKUIEmergNumbersViewController;
@class STASDKMCountry;


@protocol STASDKUICountryPickerPopoverDelegate <NSObject>

- (void)onChangeCountry:(STASDKMCountry*)country;

@end





@interface STASDKUICountryPickerPopoverViewController : UIViewController

@property (weak, nonatomic) id <STASDKUICountryPickerPopoverDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionBtn;


- (void)setForMultiStage;

- (STASDKMCountry*)chosenCountry;

@end
