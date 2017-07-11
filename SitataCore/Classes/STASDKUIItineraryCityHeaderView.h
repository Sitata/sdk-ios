//
//  STASDKUIItineraryCityHeaderView.h
//  Pods
//
//  Created by Adam St. John on 2017-07-09.
//
//

#import <UIKit/UIKit.h>

@class STASDKMDestination;
@class STASDKMDestinationLocation;


@protocol STASDKUIItineraryCityHeaderViewDelegate <NSObject>

- (void)onAddCity:(id)sender destination:(STASDKMDestination*)destination;
- (void)onRemoveCity:(id)sender removed:(STASDKMDestinationLocation*)location;

@end



@interface STASDKUIItineraryCityHeaderView : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UIButton *addCityBtn;
@property (weak, nonatomic) IBOutlet UIButton *addCityImg;
@property (weak, nonatomic) IBOutlet UIButton *removeCityImg;

@property STASDKMDestination *parentDestination;

@property (weak, nonatomic) id <STASDKUIItineraryCityHeaderViewDelegate> delegate;



- (id) initWithLocation:(STASDKMDestinationLocation*)location;

- (void) removeRemoveBtn;

@end



