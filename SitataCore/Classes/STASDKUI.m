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

#import "STASDKMAlert.h"


@implementation STASDKUI


+ (void)showAlerts {
    enum InfoType mode = Alerts;
    [self showInfoType:mode];
}

+ (void)showAdvisories {
    enum InfoType mode = Advisories;
    [self showInfoType:mode];
}


// Reusing alerts nav controller for both alerts and advisories
+ (void)showInfoType:(InfoType)mode {
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"SitataMain" bundle:bundle];

    UINavigationController *nc = [mainStoryboard instantiateViewControllerWithIdentifier:@"AlertsNavCtrl"];

    NSArray *viewControllers = [nc viewControllers];
    STASDKUIAlertsTableViewController *vc = (STASDKUIAlertsTableViewController*) [viewControllers objectAtIndex:0];
    vc.mode = mode;

    UIViewController *parentCtrl = [[STASDKController sharedInstance] parentRootViewController];
    [parentCtrl presentViewController:nc animated:YES completion:NULL];
}

+ (void)showTripVaccinations {
    enum HealthType healthMode = Vaccinations;
    [self showHealthComments:healthMode];
}

+ (void)showTripMedications {
    enum HealthType healthMode = Medications;
    [self showHealthComments:healthMode];
}

+ (void)showTripDiseases {
    enum HealthType healthMode = Diseases;
    [self showHealthComments:healthMode];
}

+ (void)showHealthComments:(HealthType)healthMode {
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"SitataMain" bundle:bundle];

    UINavigationController *nc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HealthNavCtrl"];

    NSArray *viewControllers = [nc viewControllers];
    STASDKUIHealthTableViewController *vc = (STASDKUIHealthTableViewController*) [viewControllers objectAtIndex:0];
    vc.healthMode = healthMode;

    UIViewController *parentCtrl = [[STASDKController sharedInstance] parentRootViewController];
    [parentCtrl presentViewController:nc animated:YES completion:NULL];
}

+ (void)showTripSafety {
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"SitataMain" bundle:bundle];

    UINavigationController *nc = [mainStoryboard instantiateViewControllerWithIdentifier:@"SafetyNavCtrl"];
    UIViewController *parentCtrl = [[STASDKController sharedInstance] parentRootViewController];
    [parentCtrl presentViewController:nc animated:YES completion:NULL];
}

+ (void)showTripHospitals {
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"SitataMain" bundle:bundle];


    UINavigationController *nc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HospitalsNavCtrl"];
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

    UIViewController *parentCtrl = [[STASDKController sharedInstance] parentRootViewController];
    [parentCtrl presentViewController:nc animated:YES completion:NULL];
//    [parentCtrl presentViewController:vc animated:YES completion:NULL];
    [nc pushViewController:vc animated:YES];
}





+ (NSString *)dateDisplayString:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
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
