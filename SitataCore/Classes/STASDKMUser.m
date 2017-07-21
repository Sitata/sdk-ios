//
//  STASDKMUser.m
//  Pods
//
//  Created by Adam St. John on 2017-07-18.
//
//

#import "STASDKMUser.h"

#import "STASDKMUserSettings.h"
#import "STASDKDataController.h"
#import <YYModel/YYModel.h>
#import <Realm/Realm.h>

@implementation STASDKMUser


#pragma mark - Object Mapping
+ (NSString *)primaryKey {
    return @"identifier";
}



+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"identifier": @"id",
             @"firstName": @"first_name",
             @"lastName": @"last_name",
             @"email": @"email",
             @"homeCountry": @"home_country",
             @"language": @"language"
             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {

    // We have to do the following for settings
    // explicitly because Realm doesn't play nice 100% with yyModel.
    NSDictionary *settings = dic[@"settings"];
    STASDKMUserSettings *sett = [STASDKMUserSettings yy_modelWithDictionary:settings];
    self.settings = sett;

    return YES;
}



#pragma mark - Queries

+(STASDKMUser*)findBy:(NSString *)userId {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"identifier == %@", userId];

    RLMResults<STASDKMUser *> *results = [STASDKMUser objectsInRealm:[[STASDKDataController sharedInstance] theRealm] withPredicate:pred];
    if (results && results.count > 0) {
        return results.firstObject;
    } else {
        return nil;
    }
}

+(STASDKMUser*)findFirst {
    RLMResults<STASDKMUser *> *results = [STASDKMUser allObjectsInRealm:[[STASDKDataController sharedInstance] theRealm]];
    if (results && results.count > 0) {
        return results.firstObject;
    } else {
        return nil;
    }
}








-(void)resave:(NSError **)error {
    RLMRealm *realm = [[STASDKDataController sharedInstance] theRealm];

    // destroy related models where applicable
    STASDKMUser *oldUser = [STASDKMUser findBy:self.identifier];
    if (oldUser != NULL) {
        [realm beginWriteTransaction];
        [oldUser removeAssociated:realm];
        NSError *assocError;
        [realm commitWriteTransaction:&assocError];
        if (assocError) {
            *error = assocError;
            NSLog(@"Error removing associated user models - %@", [assocError localizedDescription]);
            return;
        }
    }

    // save self
    NSError *selfError;
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:self];
    [realm commitWriteTransaction:&selfError];

    if (selfError != NULL) {
        *error = selfError;
    }
}

// Removes associated models from the database
// THIS MUST BE CALLED WITHIN A REALM TRANSACTION
-(void)removeAssociated:(RLMRealm*)realm {
    if (self.settings != NULL) {
        [realm deleteObject:self.settings];
    }
    self.settings = NULL;
}

@end
