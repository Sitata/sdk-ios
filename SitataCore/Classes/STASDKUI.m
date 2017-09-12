//
//  STASDKUI.m
//  Pods
//
//  Created by Adam St. John on 2017-02-05.
//
//


#import "STASDKUI.h"

#import "STASDKDefines.h"
#import "STASDKUIStylesheet.h"
#import "STASDKDataController.h"
#import "STASDKController.h"
#import "STASDKUIHealthTableViewController.h"
#import "STASDKUIAlertsTableViewController.h"
#import "STASDKUIAlertViewController.h"
#import "STASDKUITripBuilderBaseViewController.h"
#import "STASDKUISafetyViewController.h"
#import "STASDKUIHospitalsViewController.h"

#import "STASDKMAlert.h"
#import "STASDKMTrip.h"



// STASDKUIPortrait Navigation is a shell class which enables us
// to force the UI screens to stay in portrait orientation.
@interface STASDKUIPortraitNavigation : UINavigationController
@end

@implementation STASDKUIPortraitNavigation
- (void)viewDidLoad  {
    [super viewDidLoad];
}
- (BOOL)shouldAutorotate {
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
@end



@implementation STASDKUI


+ (void)showAlerts {
    enum InfoType mode = Alerts;
    STASDKMTrip *trip = [STASDKMTrip currentTrip];
    [self showInfoType:mode trip:trip];
}
+ (void)showAlerts:(NSString*)tripId {
    enum InfoType mode = Alerts;
    STASDKMTrip *trip = [STASDKMTrip findBy:tripId];
    [self showInfoType:mode trip:trip];
}

+ (void)showAdvisories {
    enum InfoType mode = Advisories;
    STASDKMTrip *trip = [STASDKMTrip currentTrip];
    [self showInfoType:mode trip:trip];
}

+ (void)showAdvisories:(NSString*)tripId {
    enum InfoType mode = Advisories;
    STASDKMTrip *trip = [STASDKMTrip findBy:tripId];
    [self showInfoType:mode trip:trip];
}


// Reusing alerts nav controller for both alerts and advisories
+ (void)showInfoType:(InfoType)mode trip:(STASDKMTrip*)trip {
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"SitataMain" bundle:bundle];

    UINavigationController *nc = [mainStoryboard instantiateViewControllerWithIdentifier:@"AlertsNavCtrl"];
    
    NSArray *viewControllers = [nc viewControllers];
    STASDKUIAlertsTableViewController *vc = (STASDKUIAlertsTableViewController*) [viewControllers objectAtIndex:0];
    vc.mode = mode;
    vc.trip = trip;

    UIViewController *parentCtrl = [[STASDKController sharedInstance] parentRootViewController];
    [parentCtrl presentViewController:nc animated:YES completion:NULL];
}



+ (void)showTripVaccinations {
    enum HealthType healthMode = Vaccinations;
    STASDKMTrip *trip = [STASDKMTrip currentTrip];
    [self showHealthComments:healthMode trip:trip];
}
+ (void)showTripVaccinations:(NSString*)tripId {
    enum HealthType healthMode = Vaccinations;
    STASDKMTrip *trip = [STASDKMTrip findBy:tripId];
    [self showHealthComments:healthMode trip:trip];
}

+ (void)showTripMedications {
    enum HealthType healthMode = Medications;
    STASDKMTrip *trip = [STASDKMTrip currentTrip];
    [self showHealthComments:healthMode trip:trip];
}
+ (void)showTripMedications:(NSString*)tripId {
    enum HealthType healthMode = Medications;
    STASDKMTrip *trip = [STASDKMTrip findBy:tripId];
    [self showHealthComments:healthMode trip:trip];
}

+ (void)showTripDiseases {
    enum HealthType healthMode = Diseases;
    STASDKMTrip *trip = [STASDKMTrip currentTrip];
    [self showHealthComments:healthMode trip:trip];
}
+ (void)showTripDiseases:(NSString*)tripId {
    enum HealthType healthMode = Diseases;
    STASDKMTrip *trip = [STASDKMTrip findBy:tripId];
    [self showHealthComments:healthMode trip:trip];
}

+ (void)showHealthComments:(HealthType)healthMode trip:(STASDKMTrip*)trip {
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"SitataMain" bundle:bundle];

    UINavigationController *nc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HealthNavCtrl"];

    NSArray *viewControllers = [nc viewControllers];
    STASDKUIHealthTableViewController *vc = (STASDKUIHealthTableViewController*) [viewControllers objectAtIndex:0];
    vc.healthMode = healthMode;
    vc.trip = trip;

    UIViewController *parentCtrl = [[STASDKController sharedInstance] parentRootViewController];
    [parentCtrl presentViewController:nc animated:YES completion:NULL];
}

+ (void)showTripSafety {
    STASDKMTrip *trip = [STASDKMTrip currentTrip];
    [self doShowTripSafety:trip];
}
+ (void)showTripSafety:(NSString*)tripId {
    STASDKMTrip *trip = [STASDKMTrip findBy:tripId];
    [self doShowTripSafety:trip];
}
+ (void)doShowTripSafety:(STASDKMTrip*)trip {
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"SitataMain" bundle:bundle];

    UINavigationController *nc = [mainStoryboard instantiateViewControllerWithIdentifier:@"SafetyNavCtrl"];
    NSArray *viewControllers = [nc viewControllers];
    STASDKUISafetyViewController *vc = (STASDKUISafetyViewController*) [viewControllers objectAtIndex:0];
    vc.trip = trip;

    UIViewController *parentCtrl = [[STASDKController sharedInstance] parentRootViewController];
    [parentCtrl presentViewController:nc animated:YES completion:NULL];
}


+ (void)showTripHospitals {
    STASDKMTrip *trip = [STASDKMTrip currentTrip];
    [self doShowTripHospitals:trip];
}
+ (void)showTripHospitals:(NSString*)tripId {
    STASDKMTrip *trip = [STASDKMTrip findBy:tripId];
    [self doShowTripHospitals:trip];
}
+ (void)doShowTripHospitals:(STASDKMTrip*)trip {
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"SitataMain" bundle:bundle];

    UINavigationController *nc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HospitalsNavCtrl"];
    NSArray *viewControllers = [nc viewControllers];
    STASDKUIHospitalsViewController *vc = (STASDKUIHospitalsViewController*) [viewControllers objectAtIndex:0];
    vc.trip = trip;

    UIViewController *parentCtrl = [[STASDKController sharedInstance] parentRootViewController];
    [parentCtrl presentViewController:nc animated:YES completion:NULL];
}

+ (void)showEmergencyNumbers {
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"SitataMain" bundle:bundle];


    UINavigationController *nc = [mainStoryboard instantiateViewControllerWithIdentifier:@"EmergNumNavCtrl"];
    UIViewController *parentCtrl = [[STASDKController sharedInstance] parentRootViewController];
    [parentCtrl presentViewController:nc animated:YES completion:NULL];
}

+ (void)showAlert:(NSString*)alertId {
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"SitataMain" bundle:bundle];

    UINavigationController *nc = [mainStoryboard instantiateViewControllerWithIdentifier:@"AlertsNavCtrl"];
    STASDKUIAlertViewController *vc = (STASDKUIAlertViewController*) [mainStoryboard instantiateViewControllerWithIdentifier:@"showAlert"];
    STASDKMAlert *alert = [STASDKMAlert findBy:alertId];
    vc.alert = alert;
    vc.alertId = alertId;

    UIViewController *parentCtrl = [[STASDKController sharedInstance] parentRootViewController];
    [parentCtrl presentViewController:nc animated:YES completion:NULL];
    [nc pushViewController:vc animated:YES];
}

+ (void)showTripBuilder:(NSString*_Nullable)tripId {

    UIViewController *parentCtrl = [[STASDKController sharedInstance] parentRootViewController];

    if (![[STASDKDataController sharedInstance] isConnected]) {
        // alert and close window

        UIAlertController *alertCtrl = [UIAlertController
                                        alertControllerWithTitle:[[STASDKDataController sharedInstance] localizedStringForKey:@"DISCONNECTED"]
                                        message:[[STASDKDataController sharedInstance] localizedStringForKey:@"CONNECTION_REQ"]
                                        preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:[[STASDKDataController sharedInstance] localizedStringForKey:@"OK"]
                                   style:UIAlertActionStyleDefault
                                   handler:NULL];
        [alertCtrl addAction:okAction];

        [parentCtrl presentViewController:alertCtrl animated:YES completion:nil];
        return;
    }

    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"SitataMain" bundle:bundle];
    UINavigationController *nc = [mainStoryboard instantiateViewControllerWithIdentifier:@"TripBuilderNavCtrl"];

    NSArray *viewControllers = [nc viewControllers];
    STASDKUITripBuilderBaseViewController *vc = (STASDKUITripBuilderBaseViewController*) [viewControllers objectAtIndex:0];
    vc.tripId = tripId;
    [parentCtrl presentViewController:nc animated:YES completion:NULL];
}





+ (NSString *)dateDisplayString:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] localeIdentifier]];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return [dateFormatter stringFromDate:date];
}

+ (NSString *_Nonnull)dateDisplayShort:(NSDate*_Nonnull)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] localeIdentifier]];
    dateFormatter.dateFormat = @"MMM dd";
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)formattedDistance:(double)distanceMeters {
    DistanceUnitsType dut = [STASDKController sharedInstance].distanceUnits;
    NSString *suffix;
    NSString *format;
    double distanceValue;

    switch (dut) {
        case Imperial:
            // convert value to feet from meters
            distanceValue = distanceMeters * 3.28084;
            if (distanceValue < 1320) { // feet
                // quarter mile
                format = @"%.f %@"; // no decimals - e.g. 25 ft
                suffix = @"ft";
            } else {
                distanceValue = distanceValue * 0.000189394; // feet to miles
                suffix = @"mi";
                if (distanceValue < 1) {
                    // between 1 and 0.25 mile (quarter mile)
                    format = @"%.02f %@"; // no decimals - e.g. 0.75 mi
                } else {
                    format = @"%.f %@"; // no decimals - e.g. 251 mi
                }
            }
            break;
        default:
            // metric
            format = @"%.f %@"; // no decimals - e.g. 25 m or 125 km
            if (distanceMeters > 999) {
                // convert to km
                distanceValue = distanceMeters / 1000;
                suffix = @"km";
            } else {
                // leave as meters
                distanceValue = distanceMeters;
                suffix = @"m";
            }
            break;
    }
    return [NSString stringWithFormat:format, distanceValue, suffix];
}

@end



















