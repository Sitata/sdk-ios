//
//  STASDKUIHospitalClusterView.h
//  Pods
//
//  Created by Adam St. John on 2017-03-12.
//
//

#import <MapKit/MapKit.h>

@interface STASDKUIHospitalClusterView : MKAnnotationView

@property (nonatomic, getter = isUniqueLocation) BOOL uniqueLocation;

- (void)setUnique:(BOOL)isUnique;
- (void)setImage;
//- (void)setFirstHospital:(STASDKDBModelHospital*)hospital;

@end
