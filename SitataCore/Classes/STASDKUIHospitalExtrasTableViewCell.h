//
//  STASDKUIHospitalExtrasTableViewCell.h
//  Pods
//
//  Created by Adam St. John on 2017-03-16.
//
//

#import <UIKit/UIKit.h>

@class STASDKMHospital;

@interface STASDKUIHospitalExtrasTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *emergImg;
@property (weak, nonatomic) IBOutlet UIImageView *accreditedImg;
@property (weak, nonatomic) IBOutlet UILabel *emergLbl;
@property (weak, nonatomic) IBOutlet UILabel *accreditedLbl;




- (void)setForHospital:(STASDKMHospital*)hospital;


@end
