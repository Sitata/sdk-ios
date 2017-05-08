//
//  STASDKSuperFold.h
//  Pods
//
//  Created by Adam St. John on 2017-04-30.
//
//

#import <UIKit/UIKit.h>

@interface UIView (Fold)

- (void)foldOpenWithTransparency:(BOOL)withTransparency
             withCompletionBlock:(void (^)(void))completionBlock;

- (void)foldClosedWithTransparency:(BOOL)withTransparency
               withCompletionBlock:(void (^)(void))completionBlock;

@end
