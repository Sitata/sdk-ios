//
//  STASDKUINullStateHandler.m
//  Pods
//
//  Created by Adam St. John on 2017-03-16.
//
//

#import "STASDKUINullStateHandler.h"

#import "STASDKDataController.h"
#import "STASDKUIStylesheet.h"

@interface STASDKUINullStateHandler()

@property (retain) UIViewController *parent;
@property (retain) NSString *message;
@property (retain) UIView *containerView;

@end

@implementation STASDKUINullStateHandler

- (instancetype)initWith:(NSString*)message parent:(UIViewController*)parent {
    self = [super init];
    if (self) {
        _message = message;
        _parent = parent;
    }
    return self;
}

- (void)displayNullState {
    self.containerView = [self buildNullStateView];
    [self bindToParent];
}

- (UIView*)buildNullStateView {
    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    UIView *parentView = self.parent.view;

    CGFloat width = CGRectGetWidth(parentView.bounds);
    CGFloat height = CGRectGetHeight(parentView.bounds);

    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    containerView.backgroundColor = [UIColor whiteColor];
    [containerView setAlpha:1.0];

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    lbl.numberOfLines = 0;
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.text = self.message;
    lbl.font = styles.bodyFont;
    lbl.textColor = styles.bodyTextColor;
    lbl.translatesAutoresizingMaskIntoConstraints = NO;

    [containerView addSubview:lbl];
    [lbl.leftAnchor constraintEqualToAnchor:containerView.leftAnchor constant:15.0].active = YES;
    [lbl.rightAnchor constraintEqualToAnchor:containerView.rightAnchor constant:-15.0].active = YES;
    [lbl.centerYAnchor constraintEqualToAnchor:containerView.centerYAnchor].active = YES;

    return containerView;
}

- (void)bindToParent {
    UIView *parentView = self.parent.view;
    [parentView addSubview:self.containerView];
    [self.containerView.topAnchor constraintEqualToAnchor:parentView.topAnchor].active = YES;
    [self.containerView.bottomAnchor constraintEqualToAnchor:parentView.bottomAnchor].active = YES;
    [self.containerView.leftAnchor constraintEqualToAnchor:parentView.leftAnchor].active = YES;
    [self.containerView.rightAnchor constraintEqualToAnchor:parentView.rightAnchor].active = YES;
}



- (void)displayNullStateWithNav {
    self.containerView = [self buildNullStateView];

    UINavigationBar *bar = [[UINavigationBar alloc] init];
    bar.translatesAutoresizingMaskIntoConstraints = NO;

    [self.containerView addSubview:bar];
    [bar.topAnchor constraintEqualToAnchor:self.containerView.topAnchor].active = YES;
    [bar.rightAnchor constraintEqualToAnchor:self.containerView.rightAnchor].active = YES;
    [bar.leftAnchor constraintEqualToAnchor:self.containerView.leftAnchor].active = YES;
    [bar.heightAnchor constraintEqualToConstant:64.0].active = YES; // necessary to match navController elsewhere

    NSString *closeStr = [[STASDKDataController sharedInstance] localizedStringForKey:@"CLOSE"];
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:closeStr style:UIBarButtonItemStylePlain target:self action:@selector(doClose:)];

    navItem.leftBarButtonItem = closeBtn;
    [bar pushNavigationItem:navItem animated:NO];

    [self bindToParent];
}

- (void)doClose:(id)sender {
    [self.parent dismissViewControllerAnimated:YES completion:NULL];
}

- (void)dismiss {
    [self.containerView removeFromSuperview];
}

@end
