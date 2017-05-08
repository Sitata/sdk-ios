//
//  STASDKUIContactDetailTableViewCell.m
//  Pods
//
//  Created by Adam St. John on 2017-03-15.
//
//

#import "STASDKUIContactDetailTableViewCell.h"

#import "STASDKDataController.h"
#import "STASDKMContactDetail.h"
#import "STASDKMHospital.h"

#import <MapKit/MapKit.h>

@implementation STASDKUIContactDetailTableViewCell

@synthesize hospital = _hospital;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state

}


- (void)setForContactDetail:(STASDKMContactDetail*)detail {
    self.contactDetail = detail;
    
    self.valueLbl.text = detail.val;

    [self setNoteValue:detail];



    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    NSString *imgStr;
    ContactDetailType cType = self.contactDetail.typ;
    if (self.forcePhone) {
        imgStr = @"PhonecallIcon";
    } else {
        switch (cType) {
            // fall through all phone numbers
            case OfficePhone:
            case Fax:
            case HomePhone:
            case MobilePhone:
            case Police:
            case Fire:
            case Ambulance:
            case AllEmergency:
                // all phone numbers handled
                imgStr = @"PhonecallIcon";
                break;
            case Website:
                imgStr = @"WebIcon";
                break;
            case EmailAddress:
                imgStr = @"EnvelopeIcon";
                break;
            default:
                // Other = 99
                // don't do anything - it should be hidden anyway...
                break;
        }
    }
    if (imgStr != NULL && [imgStr length] > 0) {
        UIImage *img = [UIImage imageNamed:imgStr inBundle:bundle compatibleWithTraitCollection:NULL];
        [self.actionBtn setImage:img forState:UIControlStateNormal];
    } else {
        [self.actionBtn setAlpha:0.0];
    }
}

- (void)setForAddress:(NSString*)addressStr {
    self.valueLbl.text = addressStr;
    [self.noteLbl removeFromSuperview]; // no note for this one

    // set action button icon
    [self.actionBtn setTitle:NULL forState:UIControlStateNormal];
    NSBundle *bundle = [[STASDKDataController sharedInstance] sdkBundle];
    UIImage *img = [UIImage imageNamed:@"NavigationIcon" inBundle:bundle compatibleWithTraitCollection:NULL];

    [self.actionBtn setImage:img forState:UIControlStateNormal];
}

- (void)setNoteValue:(STASDKMContactDetail*)detail {
    // This will add additional text to the note field for display to
    // the user. For example "Fire" if it is a fire phone number.
    // Necessary because we're not using icons.
    NSString *prefix;
    STASDKDataController *dc = [STASDKDataController sharedInstance];
    ContactDetailType cType = self.contactDetail.typ;
    switch (cType) {
        // fall through all phone numbers
        case OfficePhone:
            prefix = [dc localizedStringForKey:@"CONTACT_OFFICE"];
            break;
        case Fax:
            prefix = [dc localizedStringForKey:@"CONTACT_FAX"];
            break;
        case HomePhone:
            prefix = [dc localizedStringForKey:@"CONTACT_HOME"];
            break;
        case MobilePhone:
            prefix = [dc localizedStringForKey:@"CONTACT_MOBILE"];
            break;
        case Police:
            prefix = [dc localizedStringForKey:@"CONTACT_POLICE"];
            break;
        case Fire:
            prefix = [dc localizedStringForKey:@"CONTACT_FIRE"];
            break;
        case Ambulance:
            prefix = [dc localizedStringForKey:@"CONTACT_AMBULANCE"];
            break;
        case AllEmergency:
            prefix = [dc localizedStringForKey:@"CONTACT_ALL_EMERG"];
            break;
        default:
            // No prefix to note value
            break;
    }

    if ((prefix == NULL || [prefix length] <= 0) &&
        ([detail.note isEqual:[NSNull null]] || (![detail.note isEqual:[NSNull null]] && [detail.note length] <= 0))) {
        [self.noteLbl removeFromSuperview];
        return;
    }

    if (prefix == NULL || [prefix length] <= 0) {
        self.noteLbl.text = detail.note;
    } else {
        if (![detail.note isEqual:[NSNull null]] && [detail.note length] > 0) {
            self.noteLbl.text = [NSString stringWithFormat:@"%@ - %@", prefix, detail.note];
        } else {
            self.noteLbl.text = prefix;
        }

    }
}




- (IBAction)onActionTouch:(id)sender {
    if (self.contactDetail == NULL) {
        // address so we need to open up directions to hospital
        [self handleDirections];
    } else {
        if (self.forcePhone) {
            [self handleDialPhone];
        } else {
            // action dependent upon type of contact detail
            ContactDetailType cType = self.contactDetail.typ;
            switch (cType) {

                // fall through all phone numbers
                case OfficePhone:
                case Fax:
                case HomePhone:
                case MobilePhone:
                case Police:
                case Fire:
                case Ambulance:
                case AllEmergency:
                    // all phone numbers handled
                    [self handleDialPhone];
                    break;
                case Website:
                    [self handleWebsite];
                    break;
                case EmailAddress:
                    [self handleEmail];
                    break;
                default:
                    // Other = 99
                    // don't do anything - it should be hidden anyway...
                    break;
            }
        }
    }
}

- (void)handleDirections {
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.hospital.latitude, self.hospital.longitude);

    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:self.hospital.name];
    NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
    [mapItem openInMapsWithLaunchOptions:options];
}

- (void)handleDialPhone {
    NSString *phoneNumber = [NSString stringWithFormat:@"tel://%@", self.contactDetail.val];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (void)handleWebsite {
    NSURL *url = [NSURL URLWithString:self.contactDetail.val];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)handleEmail {
    NSString *email = [NSString stringWithFormat:@"mailto:%@", self.contactDetail.val];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}


@end
