//
//  STASDKUIHealthTableViewController.h
//  Pods
//
//  Created by Adam St. John on 2017-03-02.
//
//

#import <UIKit/UIKit.h>

#import "STASDKUI.h"

@class STASDKMTrip;

@interface STASDKUIHealthTableViewController : UITableViewController

@property (assign) HealthType healthMode;
@property STASDKMTrip *trip;

@end
