//
//  STASDKUIUtility.m
//  Pods
//
//  Created by Adam St. John on 2017-04-22.
//
//

#import "STASDKUIUtility.h"

#import "STASDKUIStylesheet.h"
#import "STASDKDefines.h"
#import "STASDKUIAlertTableViewCell.h"

@implementation STASDKUIUtility

+ (void)applyStylesheetToNavigationController:(UINavigationController *)navigationController {
    [self applyStylesheetToNavigationBar:navigationController.navigationBar];
}

+ (void)applyStylesheetToNavigationBar:(UINavigationBar*)navigationBar {
    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];

    if (IOS7) {
        navigationBar.tintColor = styles.navigationBarTintColor;
        navigationBar.barTintColor = styles.navigationBarBackgroundColor;
    } else {
        navigationBar.tintColor = styles.navigationBarBackgroundColor;
    }
    navigationBar.translucent = styles.navigationBarTranslucency;
    [navigationBar setBackgroundImage:styles.navigationBarBackgroundImage forBarMetrics:UIBarMetricsDefault];

    NSMutableDictionary *navbarTitleTextAttributes = [[NSMutableDictionary alloc] initWithDictionary:navigationBar.titleTextAttributes];

    if (styles.navigationBarTextColor) {
        [navbarTitleTextAttributes setObject:styles.navigationBarTextColor forKey:NSForegroundColorAttributeName];
    }

    if (styles.navigationBarTextShadowColor) {
        NSShadow *shadow = [NSShadow new];
        shadow.shadowColor = styles.navigationBarTextShadowColor;
        shadow.shadowOffset = CGSizeMake(1, 0);
        [navbarTitleTextAttributes setObject:shadow forKey:NSShadowAttributeName];
    }
    if (styles.navigationBarFont) {
        [navbarTitleTextAttributes setObject:styles.navigationBarFont forKey:NSFontAttributeName];
    }
    [navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
}


+ (void)applyZebraStripeToTableCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath {
    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    NSInteger row = [indexPath row];

    if (row % 2 == 0) {
        // even row
        [cell setBackgroundColor:styles.evenCellBackgroundColor];
    } else {
        // odd row
        [cell setBackgroundColor:styles.oddCellBackgroundColor];
    }
}






@end
