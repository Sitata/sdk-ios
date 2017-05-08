//
//  STASDKUIHospitalExtrasTableViewCell.m
//  Pods
//
//  Created by Adam St. John on 2017-03-16.
//
//

#import "STASDKUIHospitalExtrasTableViewCell.h"

#import "STASDKMHospital.h"
#import "STASDKDataController.h"
#import "STASDKUIStylesheet.h"

@implementation STASDKUIHospitalExtrasTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    self.accreditedLbl.textColor = styles.hospitalAccredationLblColor;
    self.emergLbl.textColor = styles.hospitalEmergencyLblColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setForHospital:(STASDKMHospital*)hospital {
    if ([hospital isAccredited]) {
        [self.accreditedImg setAlpha:1.0];
        self.accreditedLbl.text = [[STASDKDataController sharedInstance] localizedStringForKey:@"HOSP_ACCRED"];
    } else {
        [self.accreditedImg setAlpha:0.1];
        self.accreditedLbl.text = [[STASDKDataController sharedInstance] localizedStringForKey:@"HOSP_NOT_ACCRED"];
    }

    if ([hospital emergency]) {
        [self.emergImg setAlpha:1.0];
        self.emergLbl.text = [[STASDKDataController sharedInstance] localizedStringForKey:@"HOSP_EMERG"];
    } else {
        [self.emergImg setAlpha:0.1];
        self.emergLbl.text = [[STASDKDataController sharedInstance] localizedStringForKey:@"HOSP_NOT_EMERG"];
    }
}

@end
