//
//  STASDKUIAlertTableViewCell.m
//  Pods
//
//  Created by Adam St. John on 2017-02-11.
//
//

#import "STASDKUIAlertTableViewCell.h"
#import "STASDKMAlert.h"
#import "STASDKMAdvisory.h"
#import "STASDKDataController.h"
#import "STASDKUI.h"
#import "STASDKUIStylesheet.h"

@implementation STASDKUIAlertTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


// Set the alert for the view
- (void)setForAlert:(STASDKMAlert*)alert {
    [self.headlineLbl setText:alert.headline];
    [self.dateLbl setText:[STASDKUI dateDisplayString:alert.updatedAt]];
    [self applyColors];

    if (alert._read) {
        [self setRead];
    } else {
        [self setUnread];
    }
}

- (void)setForAdvisory:(STASDKMAdvisory*)advisory {
    [self.headlineLbl setText:advisory.headline];
    [self.dateLbl setText:[STASDKUI dateDisplayString:advisory.updatedAt]];
    [self applyColors];

    if (advisory._read) {
        [self setRead];
    } else {
        [self setUnread];
    }
}

- (void)setForEmpty:(InfoType)mode {
    [self.dateLbl removeFromSuperview];
    NSString *key;

    if (mode == Alerts) {
        key = @"NO_ALERTS";
    } else {
        key = @"NO_ADVISORIES";
    }
    [self.headlineLbl setText:[[STASDKDataController sharedInstance] localizedStringForKey:key]];
}

- (void)applyColors {
    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];

    self.dateLbl.textColor = styles.alertAdvisoryRowDateLblColor;
    self.headlineLbl.textColor = styles.alertAdvisoryRowHeadlineLblColor;
    if (styles.rowTextFont) {
        self.headlineLbl.font = styles.rowTextFont;
    }
    if (styles.rowSecondaryTextFont) {
        self.dateLbl.font = styles.rowSecondaryTextFont;
    }
    if (styles.alertsRowNormalFont) {
        self.headlineLbl.font = styles.alertsRowNormalFont;
    }
}

- (void)setUnread {
    // make bold
    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];

    UIFontDescriptor *headDesc = [[[self.headlineLbl font] fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    [self.headlineLbl setFont:[UIFont fontWithDescriptor:headDesc size:0]];

    if (styles.alertsRowUnreadFont) {
        self.headlineLbl.font = styles.alertsRowUnreadFont;
    }
}

- (void)setRead {
    // make regular ( not bold )
    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];

    UIFontDescriptor *headDesc = [[[self.headlineLbl font] fontDescriptor] fontDescriptorWithSymbolicTraits:0];
    [self.headlineLbl setFont:[UIFont fontWithDescriptor:headDesc size:0]];

    if (styles.alertsRowNormalFont) {
        self.headlineLbl.font = styles.alertsRowNormalFont;
    }
}




@end
