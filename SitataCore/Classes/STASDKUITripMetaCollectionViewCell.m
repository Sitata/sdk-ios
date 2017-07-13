//
//  STASDKUITripMetaCollectionViewCell.m
//  Pods
//
//  Created by Adam St. John on 2017-07-11.
//
//

#import "STASDKUITripMetaCollectionViewCell.h"


#import "STASDKDataController.h"
#import "STASDKUIStylesheet.h"

@interface STASDKUITripMetaCollectionViewCell()


@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLbl;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property bool isActive;
@property CAShapeLayer *activeCircle;
@property CALayer *isActiveImg;


@end

@implementation STASDKUITripMetaCollectionViewCell

static CGFloat radius = 2.0;
static int shadowOffsetWidth = 0;
static int shadowOffsetHeight = 3;
static float shadowOpacity = 0.5;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    self.backgroundColor = [UIColor whiteColor];
    self.containerView.backgroundColor = [UIColor whiteColor];
    // card view shadow
    self.layer.masksToBounds = NO;
    self.containerView.layer.cornerRadius = radius;
    self.containerView.layer.masksToBounds = NO;
    self.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.containerView.layer.shadowOffset = CGSizeMake(shadowOffsetWidth, shadowOffsetHeight);
    self.containerView.layer.shadowOpacity = shadowOpacity;
}



- (void)setFor:(TripMetaType)tripType atIndex:(NSInteger)index {
    self.mode = tripType;
    self.index = index;

    if (self.mode == TripPurpose) {
        // trip types
        [self setIcon:@"tripType"];
        [self setLabel:@"TRIP_TYPE_"];
    } else {
        // trip activities
        [self setIcon:@"tripActivity"];
        [self setLabel:@"TRIP_ACTIVITY_"];
    }
}


- (void)setIcon:(NSString*)prefix {
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    NSString *imgName = [NSString stringWithFormat:@"%@%ld", prefix, (long)self.index];
    UIImage *img = [UIImage imageNamed:imgName inBundle:bundle compatibleWithTraitCollection:NULL];
    if (img) {
        STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
        [self.iconImg setImage:img];
        [self.iconImg setTintColor:styles.tripTypeIconColor];
    }
}

- (void)setLabel:(NSString*)prefix {
    NSString *lblStr = [NSString stringWithFormat:@"%@%ld", prefix, (long)self.index];
    self.descriptionLbl.text = [[STASDKDataController sharedInstance] localizedStringForKey:lblStr];
    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    [self.descriptionLbl setTextColor:styles.tripTypeIconColor];
}

- (void)toggleActive {
    if (!self.isActive) {
        [self setActive];
    } else {
        [self setInactive];
    }
}

- (void)setActive {
    self.isActive = YES;

    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];

    // Draw circular node
    CGRect centerPointRect = CGRectMake(-12, -12, 32, 32);
    self.activeCircle = [CAShapeLayer layer];
    [self.activeCircle setPath:[[UIBezierPath bezierPathWithOvalInRect:centerPointRect] CGPath]];
    [self.activeCircle setStrokeColor:styles.tripMetaCardActiveColor.CGColor];
    [self.activeCircle setFillColor:styles.tripMetaCardActiveColor.CGColor];
    [[self layer] addSublayer:self.activeCircle];

    // Add checkmark
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    UIImage *img = [UIImage imageNamed:@"smallCheckmark" inBundle:bundle compatibleWithTraitCollection:NULL];
    self.isActiveImg = [[CALayer alloc] init];
    self.isActiveImg.contents = (id) [img CGImage];
    self.isActiveImg.frame = centerPointRect;
    [self.layer addSublayer:self.isActiveImg];
}

- (void)setInactive {
    self.isActive = NO;
    if (self.activeCircle) {
        [self.activeCircle removeFromSuperlayer];
    }
    if (self.isActiveImg) {
        [self.isActiveImg removeFromSuperlayer];
    }
}



@end
