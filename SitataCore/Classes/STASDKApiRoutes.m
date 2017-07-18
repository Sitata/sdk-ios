//
//  STASDKApiRoutes.m
//  STASDKApiRoutes
//
//  Created by Adam St. John on 2016-10-02.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//



#import "STASDKApiRoutes.h"
#import "STASDKDefines.h"
#import "STASDKController.h"

NSString *const APIPath = @"api/v1";

@implementation STASDKApiRoutes


+(NSString*)apiEndpoint {
    STASDKController *ctrl = [STASDKController sharedInstance];
    return [NSString stringWithFormat:@"%@/%@", ctrl.apiEndpoint, APIPath];
}


// MARK: == TRIPS ==

+(NSString*)trips {
    return [NSString stringWithFormat:@"%@/trips", [self apiEndpoint]];
}

+(NSString*)currentTrip {
    return [NSString stringWithFormat:@"%@/%@", [self trips], @"current_trip"];
}

+(NSString*)trip:(NSString*)tripId {
    return [NSString stringWithFormat:@"%@/%@", [self trips], tripId];
}

+(NSString*)tripSettings:(NSString*)tripId {
    return [NSString stringWithFormat:@"%@/change_trip_settings", [self trip:tripId]];
}


// MARK: == COUNTRIES ==
+(NSString*)countries {
    return [NSString stringWithFormat:@"%@/countries", [self apiEndpoint]];
}

// /countries/short_list
+(NSString*)countriesShortForm {
    return [NSString stringWithFormat:@"%@/short_list", [self countries]];
}

// /countries/:country_id
+(NSString*)country:(NSString*)countryId {
    return [NSString stringWithFormat:@"%@/%@", [self countries], countryId];
}


// MARK: == DISEASES ==
+(NSString*)diseases {
    return [NSString stringWithFormat:@"%@/diseases", [self apiEndpoint]];
}

// /diseases/:disease_id
+(NSString*)disease:(NSString*)diseaseId {
    return [NSString stringWithFormat:@"%@/%@", [self diseases], diseaseId];
}


// MARK: == VACCINATIONS ==
+(NSString*)vaccinations {
    return [NSString stringWithFormat:@"%@/vaccinations", [self apiEndpoint]];
}

// /vaccinations/:vaccination_id
+(NSString*)vaccination:(NSString*)vaccinationId {
    return [NSString stringWithFormat:@"%@/%@", [self vaccinations], vaccinationId];
}


// MARK: == MEDICATIONS ==
+(NSString*)medications {
    return [NSString stringWithFormat:@"%@/medications", [self apiEndpoint]];
}

// /medications/:medication_id
+(NSString*)medication:(NSString*)medicationId {
    return [NSString stringWithFormat:@"%@/%@", [self medications], medicationId];
}


// Mark: == ALERTS ==

// /api/v1/trips/:trip_id/alerts
+(NSString*)tripAlerts:(NSString*)tripId {
    return [NSString stringWithFormat:@"%@/alerts?full=true", [self trip:tripId]];
}

// /api/v1/alerts/:alert_id/mark_read
+(NSString*)alertMarkRead:(NSString*)alertId {
    return [NSString stringWithFormat:@"%@/alerts/%@/mark_read", [self apiEndpoint], alertId];
}

// /api/v1/alerts/:alert_id/from_push
+(NSString*)alertFromPush:(NSString*)alertId {
    return [NSString stringWithFormat:@"%@/alerts/%@/from_push", [self apiEndpoint], alertId];
}


// Mark: == ADVISORIES ==

// /api/v1/trips/:trip_id/advisories
+(NSString*)tripAdvisories:(NSString*)tripId {
    return [NSString stringWithFormat:@"%@/advisories?full=true", [self trip:tripId]];
}


// Mark: == HOSPITALS ==

// /api/v1/hospitals
+(NSString*)hospitals {
    return [NSString stringWithFormat:@"%@/hospitals", [self apiEndpoint]];
}

// /api/v1/trips/:trip_id/hospitals
+(NSString*)tripHospitals:(NSString*)tripId {
    return [NSString stringWithFormat:@"%@/hospitals", [self trip:tripId]];
}

// /api/v1/countries/:country_id/hospitals
+(NSString*)countryHospitals:(NSString*)countryId {
    return [NSString stringWithFormat:@"%@/hospitals", [self country:countryId]];
}


// Mark: == MOBILE DEVICE / PUSH TOKEN ==

// /api/v1/users/device_push
+(NSString*)addDevice {
    return [NSString stringWithFormat:@"%@/users/add_device", [self apiEndpoint]];
}



// MARK: == GOOGLE ==

// https://maps.googleapis.com/maps/api/place/autocomplete/json?parameters
+(NSString*)googleSearchForCityNamed:(NSString*)query inCountry:(NSString*)countryCode {
    // https://maps.googleapis.com/maps/api/place/autocomplete/json?parameters
    // key - API key
    // input - text string
    // types=(cities)
    // components=country:COUNTRY_CODE_HERE
    NSString *plistKey = [[STASDKController sharedInstance] googleApiKeyPListKey];
    NSString *key = [[NSBundle mainBundle] objectForInfoDictionaryKey:plistKey];
    return [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?key=%@&input=%@&types=(cities)&components=country:%@", key, query, countryCode];
}

// https://maps.googleapis.com/maps/api/place/details/json?parameters
+(NSString*)googlePlaceDetails:(NSString*)placeId; {
    NSString *plistKey = [[STASDKController sharedInstance] googleApiKeyPListKey];
    NSString *key = [[NSBundle mainBundle] objectForInfoDictionaryKey:plistKey];
    return [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?key=%@&placeid=%@", key, placeId];
}


@end
