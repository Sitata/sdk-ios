//
//  STASDKUITripMetaCollectionViewCell.h
//  Pods
//
//  Created by Adam St. John on 2017-07-11.
//
//

#import <UIKit/UIKit.h>

#import "STASDKUITripMetaCollectionViewController.h"


@interface STASDKUITripMetaCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) TripMetaType mode;
@property (nonatomic, assign) NSInteger index;


- (void)setFor:(TripMetaType)tripType atIndex:(NSInteger)index;
- (void)toggleActive;


@end
