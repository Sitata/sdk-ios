//
//  STASDKUIAlertsTableViewController.h
//  Pods
//
//  Created by Adam St. John on 2017-02-05.
//
//

#import <UIKit/UIKit.h>
#import "STASDKUI.h"

@class STASDKMTrip;

@interface STASDKUIAlertsTableViewController : UITableViewController 

@property (assign) InfoType mode;
@property STASDKMTrip *trip;


@end
