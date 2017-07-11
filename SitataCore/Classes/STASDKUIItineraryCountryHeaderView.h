//
//  STASDKUIItineraryCountryHeaderView.h
//  Pods
//
//  Created by Adam St. John on 2017-07-03.
//
//

#import <UIKit/UIKit.h>

@class STASDKMDestination;

@protocol STASDKUIItineraryCountryHeaderViewDelegate <NSObject>

- (void)onAddCountry:(id)sender;
- (void)onRemoveCountry:(id)sender;

@end



@interface STASDKUIItineraryCountryHeaderView : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UIButton *addCountryBtn;
@property (weak, nonatomic) IBOutlet UIButton *addCountryImg;
@property (weak, nonatomic) IBOutlet UIButton *removeCountryImg;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;

@property (weak, nonatomic) id <STASDKUIItineraryCountryHeaderViewDelegate> delegate;


- (id) initWithDestination:(STASDKMDestination*)destination isLast:(bool)isLast;

- (void) removeRemoveBtn;
- (void) removeDateLbl;

@end



