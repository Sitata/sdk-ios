//
//  STASDKUITBDestPickerPageViewController.h
//  Pods
//
//  Created by Adam St. John on 2017-07-06.
//
//

#import <UIKit/UIKit.h>

@class STASDKUITripBuildItinViewController;

@class STASDKMDestination;

@protocol STASDKUITBDestinationPickerDelegate <NSObject>

- (void)onPickedDestination:(STASDKMDestination*)destination;

@end



@interface STASDKUITBDestPickerPageViewController : UIPageViewController

@property (weak, nonatomic) id <STASDKUITBDestinationPickerDelegate> destPickerDelegate;

@end
