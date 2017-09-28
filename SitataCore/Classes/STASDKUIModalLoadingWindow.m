//
//  STASDKUIModalLoadingWindow.m
//  Pods
//
//  Created by Adam St. John on 2017-06-27.
//
//

#import "STASDKUIModalLoadingWindow.h"
#import "STASDKDataController.h"

#import <UIKit/UIKit.h>


@interface STASDKUIModalLoadingWindow ()

@property (nonatomic) UIView *overlayWindow;
@property (nonatomic) UIStackView *infoWin;
@property (nonatomic) UILabel *title;
@property (nonatomic) UILabel *subTitle;
@property (nonatomic) UIButton *closeBtn;
@property (nonatomic) void (^closeCallback)(void);

@end



@implementation STASDKUIModalLoadingWindow

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {

    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.backgroundColor = [UIColor clearColor];

        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        blurView.frame = self.bounds;
        blurView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self addSubview:blurView];
    } else {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.95;
    }


    self.clipsToBounds = YES;

    _overlayWindow = [[UIView alloc] initWithFrame:self.bounds];
    _overlayWindow.translatesAutoresizingMaskIntoConstraints = NO;
    _overlayWindow.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    UIStackView *stack = [self createInformationStackView];
    [_overlayWindow addSubview:stack];

//    UIButton *closeBtn = [self createCloseBtn];
//    [_overlayWindow addSubview:closeBtn];

    [self addSubview:_overlayWindow];
    [self addViewConstraints];
}

//override public func layoutSubviews() {
//    //NOTE: Add code if some last minute layout changes are needed
//}




- (UIStackView*)createInformationStackView {
    _infoWin = [[UIStackView alloc] init];
    _infoWin.axis = UILayoutConstraintAxisVertical;
    _infoWin.alignment = UIStackViewAlignmentCenter;
    _infoWin.distribution = UIStackViewDistributionFill;
    _infoWin.translatesAutoresizingMaskIntoConstraints = NO;
    _infoWin.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);

    UIActivityIndicatorView *actView = [self createActivityIndicator];
    UILabel *titleLbl = [self createTitle];
    UILabel *subLbl = [self createSubTitle];

    [_infoWin addArrangedSubview:actView];
    [_infoWin addArrangedSubview:titleLbl];
    [_infoWin addArrangedSubview:subLbl];

    return _infoWin;
}

- (UIActivityIndicatorView*)createActivityIndicator {
    UIActivityIndicatorView *v = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [v startAnimating];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    return v;
}

- (UILabel*)createTitle {
    _title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
    _title.text = [STASDKDataController.sharedInstance localizedStringForKey:@"LOADING"];
    _title.textColor = [UIColor whiteColor];
    _title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _title.textAlignment = NSTextAlignmentCenter;
    _title.translatesAutoresizingMaskIntoConstraints = NO;
    return _title;
}

- (UILabel*)createSubTitle {
    _subTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
    _subTitle.text = [STASDKDataController.sharedInstance localizedStringForKey:@"PLEASE_STAND_BY"];
    _subTitle.textColor = [UIColor whiteColor];
    _subTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _subTitle.textAlignment = NSTextAlignmentCenter;
    _subTitle.translatesAutoresizingMaskIntoConstraints = NO;
    return _subTitle;
}

// TODO: Make close button optional.
//- (UIButton*)createCloseBtn {
//    _closeBtn = [[UIButton alloc] init];
//    [_closeBtn setTitle:@"Close" forState:UIControlStateNormal];
//    [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
//    _closeBtn.tintColor = [UIColor whiteColor];
//    return _closeBtn;
//}

- (void)addViewConstraints {
    self.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self addConstraintsForOverlay];
//    [self addConstraintsForCloseButton];
    [self addConstraintsForStackView];
}

- (void)addConstraintsForOverlay {
    [_overlayWindow.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = true;
    [_overlayWindow.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = true;
    [_overlayWindow.topAnchor constraintEqualToAnchor:self.topAnchor].active = true;
    [_overlayWindow.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = true;
}

//- (void)addConstraintsForCloseButton {
//    [_closeBtn.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:24.0].active = true;
//    [_closeBtn.topAnchor constraintEqualToAnchor:self.topAnchor constant:24.0].active = true;
//}

- (void)addConstraintsForStackView {

    NSLayoutConstraint *xCenter = [NSLayoutConstraint constraintWithItem:_infoWin attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual toItem:_infoWin.superview
                                                               attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [_overlayWindow addConstraint:xCenter];

    NSLayoutConstraint *yCenter = [NSLayoutConstraint constraintWithItem:_infoWin
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_infoWin.superview
                                                               attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [_overlayWindow addConstraint:yCenter];
}



- (void)hide {
    [self removeFromSuperview];
}

- (void)setTitleText:(NSString*)txt {
    [self.title setText:txt];
}

- (void)setSubTitleText:(NSString*)txt {
    [self.subTitle setText:txt];
}

//- (void)setCloseCallBack:(

//- (void)close {
//    [self hide];
//    if (_closeCallback) {
//        _closeCallback();
//    }
//}



@end
