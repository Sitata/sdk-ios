//
//  STASDKUITripBuildItinViewController.h
//  Pods
//
//  Created by Adam St. John on 2017-07-03.
//
//

#import <UIKit/UIKit.h>

@class STASDKMTrip;
@class RLMRealm;

@interface STASDKUITripBuildItinViewController : UIViewController

@property (nonatomic) STASDKMTrip *trip;

@property RLMRealm *theRealm;

@end
