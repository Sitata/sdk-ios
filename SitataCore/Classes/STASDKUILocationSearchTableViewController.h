//
//  STASDKUILocationSearchTableViewController.h
//  Pods
//
//  Created by Adam St. John on 2017-07-10.
//
//

#import <UIKit/UIKit.h>

@class STASDKMDestinationLocation;
@class STASDKMDestination;

@protocol STASDKUILocationSearchDelegate <NSObject>

- (void)onSelectedLocation:(STASDKMDestinationLocation*)location;

@end



@interface STASDKUILocationSearchTableViewController : UITableViewController <UISearchResultsUpdating>


@property (weak, nonatomic) id <STASDKUILocationSearchDelegate> delegate;

@property STASDKMDestination* currentDestination;

@end
