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



#endif /* STASDKDefines_h */
