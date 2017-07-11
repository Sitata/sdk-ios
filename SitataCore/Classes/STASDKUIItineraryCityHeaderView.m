//
//  STASDKUIItineraryCityHeaderView.m
//  Pods
//
//  Created by Adam St. John on 2017-07-09.
//
//

#import "STASDKUIItineraryCityHeaderView.h"

#import "STASDKDataController.h"
#import "STASDKMDestinationLocation.h"


@interface STASDKUIItineraryCityHeaderView()

@property STASDKMDestinationLocation *location;

@end


@implementation STASDKUIItineraryCityHeaderView

@synthesize delegate;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        STASDKDataController *ctrl = [STASDKDataController sharedInstance];
        NSBundle *bndl = [ctrl sdkBundle];
        NSArray *nib = [bndl loadNibNamed:@"TBItineraryCityHeader" owner:self options:NULL];
        self = [nib objectAtIndex:0];
        self.frame = frame;
        [self commonInit];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}


- (id) initWithLocation:(STASDKMDestinationLocation*)location {
    self = [super init];
    if (self) {
        self.location = location;
        self.titleLbl.alpha = 1.0;

        // Draw circular node
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(66, 9, 17, 17)] CGPath]];
        [circleLayer setStrokeColor:[[UIColor darkGrayColor] CGColor]];
        [circleLayer setFillColor:[[UIColor darkGrayColor] CGColor]];
        [[self layer] addSublayer:circleLayer];

        // Draw timeline
        UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(31.0, 0, 3.0, 50.0)];
        bar.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:bar];

        self.addCityBtn.alpha = 0.0;
        self.addCityImg.alpha = 0.0;
        self.titleLbl.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        self.titleLbl.text = location.friendlyName;
        self.removeCityImg.tintColor = [UIColor darkGrayColor];

    }
    return self;
}


- (void) commonInit {
    self.titleLbl.alpha = 0.0; // hide city title label
    self.addCityBtn.alpha = 1.0;
    self.addCityImg.alpha = 1.0;

    // draw timeline bar
    UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(31.0, 0, 3.0, 50.0)];
    bar.backgroundColor = [UIColor darkGrayColor];
    [self addSubview:bar];

    self.addCityImg.tintColor = [UIColor darkGrayColor];
    self.titleLbl.textColor = [UIColor darkGrayColor];
}

- (void) removeRemoveBtn {
    [self.removeCityImg removeFromSuperview];
}

- (IBAction)onAddCity:(id)sender {
    if (self.delegate) {
        [self.delegate onAddCity:sender destination:self.parentDestination];
    }
}

- (IBAction)onAddCityImg:(id)sender {
    if (self.delegate) {
        [self.delegate onAddCity:sender destination:self.parentDestination];
    }
}

- (IBAction)onRemoveCityImg:(id)sender {
    if (self.delegate) {
        [self.delegate onRemoveCity:sender removed:self.location];
    }
}



@end
