//
//  STASDKUIStylesheet.m
//  Pods
//
//  Created by Adam St. John on 2017-03-17.
//
//

#import "STASDKUIStylesheet.h"

@implementation STASDKUIStylesheet

#pragma mark Singleton
+ (id)sharedInstance {
    static STASDKUIStylesheet *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}



- (id)init
{
    self = [super init];
    if (!self) return nil;


    UIColor *lightestGrayColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0]; // #F9F9F9
    UIColor *deepBlueColor = [UIColor colorWithRed:11/255.0 green:79/255.0 blue:188/255.0 alpha:1.0]; // #0b4fbc
    UIColor *mediumGrey = [UIColor colorWithRed:142/255.0 green:142/255.0 blue:142/255.0 alpha:1.0]; // #8e8e8e
    UIColor *successGreen = [UIColor colorWithRed:39/255.0 green:174/255.0 blue:96/255.0 alpha:1.0]; // #27ae60


//    @property (nonatomic, retain) UIColor *navigationBarTextShadowColor;
//    @property (nonatomic, retain) UIImage *navigationBarBackgroundImage;
//    @property (nonatomic, retain) UIFont  *navigationBarFont;
//    @property (nonatomic, assign) BOOL navigationBarTranslucency;

    self.headingFont = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
    self.subHeadingFont = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
    self.bodyFont = [UIFont systemFontOfSize:17];
    self.rowTextFont = [UIFont systemFontOfSize:15];
    self.rowSecondaryTextFont = [UIFont systemFontOfSize:14];
    self.titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    self.buttonFont = [UIFont systemFontOfSize:15];

    self.headingTextColor = [UIColor darkGrayColor];
    self.subheadingTextColor = [UIColor darkGrayColor];
    self.bodyTextColor = [UIColor darkGrayColor];
    self.titleTextColor = [UIColor darkGrayColor];



    self.navigationBarBackgroundColor = deepBlueColor;
    self.navigationBarTextColor = [UIColor whiteColor];
    self.navigationBarTintColor = [UIColor whiteColor];
    self.navigationBarActivityIndicatorColor = [UIColor whiteColor];

    self.oddCellBackgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]; // #F2F2F2
    self.evenCellBackgroundColor = lightestGrayColor;




    // Alerts & Advisories
    self.alertAdvisoryRowDateLblColor = [UIColor lightGrayColor];
    self.alertAdvisoryRowHeadlineLblColor = [UIColor darkGrayColor];
    self.alertsAdvisoriesListPageBackgroundColor = lightestGrayColor;
    self.alertPageBackgroundColor = lightestGrayColor;
//    self.alertsRowNormalFont
//    self.alertsRowUnreadFont

    // Health objects
    self.diseaseRowNameLblColor = [UIColor darkGrayColor];
    self.diseaseListPageBackgroundColor = lightestGrayColor;
    self.diseasePageBackgroundColor = lightestGrayColor;

    self.medicationRowNameLblColor = [UIColor darkGrayColor];
    self.medicationListPageBackgroundColor = lightestGrayColor;
    self.medicationPageBackgroundColor = lightestGrayColor;

    self.vaccinationRowNameLblColor = [UIColor darkGrayColor];
    self.vaccinationListPageBackgroundColor = lightestGrayColor;
    self.vaccinationPageBackgroundColor = lightestGrayColor;

    // Hospitals
    self.hospitalListPageBackgroundColor = lightestGrayColor;
    self.hospitalPageBackgroundColor = lightestGrayColor;
    self.hospitalRowHosptialNameLblColor = self.bodyTextColor;
    self.hospitalRowHosptialDistanceLblColor = [UIColor lightGrayColor];
    self.hospitalNameLblColor = self.headingTextColor;
    self.hospitalDistanceLblColor = self.bodyTextColor;
    self.hospitalEmergencyLblColor = self.subheadingTextColor;
//    self.hospitalEmergencyLblFont
    self.hospitalAccredationLblColor = self.subheadingTextColor;
//    self.hospitalAccredationLblFont

    self.hospitalContactLblColor = self.bodyTextColor;
    self.hospitalContactNoteLblColor = [UIColor lightGrayColor];
    self.hospitalContactBtnLblColor = deepBlueColor;

    // Disease
    self.diseaseAboutPageBackgroundColor = lightestGrayColor;
    self.diseaseAboutPageSectionCardBackgroundColor = [UIColor whiteColor];
    self.diseaseAboutPageSectionHeaderLblColor = self.headingTextColor;
    self.diseaseAboutPageSectionContentLblColor = self.bodyTextColor;

    // Country Safety Page
    self.countrySafetyPageBackgroundColor = lightestGrayColor;
    self.countrySafetyPageSectionCardBackgroundColor = [UIColor whiteColor];
    self.countrySafetyPageSectionHeaderLblColor = self.headingTextColor;
    self.countrySafetyPageSectionContentLblColor = self.bodyTextColor;

    // Emergency Numbers
    self.emergNumbersPageBackgroundColor = lightestGrayColor;
    self.emergNumbersPageTitleColor = self.headingTextColor;
    self.emergNumberContactLblColor = self.bodyTextColor;
    self.emergNumberContactNoteLblColor = [UIColor lightGrayColor];
    self.emergNumberContactBtnLblColor = deepBlueColor;

    // Country Picker
    self.countrySwitcherBackgroundColor = deepBlueColor; //[UIColor lightGrayColor];
    self.countrySwitcherTitleColor = [UIColor whiteColor]; //[UIColor darkGrayColor];
    self.countrySwitcherButtonColor = [UIColor whiteColor]; //[UIColor darkGrayColor];


    // Trip Builder
    self.tripTypeIconColor = mediumGrey;
    self.tripMetaCardActiveColor = self.navigationBarBackgroundColor;
    self.tripSuccessIconColor = successGreen;
    self.tripTimelineColor = [UIColor darkGrayColor];
    self.tripBuilderRemoveColor = [UIColor darkGrayColor];
    self.tripBuilderAddColor = [UIColor darkGrayColor];
    

    return self;
}


// some of the other color settings are depenent upon these and so we must re-set the dependent colors


//self.subheadingTextColor = [UIColor darkGrayColor];
//self.bodyTextColor = [UIColor darkGrayColor];
//self.titleTextColor = [UIColor darkGrayColor];



- (void) setHeadingTextColor:(UIColor *)headingTextColor {
    _headingTextColor = headingTextColor;
    self.hospitalNameLblColor = headingTextColor;
    self.diseaseAboutPageSectionHeaderLblColor = headingTextColor;
    self.countrySafetyPageSectionHeaderLblColor = headingTextColor;
    self.emergNumbersPageTitleColor = headingTextColor;

}

- (void)setSubheadingTextColor:(UIColor *)subheadingTextColor {
    _subheadingTextColor = subheadingTextColor;
    self.hospitalEmergencyLblColor = subheadingTextColor;
    self.hospitalAccredationLblColor = subheadingTextColor;
}

- (void)setBodyTextColor:(UIColor *)bodyTextColor {
    _bodyTextColor = bodyTextColor;
    self.hospitalRowHosptialNameLblColor = bodyTextColor;
    self.hospitalDistanceLblColor = bodyTextColor;
    self.hospitalContactLblColor = bodyTextColor;
    self.diseaseAboutPageSectionContentLblColor = bodyTextColor;
    self.countrySafetyPageSectionContentLblColor = bodyTextColor;
    self.emergNumberContactLblColor = bodyTextColor;
}





@end
