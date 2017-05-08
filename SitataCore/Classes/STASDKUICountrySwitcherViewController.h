//
//  STASDKUICountrySwitcherViewController.h
//  Pods
//
//  Created by Adam St. John on 2017-03-09.
//
//

#import <UIKit/UIKit.h>


@class STASDKUISafetyViewController;

FOUNDATION_EXPORT NSNotificationName const NotifyCountrySwitcherChanged;
FOUNDATION_EXPORT NSString *const NotifyKeyCountriesIndex;




@interface STASDKUICountrySwitcherViewController : UIViewController


@property int pageIndex;
@property int pageCount;
@property NSArray *countries;


@property (weak, nonatomic) IBOutlet UILabel *countryNameLbl;
@property (weak, nonatomic) IBOutlet UIButton *nextPageBtn;
@property (weak, nonatomic) IBOutlet UIButton *previousPageBtn;





@end
