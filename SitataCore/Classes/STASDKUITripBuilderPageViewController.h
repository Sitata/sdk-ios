//
//  STASDKUITripBuilderPageViewController.h
//  Pods
//
//  Created by Adam St. John on 2017-06-19.
//
//

#import <UIKit/UIKit.h>

@class STASDKMTrip;

@interface STASDKUITripBuilderPageViewController : UIPageViewController

@property (nonatomic) NSString *tripId;
@property (weak, nonatomic) UIViewController *manualParentViewController;

@end
