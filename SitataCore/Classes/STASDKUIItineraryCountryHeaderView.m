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
        // grab destination country
        STASDKMCountry *country = [STASDKMCountry findBy:destination.countryId];
        if (country) {
            self.titleLbl.alpha = 1.0;
            self.timelineImg.alpha = 1.0;
            self.timelineImg.tintColor = [UIColor darkGrayColor];

            self.addCountryBtn.alpha = 0.0;
            self.addCountryImg.alpha = 0.0;
            self.titleLbl.text = country.name;
        }
    }
    return self;
}


- (void) commonInit {
    self.titleLbl.alpha = 0.0; // hide country title label
    self.timelineImg.alpha = 0.0;
    self.addCountryBtn.alpha = 1.0;
    self.addCountryImg.alpha = 1.0;

    // draw timeline bar
    CGFloat imageTop = self.timelineImg.frame.origin.y;
    CGFloat imageSpace = 10.0;

    UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(31.0, 0, 3.0, imageTop+imageSpace)];
    bar.backgroundColor = [UIColor darkGrayColor];
    [self addSubview:bar];


    self.addCountryImg.tintColor = [UIColor darkGrayColor];

//    self.backgroundColor = [UIColor purpleColor];
    self.titleLbl.textColor = [UIColor darkGrayColor];
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


@end
