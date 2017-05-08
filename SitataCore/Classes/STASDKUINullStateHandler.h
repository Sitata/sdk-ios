//
//  STASDKUINullStateHandler.h
//  Pods
//
//  Created by Adam St. John on 2017-03-16.
//
//

#import <Foundation/Foundation.h>

// Displays a full screen with a message in the middle for the user. Primarily
// used for when data doesn't exist
@interface STASDKUINullStateHandler : NSObject

@property UIViewController *parent;
@property NSString *message;

- (instancetype)initWith:(NSString*)message parent:(UIViewController*)parent;

+ (UIView*)displayNullStateWith:(NSString*)message parentView:(UIView*)parentView;

// Pass withNav true to ensure that a navigation bar with a close button is present
- (UIView*)displayNullStateWithNav;

- (void)doClose:(id)sender;

@end
