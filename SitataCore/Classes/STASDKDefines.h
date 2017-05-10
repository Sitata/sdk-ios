//
//  STASDKDefines.h
//  Pods
//
//  Created by Adam St. John on 2017-03-17.
//
//

#ifndef STASDKDefines_h
#define STASDKDefines_h


#define IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)


#ifdef __IPHONE_7_0
#define IOS7 ([UIDevice currentDevice].systemVersion.floatValue >= 7)
#else
#define IOS7 (NO)
#endif



#ifdef DEBUG
#define API_ENDPOINT_HOST @"https://127.0.0.1:3000/api/v1"
#else
#define API_ENDPOINT_HOST @"https://www.sitata.com/api/v1"
#endif


#endif /* STASDKDefines_h */
