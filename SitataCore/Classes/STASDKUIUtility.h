//
//  STASDKUIUtility.h
//  Pods
//
//  Created by Adam St. John on 2017-04-22.
//
//

#import <Foundation/Foundation.h>

@interface STASDKUIUtility : NSObject


// Convenience method to apply STASDKUIStylesheet styles to the given navigation controller.
+ (void)applyStylesheetToNavigationController:(UINavigationController *)navigationController;

// Convenience method to apply background colors to even/odd rows of tableview cells
+ (void)applyZebraStripeToTableCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath;

// Convenience method to apply STASDKUIStylesheet styles to the given navigation bar.
+ (void)applyStylesheetToNavigationBar:(UINavigationBar*)navigationBar;

#pragma mark - Alerts


@end
