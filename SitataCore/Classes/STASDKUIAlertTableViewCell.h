//
//  STASDKUIAlertTableViewCell.h
//  Pods
//
//  Created by Adam St. John on 2017-02-11.
//
//

#import <UIKit/UIKit.h>
#import "STASDKUI.h"

@class STASDKMAdvisory;
@class STASDKMAlert;

@interface STASDKUIAlertTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet UILabel *headlineLbl;


// Set the alert for the view
- (void)setForAlert:(STASDKMAlert*)alert;

- (void)setForAdvisory:(STASDKMAdvisory*)advisory;

- (void)setForEmpty:(InfoType)mode;


@end
