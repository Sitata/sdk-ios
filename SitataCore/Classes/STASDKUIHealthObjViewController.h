//
//  STASDKUIHealthObjViewController.h
//  Pods
//
//  Created by Adam St. John on 2017-03-05.
//
//

#import <UIKit/UIKit.h>
#import "STASDKUI.h"

@interface STASDKUIHealthObjViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *healthObjTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString *healthObjId;
@property HealthType healthMode;

@end
