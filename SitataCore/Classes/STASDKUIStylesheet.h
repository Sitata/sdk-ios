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


#pragma mark - General

// Page specific styles and customizations will take precedence over
// the general ones.
@property (nonatomic, retain) UIFont *headingFont;
@property (nonatomic, retain) UIFont *subHeadingFont;
@property (nonatomic, retain) UIFont *titleFont;
@property (nonatomic, retain) UIFont *rowTextFont;
@property (nonatomic, retain) UIFont *rowSecondaryTextFont;
@property (nonatomic, retain) UIFont *bodyFont;
@property (nonatomic, retain) UIFont *buttonFont;

@property (nonatomic, retain) UIColor *headingTextColor;
@property (nonatomic, retain) UIColor *subheadingTextColor;
@property (nonatomic, retain) UIColor *titleTextColor;
@property (nonatomic, retain) UIColor *bodyTextColor;



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
@property (nonatomic, retain) UIFont *alertsRowNormalFont;
@property (nonatomic, retain) UIFont *alertsRowUnreadFont;


#pragma mark - Diseases
@property (nonatomic, retain) UIColor *diseaseRowNameLblColor;
@property (nonatomic, retain) UIColor *diseaseListPageBackgroundColor;
@property (nonatomic, retain) UIColor *diseasePageBackgroundColor;
@property (nonatomic, retain) UIColor *diseaseAboutPageBackgroundColor;
@property (nonatomic, retain) UIColor *diseaseAboutPageSectionHeaderLblColor;
@property (nonatomic, retain) UIColor *diseaseAboutPageSectionCardBackgroundColor;
@property (nonatomic, retain) UIColor *diseaseAboutPageSectionContentLblColor;



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
@property (nonatomic, retain) UIFont  *hospitalEmergencyLblFont;
@property (nonatomic, retain) UIFont  *hospitalAccredationLblFont;


#pragma mark - Country Safety
@property (nonatomic, retain) UIColor *countrySafetyPageBackgroundColor;
@property (nonatomic, retain) UIColor *countrySafetyPageSectionHeaderLblColor;
@property (nonatomic, retain) UIColor *countrySafetyPageSectionCardBackgroundColor;
@property (nonatomic, retain) UIColor *countrySafetyPageSectionContentLblColor;

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

#pragma mark - Trip Builder
@property (nonatomic, retain) UIColor *tripTypeIconColor;
@property (nonatomic, retain) UIColor *tripMetaCardActiveColor;
@property (nonatomic, retain) UIColor *tripSuccessIconColor;
@property (nonatomic, retain) UIColor *tripTimelineColor;
@property (nonatomic, retain) UIColor *tripBuilderRemoveColor;
@property (nonatomic, retain) UIColor *tripBuilderAddColor;

@end
