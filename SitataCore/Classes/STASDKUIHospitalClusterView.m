//
//  STASDKUIHospitalClusterView.m
//  Pods
//
//  Created by Adam St. John on 2017-03-12.
//
//

#import "STASDKUIHospitalClusterView.h"
#import "STASDKDataController.h"
#import "STASDKMHospital.h"


@interface STASDKUIHospitalClusterView ()

@property (nonatomic) UILabel *countLabel;

@end

@implementation STASDKUIHospitalClusterView


//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    return [super initWithCoder:aDecoder];
//}



- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // do other custom stuff
    }
    return self;
}

- (void)setUnique:(BOOL)isUnique {
    self.uniqueLocation = isUnique;

    // clusters don't have titles, but a single unique cluster (map pin) can.
    self.canShowCallout = isUnique;

    [self setImage];
}

- (void)setImage {
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    NSString *imgName;
    if (self.uniqueLocation) {
        if ([self isAccredited]) {
            imgName = @"MapPinHospitalAccredited";
        } else {
            imgName = @"MapPinHospital";
        }

    } else {
        imgName = @"MapGroupHospital";
    }
    self.image = [UIImage imageNamed:imgName inBundle:bundle compatibleWithTraitCollection:NULL];
}

- (BOOL)isAccredited {
    SEL selAnnotations = NSSelectorFromString(@"annotations");
    SEL selHospital = NSSelectorFromString(@"hospital");

    if ([self.annotation respondsToSelector:selAnnotations]) {

        for (id ann in [self.annotation performSelector:selAnnotations]) {

            // Check to see if we have an STASDKUIHospitalPin
            if ([ann respondsToSelector:selHospital]) {
                STASDKMHospital *hos = [ann performSelector:selHospital];
                BOOL isFound = [hos isAccredited];
                if (isFound) {return YES;} // break out of loop
            }
        }
    }
    return NO;
}




@end
