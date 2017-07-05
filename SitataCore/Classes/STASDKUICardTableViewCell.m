//
//  STASDKUICardTableViewCell.m
//  Pods
//
//  Created by Adam St. John on 2017-07-04.
//
//

#import "STASDKUICardTableViewCell.h"

@implementation STASDKUICardTableViewCell


static CGFloat radius = 2.0;
static int shadowOffsetWidth = 0;
static int shadowOffsetHeight = 3;
static float shadowOpacity = 0.5;


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code


    // card view shadow
    self.containerView.layer.cornerRadius = radius;
    self.containerView.layer.masksToBounds = NO;
    self.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.containerView.layer.shadowOffset = CGSizeMake(shadowOffsetWidth, shadowOffsetHeight);
    self.containerView.layer.shadowOpacity = shadowOpacity;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end




