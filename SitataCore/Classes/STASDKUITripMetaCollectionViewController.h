//
//  STASDKUITripMetaCollectionViewController.h
//  Pods
//
//  Created by Adam St. John on 2017-07-11.
//
//

#import <UIKit/UIKit.h>

#import "STASDKDefines.h"

@class STASDKMTrip;
@class RLMRealm;


@interface STASDKUITripMetaCollectionViewController : UIViewController

@property (nonatomic) STASDKMTrip *trip;
@property (nonatomic) TripMetaType mode;
@property (nonatomic) RLMRealm *theRealm;

@end
