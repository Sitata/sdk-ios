//
//  STASDKMContactDetail.h
//  Pods
//
//  Created by Adam St. John on 2017-03-15.
//
//

#import <Foundation/Foundation.h>


//# Types
//# -----------
//# 0: Office Phone
//# 1: Fax
//# 2: Home Phone
//# 3: Mobile Phone
//# 4: Web Address
//# 5: Email Address
//# 90: Police
//# 91: Fire
//# 92: Ambulance
//# 98: All Emergency
//# 99: Other
typedef NS_ENUM(int, ContactDetailType) {
    OfficePhone = 0,
    Fax = 1,
    HomePhone = 2,
    MobilePhone = 3,
    Website = 4,
    EmailAddress = 5,
    Police = 90,
    Fire = 91,
    Ambulance = 92,
    AllEmergency = 98,
    Other = 99
};


@interface STASDKMContactDetail : NSObject


@property int typ;
@property int order;
@property (retain) NSString *val;
@property (retain) NSString *note;



// Creates a new contact detail model from the given nsdictionary representation
- (instancetype)initWith:(NSDictionary*)dict NS_DESIGNATED_INITIALIZER;




@end
