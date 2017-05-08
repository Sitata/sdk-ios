//
//  STASDKApiPlaces.h
//  STASDKApiPlaces
//
//  Created by Adam St. John on 2017-01-10.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@class STASDKMHospital;

@interface STASDKApiPlaces : NSObject


// Request hosptials to be save to the device for the trip
+(void)getHospitalsForTrip:(NSString*)tripId onFinished:(void(^)(NSArray<STASDKMHospital*>*, NSURLSessionDataTask*, NSError*))callback;

// Request hosptials to be save to the device for a given country
+(void)getHospitalsForCountry:(NSString*)countryId onFinished:(void(^)(NSArray<STASDKMHospital*>*, NSURLSessionDataTask*, NSError*))callback;

// Request hosptials near the user's location
+(void)getHospitalsNearby:(double)latitude longitude:(double)longitude onFinished:(void(^)(NSArray<STASDKMHospital*>*, NSURLSessionDataTask*, NSError*))callback;






@end


