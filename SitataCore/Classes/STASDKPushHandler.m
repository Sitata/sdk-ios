//
//  STASDKPushHandler.m
//  Pods
//
//  Created by Adam St. John on 2017-06-19.
//
//

#import "STASDKPushHandler.h"
#import "STASDKJobs.h"
#import "STASDKUI.h"

#import <EDQueue/EDQueue.h>


@implementation STASDKPushHandler

const NSString *PUSH_KEY_SIT_TYPE = @"sitataPt";
const NSString *PUSH_KEY_SIT_DATA = @"sitataData";

const int PUSH_TYPE_ALERT = 0;
const int PUSH_TYPE_ALERT_LATENT = 2;



//PUSHTYPES = {alert: 0,
//alert_incubation: 1, # legacy
//alert_latent: 2,
//new_trip: 3,
//proximity_report_reward: 4,
//report_votes: 5,
//new_comment: 6,
//new_badge: 7,
//new_report_proximity: 8,
//community_prompt: 9}.freeze



/**
 *   EXAMPLE INCOMING DATA STRUCTURE FOR USER INFO
 *
 *   {
 *       aps =     {
 *           alert = "testing another ios push";
 *           badge = 6;
 *           "content-available" = 1;
 *           sound = "/sounds/sitataChime.wav";
 *       };
 *       sitataData = "{\"alert_id\":\"594c018b59b6bae93ef1ec7c\"}";
 *       sitataPt = 0;
 *   }
 */
+ (void) handlePushData:(NSDictionary*)userInfo {

    // If we have a Sitata push notification type, then let's process it. Otherwise, ignroe it.
    if (userInfo[PUSH_KEY_SIT_TYPE]) {
        int pushType = [userInfo[PUSH_KEY_SIT_TYPE] intValue];
        NSDictionary *sitataDataDict = [self parsePushData:userInfo];

        switch(pushType) {
            case PUSH_TYPE_ALERT:
                [self handleAlertPush:sitataDataDict];
                break;
            default:
                // ignore
                break;
        }

    }
}

+ (void) launchPushScreen:(NSDictionary*)userInfo {
    int pushType = [userInfo[PUSH_KEY_SIT_TYPE] intValue];
    NSDictionary *sitataDataDict = [self parsePushData:userInfo];

    switch(pushType) {
        case PUSH_TYPE_ALERT:
            [self launchAlertScreen:sitataDataDict];
            break;
        default:
            // ignore
            break;
    }

}


// Handle incoming trip alert push notification
+ (void) handleAlertPush:(NSDictionary*)sitataData {
    if (sitataData != NULL) {
        NSString *alertId = [sitataData objectForKey:@"alert_id"];

        // do sync to ensure we have the data
        [[EDQueue sharedInstance] enqueueWithData:@{JOB_PARAM_AID: alertId} forTask:JOB_SYNC_ALERT];
    }
}


// Grab out the sitata data (stringified json) from the push notification
+ (NSDictionary*) parsePushData:(NSDictionary*)userInfo {
    NSString *sitataData = [userInfo objectForKey:PUSH_KEY_SIT_DATA];
    NSData *sitataJsonData;
    NSDictionary *sitataDataDict;
    if (sitataData != NULL) {
        sitataJsonData = [sitataData dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        sitataDataDict = [NSJSONSerialization JSONObjectWithData:sitataJsonData options:kNilOptions error:&error];
    }
    return sitataDataDict;
}



#pragma mark - UI Screens

// alert screen
+ (void) launchAlertScreen:(NSDictionary*)sitataData {
    if (sitataData != NULL) {
        NSString *alertId = [sitataData objectForKey:@"alert_id"];
        if (alertId != NULL) {
            // TODO: LAUNCH ALERT SCREEN
            [STASDKUI showAlert:alertId];
        }
    }
}

@end