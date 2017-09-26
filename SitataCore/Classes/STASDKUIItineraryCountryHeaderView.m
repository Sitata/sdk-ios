//
//  STASDKUIItineraryCountryHeaderView.m
//  Pods
//
//  Created by Adam St. John on 2017-07-03.
//
//

#import "STASDKUIItineraryCountryHeaderView.h"

#import "STASDKDataController.h"
#import "STASDKMDestination.h"
#import "STASDKMCountry.h"
#import "STASDKUI.h"
#import "STASDKUIStylesheet.h"


@interface STASDKUIItineraryCountryHeaderView()

@property STASDKMDestination *destination;

@end

@implementation STASDKUIItineraryCountryHeaderView

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
        NSArray *nib = [bndl loadNibNamed:@"TBItineraryCountryHeader" owner:self options:NULL];
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


- (id) initWithDestination:(STASDKMDestination*)destination {
    self = [super init];
    if (self) {
        STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];

        // grab destination country
        self.destination = destination;
        STASDKMCountry *country = [STASDKMCountry findBy:destination.countryId];
        if (country) {
            self.titleLbl.alpha = 1.0;

            // Draw circular node
            CAShapeLayer *circleLayer = [CAShapeLayer layer];
            [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(23, 15, 20, 20)] CGPath]];
            [circleLayer setStrokeColor:[styles.tripTimelineColor CGColor]];
            [circleLayer setFillColor:[styles.tripTimelineColor CGColor]];
            [[self layer] addSublayer:circleLayer];

            // Draw timeline
            UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(31.0, 0, 3.0, 50.0)];
            bar.backgroundColor = styles.tripTimelineColor;
            [self addSubview:bar];

            // date
            self.dateLbl.textColor = [UIColor darkGrayColor];
            self.dateLbl.text = [STASDKUI dateDisplayShort:[destination departureDate]];

            self.addCountryBtn.alpha = 0.0;
            self.addCountryImg.alpha = 0.0;
            self.titleLbl.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
            self.titleLbl.text = country.name;

        }
    }
    return self;
}


- (void) commonInit {
    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];

    self.titleLbl.alpha = 0.0; // hide country title label
    self.addCountryBtn.alpha = 1.0;
    self.addCountryImg.alpha = 1.0;
    self.addCountryImg.tintColor = styles.tripTimelineColor;

    // draw timeline bar
    CGFloat imageTop = self.addCountryBtn.frame.origin.y;
    CGFloat imageSpace = 7.0;

    UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(31.0, 0, 3.0, imageTop+imageSpace)];
    bar.backgroundColor = styles.tripTimelineColor;
    [self addSubview:bar];

    self.addCountryImg.tintColor = styles.tripBuilderAddColor;
    self.removeCountryImg.tintColor = styles.tripBuilderRemoveColor;
    self.titleLbl.textColor = styles.titleTextColor;
    self.titleLbl.font = styles.titleFont;
    self.addCountryBtn.titleLabel.font = styles.buttonFont;
}


- (void) removeRemoveBtn {
    [self.removeCountryImg removeFromSuperview];
}

- (void) removeDateLbl {
    [self.dateLbl removeFromSuperview];
}

- (IBAction)onAddCountry:(id)sender {
    if (self.delegate) {
        [self.delegate onAddCountry:sender];
    }
}

- (IBAction)onAddCountryImg:(id)sender {
    if (self.delegate) {
        [self.delegate onAddCountry:sender];
    }
}

- (IBAction)onRemoveCountryImg:(id)sender {
    if (self.delegate) {
        [self.delegate onRemoveCountry:sender removed:self.destination];
    }
}


@end
