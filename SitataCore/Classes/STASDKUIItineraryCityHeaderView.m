//
//  STASDKUIItineraryCityHeaderView.m
//  Pods
//
//  Created by Adam St. John on 2017-07-09.
//
//

#import "STASDKUIItineraryCityHeaderView.h"

#import "STASDKDataController.h"
//#import "STASDKMDestination.h"
//#import "STASDKMCountry.h"
//


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


- (id) initWithDestination:(STASDKMDestination*)destination {
    self = [super init];
    if (self) {
        // grab destination country
//        STASDKMCountry *country = [STASDKMCountry findBy:destination.countryId];
//        if (country) {
//            self.titleLbl.alpha = 1.0;
//
//            // Draw circular node
//            CAShapeLayer *circleLayer = [CAShapeLayer layer];
//            [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(23, 15, 20, 20)] CGPath]];
//            [circleLayer setStrokeColor:[[UIColor darkGrayColor] CGColor]];
//            [circleLayer setFillColor:[[UIColor darkGrayColor] CGColor]];
//            [[self layer] addSublayer:circleLayer];
//
//            // Draw timeline
//            UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(31.0, 0, 3.0, 50.0)];
//            bar.backgroundColor = [UIColor darkGrayColor];
//            [self addSubview:bar];
//
//            self.addCountryBtn.alpha = 0.0;
//            self.addCountryImg.alpha = 0.0;
//            self.titleLbl.text = country.name;
//        }
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




@end
