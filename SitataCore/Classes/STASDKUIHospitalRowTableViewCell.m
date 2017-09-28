//
//  STASDKUIHospitalRowTableViewCell.m
//  Pods
//
//  Created by Adam St. John on 2017-03-13.
//
//

#import "STASDKUIHospitalRowTableViewCell.h"

#import "STASDKMHospital.h"
#import "STASDKUI.h"
#import "STASDKUIStylesheet.h"

@implementation STASDKUIHospitalRowTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    self.hospitalNameLbl.textColor = styles.hospitalRowHosptialNameLblColor;
    self.hospitalNameLbl.font = styles.rowTextFont;
    self.distanceLbl.textColor = styles.hospitalRowHosptialDistanceLblColor;
    self.distanceLbl.font = styles.rowSecondaryTextFont;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (void)setForHospital:(STASDKMHospital*)hospital {
    [self setBasics:hospital];
    [self.distanceLbl setAlpha:0.0];
}

- (void)setForHospital:(STASDKMHospital*)hospital distance:(double)distance {
    [self setBasics:hospital];
    [self.distanceLbl setAlpha:1.0];

    NSString *distStr = [STASDKUI formattedDistance:distance];
    self.distanceLbl.text = distStr;

}

- (void)setBasics:(STASDKMHospital*)hospital {
    self.hospitalNameLbl.text = hospital.name;
    if ([hospital isAccredited]) {
        [self.accreditedIconImg setAlpha:1.0];
    } else {
        [self.accreditedIconImg setAlpha:0.1];
    }

    if ([hospital emergency]) {
        [self.emergIconImg setAlpha:1.0];
    } else {
        [self.emergIconImg setAlpha:0.1];
    }
    
}

@end
