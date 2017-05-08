//
//  STASDKUIStylesheet.h
//  Pods
//
//  Created by Adam St. John on 2017-03-17.
//
//

#import <Foundation/Foundation.h>

@interface STASDKUIStylesheet : NSObject

// Singleton
+ (STASDKUIStylesheet*)sharedInstance;

//@property (nonatomic, retain) UIColor *tintColor;
//@property (nonatomic, retain) UIColor *tableViewBackgroundColor;
//@property (nonatomic, retain) UIColor *loadingViewBackgroundColor;
//@property (nonatomic, assign) UIStatusBarStyle preferredStatusBarStyle;


#pragma mark - Navigation Bar

@property (nonatomic, retain) UIColor *navigationBarBackgroundColor;
@property (nonatomic, retain) UIColor *navigationBarTextColor;
@property (nonatomic, retain) UIColor *navigationBarTextShadowColor;
@property (nonatomic, retain) UIImage *navigationBarBackgroundImage;
@property (nonatomic, retain) UIFont  *navigationBarFont;
@property (nonatomic, retain) UIColor *navigationBarTintColor;
@property (nonatomic, retain) UIColor *navigationBarActivityIndicatorColor;
@property (nonatomic, assign) BOOL navigationBarTranslucency;



#pragma mark - General Tables
@property (nonatomic, retain) UIColor *oddCellBackgroundColor;
@property (nonatomic, retain) UIColor *evenCellBackgroundColor;

#pragma mark - Alerts & Advisories
@property (nonatomic, retain) UIColor *alertAdvisoryRowDateLblColor;
@property (nonatomic, retain) UIColor *alertAdvisoryRowHeadlineLblColor;
@property (nonatomic, retain) UIColor *alertsAdvisoriesListPageBackgroundColor;
@property (nonatomic, retain) UIColor *alertPageBackgroundColor;

#pragma mark - Diseases
@property (nonatomic, retain) UIColor *diseaseRowNameLblColor;
@property (nonatomic, retain) UIColor *diseaseListPageBackgroundColor;
@property (nonatomic, retain) UIColor *diseasePageBackgroundColor;
@property (nonatomic, retain) UIColor *diseaseAboutPageBackgroundColor;
@property (nonatomic, retain) UIColor *diseaseAboutPageSectionHeaderLblColor;
@property (nonatomic, retain) UIColor *diseaseAboutPageSectionHeaderBackgroundColor;
@property (nonatomic, retain) UIColor *diseaseAboutPageSectionContentLblColor;
@property (nonatomic, retain) UIColor *diseaseAboutPageSectionBackgroundColor;



#pragma mark - Vaccinations
@property (nonatomic, retain) UIColor *vaccinationRowNameLblColor;
@property (nonatomic, retain) UIColor *vaccinationListPageBackgroundColor;
@property (nonatomic, retain) UIColor *vaccinationPageBackgroundColor;

#pragma mark - Medications
@property (nonatomic, retain) UIColor *medicationRowNameLblColor;
@property (nonatomic, retain) UIColor *medicationListPageBackgroundColor;
@property (nonatomic, retain) UIColor *medicationPageBackgroundColor;

#pragma mark - Hospitals
@property (nonatomic, retain) UIColor *hospitalListPageBackgroundColor;
@property (nonatomic, retain) UIColor *hospitalRowHosptialNameLblColor;
@property (nonatomic, retain) UIColor *hospitalRowHosptialDistanceLblColor;
@property (nonatomic, retain) UIColor *hospitalPageBackgroundColor;
@property (nonatomic, retain) UIColor *hospitalNameLblColor;
@property (nonatomic, retain) UIColor *hospitalDistanceLblColor;
@property (nonatomic, retain) UIColor *hospitalAccredationLblColor;
@property (nonatomic, retain) UIColor *hospitalEmergencyLblColor;
@property (nonatomic, retain) UIColor *hospitalContactLblColor;
@property (nonatomic, retain) UIColor *hospitalContactNoteLblColor;
@property (nonatomic, retain) UIColor *hospitalContactBtnLblColor;

#pragma mark - Country Safety
@property (nonatomic, retain) UIColor *countrySafetyPageBackgroundColor;
@property (nonatomic, retain) UIColor *countrySafetyPageSectionHeaderLblColor;
@property (nonatomic, retain) UIColor *countrySafetyPageSectionHeaderBackgroundColor;
@property (nonatomic, retain) UIColor *countrySafetyPageSectionContentLblColor;
@property (nonatomic, retain) UIColor *countrySafetyPageSectionBackgroundColor;

#pragma mark - Emergency Numbers
@property (nonatomic, retain) UIColor *emergNumbersPageBackgroundColor;
@property (nonatomic, retain) UIColor *emergNumbersPageTitleColor;
@property (nonatomic, retain) UIColor *emergNumbersPageChangeBtnColor;
@property (nonatomic, retain) UIColor *emergNumberContactLblColor;
@property (nonatomic, retain) UIColor *emergNumberContactNoteLblColor;
@property (nonatomic, retain) UIColor *emergNumberContactBtnLblColor;

#pragma mark - Country Switcher
@property (nonatomic, retain) UIColor *countrySwitcherBackgroundColor;
@property (nonatomic, retain) UIColor *countrySwitcherTitleColor;
@property (nonatomic, retain) UIColor *countrySwitcherButtonColor;

@end
