//
//  STASDKLocationHandler.h
//  STACore
//
//  Created by Adam St. John on 2016-03-12.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface STASDKLocationHandler : NSObject



+ (void)requestPermissionsWhenNecessary;

+ (void)currentCountry;

@end

