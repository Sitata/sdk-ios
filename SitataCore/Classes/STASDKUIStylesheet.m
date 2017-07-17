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



    self.navigationBarBackgroundColor = deepBlueColor;
    self.navigationBarTextColor = [UIColor whiteColor];
    self.navigationBarTintColor = [UIColor whiteColor];
    self.navigationBarActivityIndicatorColor = [UIColor whiteColor];

    self.oddCellBackgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]; // #F2F2F2
    self.evenCellBackgroundColor = lightestGrayColor;


//    @property (nonatomic, retain) UIColor *navigationBarTextShadowColor;
//    @property (nonatomic, retain) UIImage *navigationBarBackgroundImage;
//    @property (nonatomic, retain) UIFont  *navigationBarFont;
//    @property (nonatomic, assign) BOOL navigationBarTranslucency;



    // Alerts & Advisories
    self.alertAdvisoryRowDateLblColor = [UIColor lightGrayColor];
    self.alertAdvisoryRowHeadlineLblColor = [UIColor darkGrayColor];
    self.alertsAdvisoriesListPageBackgroundColor = lightestGrayColor;
    self.alertPageBackgroundColor = lightestGrayColor;
    

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
    self.hospitalRowHosptialNameLblColor = [UIColor darkGrayColor];
    self.hospitalRowHosptialDistanceLblColor = [UIColor lightGrayColor];
    self.hospitalNameLblColor = [UIColor darkGrayColor];
    self.hospitalDistanceLblColor = [UIColor darkGrayColor];
    self.hospitalEmergencyLblColor = [UIColor darkGrayColor];
    self.hospitalAccredationLblColor = [UIColor darkGrayColor];

    self.hospitalContactLblColor = [UIColor darkGrayColor];
    self.hospitalContactNoteLblColor = [UIColor lightGrayColor];
    self.hospitalContactBtnLblColor = deepBlueColor;

    // Disease
    self.diseaseAboutPageBackgroundColor = lightestGrayColor;
    self.diseaseAboutPageSectionCardBackgroundColor = [UIColor whiteColor];
    self.diseaseAboutPageSectionHeaderLblColor = [UIColor darkGrayColor];
    self.diseaseAboutPageSectionContentLblColor = [UIColor darkGrayColor];

    // Country Safety Page
    self.countrySafetyPageBackgroundColor = lightestGrayColor;
    self.countrySafetyPageSectionCardBackgroundColor = [UIColor whiteColor];
    self.countrySafetyPageSectionHeaderLblColor = [UIColor darkGrayColor];
    self.countrySafetyPageSectionContentLblColor = [UIColor darkGrayColor];

    // Emergency Numbers
    self.emergNumbersPageBackgroundColor = lightestGrayColor;
    self.emergNumbersPageTitleColor = [UIColor darkGrayColor];
    //self.emergNumbersPageChangeBtnColor = [UIColor blueColor];
    self.emergNumberContactLblColor = [UIColor darkGrayColor];
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

    return self;
}




@end
