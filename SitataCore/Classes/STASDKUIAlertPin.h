//
//  STASDKUIAlertPin.h
//  Pods
//
//  Created by Adam St. John on 2017-02-26.
//
//

#import <UIKit/UIKit.h>
#import <Mapkit/Mapkit.h>

@interface STASDKUIAlertPin : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;


- (id)initWithType:(NSString*)type coordinate:(CLLocationCoordinate2D)coordinate;




@end
