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

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)





typedef NS_ENUM(int, TripType) {
    Holiday = 0,
    Business = 1,
    OtherTripType = 2
};
//NSUInteger TripTypeEnumSize() {
//    return 3;
//}

typedef NS_ENUM(int, TripActivity) {
    Beach = 0,
    Scuba = 1,
    Snorkel = 2,
    Hiking = 3,
    Camping = 4,
    Kayaking = 5,
    Canoeing = 6,
    Shopping = 7,
    Sites = 8,
    Museums = 9,
    Food = 10,
    Ecotourism = 11,
    Bicycling = 12,
    Backpacking = 13,
    Golf = 14,
    RockClimbing = 15,
    Skiing = 16,
    Snowboarding = 17,
    Photography = 18,
    Safari = 19,
    AroundWorld = 20,
    MedicalTourism = 21,
    Humanitarian = 22,
    Gambling = 23,
    JungleTrek = 24,
    Cruise = 25,
    RoadTrip = 26,
    AmusementPark = 27

};
//NSUInteger TripActivityEnumSize() {
//    return 28;
//}


// Used to signal to STASDKUITripMetaCollectionViewController to tell it
// which mode to operate in and which icons to show.
typedef NS_ENUM(int, TripMetaType) {
    TripPurpose = 0,
    TripActivities = 1
};




#endif /* STASDKDefines_h */


