//
//  STASDKUIContactDetailTableViewCell.h
//  Pods
//
//  Created by Adam St. John on 2017-03-15.
//
//

#import <UIKit/UIKit.h>

@class STASDKMContactDetail;
@class STASDKMHospital;

@interface STASDKUIContactDetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *valueLbl;
@property (weak, nonatomic) IBOutlet UILabel *noteLbl;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;

@property (nonatomic, strong) STASDKMContactDetail *contactDetail;
@property (nonatomic, strong) STASDKMHospital *hospital;

@property BOOL forcePhone;


- (void)setForContactDetail:(STASDKMContactDetail*)detail;
- (void)setForAddress:(NSString*)addressStr;

@end
