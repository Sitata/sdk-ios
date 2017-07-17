//
//  STASDKApiTrip.h
//  STASDKApiTrip
//
//  Created by Adam St. John on 2016-10-02.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STASDKMTrip;


@interface STASDKApiTrip : NSObject

// Request all trips for a traveller.
+(void)getTrips:(void(^)(NSArray<STASDKMTrip*>*, NSURLSessionDataTask*, NSError*))callback;

// Request current trip for the traveller
+(void)getCurrentTrip:(void(^)(STASDKMTrip*, NSURLSessionDataTask*, NSError*))callback;

// Request single trip for a traveller by id.
+(void)getById:(NSString*)tripId onFinished:(void(^)(STASDKMTrip*, NSURLSessionDataTask*, NSError*))callback;

// Create a new trip
+(void)createTrip:(STASDKMTrip*)trip onFinished:(void(^)(STASDKMTrip*, NSURLSessionTask*, NSError*))callback;

// Update an existing trip
+(void)updateTrip:(STASDKMTrip*)trip onFinished:(void(^)(STASDKMTrip*, NSURLSessionTask*, NSError*))callback;

@end


