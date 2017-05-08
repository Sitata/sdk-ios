//
//  STASDKSuperFoldCell.m
//  Pods
//
//  Created by Adam St. John on 2017-04-30.
//
//

#import "STASDKSuperFoldCell.h"
#import "STASDKSuperFold.h"


@interface STASDKSuperFoldCell()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailContainerViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shadowViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shadowViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *shadowView;

@end


@implementation STASDKSuperFoldCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    self.withDetails = NO;
    self.backgroundView = nil;
    self.detailContainerViewHeightConstraint.constant = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setWithDetails:(BOOL)withDetails {
    _withDetails = withDetails;

    if (withDetails) {
        self.detailContainerViewHeightConstraint.priority = 250;
    } else {
        self.detailContainerViewHeightConstraint.priority = 999;
    }
}

- (void)animateOpen {
    UIColor *originalBackgroundColor = self.contentView.backgroundColor;
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.detailContainerView foldOpenWithTransparency:YES
                                   withCompletionBlock:^{
                                       self.contentView.backgroundColor = originalBackgroundColor;
                                   }];
}

- (void)animateClosed {
    UIColor *originalBackgroundColor = self.contentView.backgroundColor;
    self.contentView.backgroundColor = [UIColor clearColor];

    [self.detailContainerView foldClosedWithTransparency:YES withCompletionBlock:^{
        self.contentView.backgroundColor = originalBackgroundColor;
    }];
}


- (void)setShadow {
    self.shadowViewLeadingConstraint.constant = 5.f;
    self.shadowViewTrailingConstraint.constant = 5.f;

    self.shadowView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.shadowView.layer.shadowOffset = CGSizeMake(0, 2);
    self.shadowView.layer.shadowOpacity = 0.6;
    self.shadowView.layer.shadowRadius = 3;
    self.shadowView.layer.masksToBounds = NO;
    self.shadowView.layer.shadowPath = NULL;
}

@end
