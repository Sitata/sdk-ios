//
//  STASDKUIHospitalPin.h
//  Pods
//
//  Created by Adam St. John on 2017-03-12.
//
//

#import <UIKit/UIKit.h>
#import <Mapkit/Mapkit.h>

@class STASDKMHospital;

@interface STASDKUIHospitalPin : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

// Keeping a reference to the hospital is important so we can switch
// icons where appropriate
@property (nonatomic, assign) STASDKMHospital *hospital;

- (id)initWith:(STASDKMHospital*)hospital;




@end
