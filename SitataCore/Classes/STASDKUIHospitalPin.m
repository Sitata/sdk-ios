//
//  STASDKUIHospitalPin.m
//  Pods
//
//  Created by Adam St. John on 2017-02-26.
//
//

#import "STASDKUIHospitalPin.h"
#import "STASDKMHospital.h"

@implementation STASDKUIHospitalPin


- (id)initWith:(STASDKMHospital*)hospital {
    self.hospital = hospital;
    self.coordinate = CLLocationCoordinate2DMake(hospital.latitude, hospital.longitude);
    return self;
}





@end
