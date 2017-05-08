//
//  STASDKApiRoutes.m
//  STASDKApiRoutes
//
//  Created by Adam St. John on 2016-10-02.
//  Copyright © 2016 Sitata, Inc. All rights reserved.
//



#import "STASDKApiRoutes.h"
#import "STASDKDefines.h"

NSString *const APIEndpoint = API_ENDPOINT_HOST;

@implementation STASDKApiRoutes



// MARK: == TRIPS ==

+(NSString*)trips {
    return [NSString stringWithFormat:@"%@/trips", APIEndpoint];
}

+(NSString*)currentTrip {
    return [NSString stringWithFormat:@"%@/%@", [self trips], @"current_trip"];
}

+(NSString*)trip:(NSString*)tripId {
    return [NSString stringWithFormat:@"%@/%@", [self trips], tripId];
}


// MARK: == COUNTRIES ==
+(NSString*)countries {
    return [NSString stringWithFormat:@"%@/countries", APIEndpoint];
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
    return [NSString stringWithFormat:@"%@/diseases", APIEndpoint];
}

// /diseases/:disease_id
+(NSString*)disease:(NSString*)diseaseId {
    return [NSString stringWithFormat:@"%@/%@", [self diseases], diseaseId];
}


// MARK: == VACCINATIONS ==
+(NSString*)vaccinations {
    return [NSString stringWithFormat:@"%@/vaccinations", APIEndpoint];
}

// /vaccinations/:vaccination_id
+(NSString*)vaccination:(NSString*)vaccinationId {
    return [NSString stringWithFormat:@"%@/%@", [self vaccinations], vaccinationId];
}


// MARK: == MEDICATIONS ==
+(NSString*)medications {
    return [NSString stringWithFormat:@"%@/medications", APIEndpoint];
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
    return [NSString stringWithFormat:@"%@/alerts/%@/mark_read", APIEndpoint, alertId];
}


// Mark: == ADVISORIES ==

// /api/v1/trips/:trip_id/advisories
+(NSString*)tripAdvisories:(NSString*)tripId {
    return [NSString stringWithFormat:@"%@/advisories?full=true", [self trip:tripId]];
}


// Mark: == HOSPITALS ==

// /api/v1/hospitals
+(NSString*)hospitals {
    return [NSString stringWithFormat:@"%@/hospitals", APIEndpoint];
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
+(NSString*)devicePush {
    return [NSString stringWithFormat:@"%@/users/device_push", APIEndpoint];
}


@end
