//
//  STASDKUIHospitalRowTableViewCell.h
//  Pods
//
//  Created by Adam St. John on 2017-03-13.
//
//

#import <UIKit/UIKit.h>

@class STASDKMHospital;

@interface STASDKUIHospitalRowTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *hospitalNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *distanceLbl;
@property (weak, nonatomic) IBOutlet UIImageView *emergIconImg;
@property (weak, nonatomic) IBOutlet UIImageView *accreditedIconImg;


- (void)setForHospital:(STASDKMHospital*)hospital;

- (void)setForHospital:(STASDKMHospital*)hospital distance:(double)distance;

@end
