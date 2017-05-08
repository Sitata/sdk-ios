//
//  STASDKUICountrySwitcherViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-03-09.
//
//

#import "STASDKUICountrySwitcherViewController.h"
#import "STASDKMCountry.h"
#import "STASDKUISafetyViewController.h"

#import "STASDKUIStylesheet.h"


NSNotificationName const NotifyCountrySwitcherChanged = @"Sitata:CountrySwitcherChanged";
NSString *const NotifyKeyCountriesIndex = @"countriesIndex";



@interface STASDKUICountrySwitcherViewController ()

@end

@implementation STASDKUICountrySwitcherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (self.countries.count > 0) {
        [self setControls];
    } else {
        [self.previousPageBtn setAlpha:0.0];
        [self.nextPageBtn setAlpha:0.0];
        [self.countryNameLbl setAlpha:0.0];
    }

    STASDKUIStylesheet *styles = [STASDKUIStylesheet sharedInstance];
    self.view.backgroundColor = styles.countrySwitcherBackgroundColor;
    self.nextPageBtn.tintColor = styles.countrySwitcherButtonColor;
    self.previousPageBtn.tintColor = styles.countrySwitcherButtonColor;
    self.countryNameLbl.textColor = styles.countrySwitcherTitleColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setControls {
    if (self.pageIndex == 0) {
        [self.previousPageBtn setAlpha:0.0];
    } else {
        [self.previousPageBtn setAlpha:1.0];
    }
    if (self.pageIndex == self.pageCount - 1) {
        [self.nextPageBtn setAlpha:0.0];
    } else {
        [self.nextPageBtn setAlpha:1.0];
    }

    [self setCountry];
}


- (void)setCountry {
    STASDKMCountry *country = [self.countries objectAtIndex:self.pageIndex];
    self.countryNameLbl.text = country.name;
}

- (IBAction)onNextTouch:(id)sender {
    self.pageIndex++;
    [self setControls];
    // broadcast country change
    [self broadcast];
}

- (IBAction)onPrevTouch:(id)sender {
    self.pageIndex--;
    [self setControls];
    // broadcast country change
    [self broadcast];
}

- (void)broadcast {
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:self.pageIndex], NotifyKeyCountriesIndex, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotifyCountrySwitcherChanged object:self userInfo:userInfo];
}


@end
