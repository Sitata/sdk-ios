//
//  STASDKUIItineraryCountryHeaderView.h
//  Pods
//
//  Created by Adam St. John on 2017-07-03.
//
//

#import <UIKit/UIKit.h>

@class STASDKMDestination;

@protocol UIItineraryCountryHeaderViewDelegate <NSObject>

- (void)onAddCountry:(id)sender;

@end



@interface STASDKUIItineraryCountryHeaderView : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UIButton *addCountryBtn;
@property (weak, nonatomic) IBOutlet UIButton *addCountryImg;

@property (weak, nonatomic) id <UIItineraryCountryHeaderViewDelegate> delegate;


- (id) initWithDestination:(STASDKMDestination*)destination;

@end


