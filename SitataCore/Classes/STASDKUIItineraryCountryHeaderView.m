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


- (id) initWithDestination:(STASDKMDestination*)destination isLast:(bool)isLast {
    self = [super init];
    if (self) {
        // grab destination country
        self.destination = destination;
        STASDKMCountry *country = [STASDKMCountry findBy:destination.countryId];
        if (country) {
            self.titleLbl.alpha = 1.0;

            // Draw circular node
            CAShapeLayer *circleLayer = [CAShapeLayer layer];
            [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(23, 17, 20, 20)] CGPath]];
            [circleLayer setStrokeColor:[[UIColor darkGrayColor] CGColor]];
            [circleLayer setFillColor:[[UIColor darkGrayColor] CGColor]];
            [[self layer] addSublayer:circleLayer];

            // Draw timeline
            UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(31.0, 0, 3.0, 50.0)];
            bar.backgroundColor = [UIColor darkGrayColor];
            [self addSubview:bar];

            // date
            self.dateLbl.textColor = [UIColor darkGrayColor];
            self.dateLbl.text = [STASDKUI dateDisplayShort:[destination departureDate]];

            self.addCountryBtn.alpha = 0.0;
            self.addCountryImg.alpha = 0.0;
            self.titleLbl.text = country.name;
        }

        // only last country in list may be removed
        if (!isLast) {
            [self removeRemoveBtn];
        }
    }
    return self;
}


- (void) commonInit {
    self.titleLbl.alpha = 0.0; // hide country title label
    self.addCountryBtn.alpha = 1.0;
    self.addCountryImg.alpha = 1.0;

    // draw timeline bar
    CGFloat imageTop = self.addCountryBtn.frame.origin.y;
    CGFloat imageSpace = 7.0;

    UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(31.0, 0, 3.0, imageTop+imageSpace)];
    bar.backgroundColor = [UIColor darkGrayColor];
    [self addSubview:bar];

    self.addCountryImg.tintColor = [UIColor darkGrayColor];
    self.removeCountryImg.tintColor = [UIColor darkGrayColor];
    self.titleLbl.textColor = [UIColor darkGrayColor];
}


- (void) removeRemoveBtn {
    [self.removeCountryImg removeFromSuperview];

    // adjust date label
    [self.dateLbl.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-5.0].active = true;
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
        [self.delegate onRemoveCountry:sender];
    }
}


@end
