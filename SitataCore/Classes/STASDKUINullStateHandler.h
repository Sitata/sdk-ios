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

- (instancetype)initWith:(NSString*)message parent:(UIViewController*)parent;

- (void)displayNullState;

- (void)displayNullStateWithNav;

// close parent view controller
- (void)doClose:(id)sender;

// remove from superview
- (void)dismiss;

@end
