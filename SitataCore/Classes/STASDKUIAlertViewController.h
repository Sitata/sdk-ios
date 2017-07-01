//
//  STASDKUIAlertViewController.h
//  Pods
//
//  Created by Adam St. John on 2017-02-25.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@class STASDKMAlert;
@class STASDKMAdvisory;

@interface STASDKUIAlertViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *headlineLbl;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet UILabel *bodyLbl;
@property (weak, nonatomic) IBOutlet UIButton *readMoreBtn;
@property (weak, nonatomic) IBOutlet UILabel *adviceBodyLbl;
@property (weak, nonatomic) IBOutlet UILabel *adviceHeaderLbl;

@property (weak, nonatomic) IBOutlet UILabel *referencesHeaderLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *windowHeightStubConstraint;

@property (nonatomic, strong) STASDKMAlert *alert;
@property (nonatomic, strong) STASDKMAdvisory *advisory;

// for when the alert is not available yet
@property (nonatomic, strong) NSString *alertId;

@end
