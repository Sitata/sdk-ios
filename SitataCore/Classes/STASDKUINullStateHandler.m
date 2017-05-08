//
//  STASDKUINullStateHandler.m
//  Pods
//
//  Created by Adam St. John on 2017-03-16.
//
//

#import "STASDKUINullStateHandler.h"

#import "STASDKDataController.h"

@implementation STASDKUINullStateHandler

+ (UIView*)displayNullStateWith:(NSString*)message parentView:(UIView*)parentView {
    CGFloat width = CGRectGetWidth(parentView.bounds);
    CGFloat height = CGRectGetHeight(parentView.bounds);

    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    containerView.backgroundColor = [UIColor whiteColor];
    [containerView setAlpha:1.0];

    [parentView addSubview:containerView];
    [containerView.topAnchor constraintEqualToAnchor:parentView.topAnchor].active = YES;
    [containerView.bottomAnchor constraintEqualToAnchor:parentView.bottomAnchor].active = YES;
    [containerView.leftAnchor constraintEqualToAnchor:parentView.leftAnchor].active = YES;
    [containerView.rightAnchor constraintEqualToAnchor:parentView.rightAnchor].active = YES;

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    lbl.numberOfLines = 0;
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.text = message;
    lbl.textColor = [UIColor darkGrayColor];
    lbl.translatesAutoresizingMaskIntoConstraints = NO;

    [containerView addSubview:lbl];
    [lbl.leftAnchor constraintEqualToAnchor:containerView.leftAnchor constant:15.0].active = YES;
    [lbl.rightAnchor constraintEqualToAnchor:containerView.rightAnchor constant:-15.0].active = YES;
    [lbl.centerYAnchor constraintEqualToAnchor:containerView.centerYAnchor].active = YES;
    return containerView;
}

- (instancetype)initWith:(NSString*)message parent:(UIViewController*)parent {
    self = [super init];
    if (self) {
        _message = message;
        _parent = parent;
    }
    return self;
}

- (UIView*)displayNullStateWithNav {
    UIView *containerView = [STASDKUINullStateHandler displayNullStateWith:self.message parentView:self.parent.view];

    UINavigationBar *bar = [[UINavigationBar alloc] init];
    bar.translatesAutoresizingMaskIntoConstraints = NO;

    [containerView addSubview:bar];
    [bar.topAnchor constraintEqualToAnchor:containerView.topAnchor].active = YES;
    [bar.rightAnchor constraintEqualToAnchor:containerView.rightAnchor].active = YES;
    [bar.leftAnchor constraintEqualToAnchor:containerView.leftAnchor].active = YES;
    [bar.heightAnchor constraintEqualToConstant:64.0].active = YES; // necessary to match navController elsewhere

    NSString *closeStr = [[STASDKDataController sharedInstance] localizedStringForKey:@"CLOSE"];
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:closeStr style:UIBarButtonItemStylePlain target:self action:@selector(doClose:)];

    navItem.leftBarButtonItem = closeBtn;
    [bar pushNavigationItem:navItem animated:NO];

    return containerView;
}

- (void)doClose:(id)sender {
    [self.parent dismissViewControllerAnimated:YES completion:NULL];
}

@end
