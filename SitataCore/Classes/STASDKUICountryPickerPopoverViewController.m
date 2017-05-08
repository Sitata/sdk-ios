//
//  STASDKUICountryPickerPopoverViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-03-17.
//
//

#import "STASDKUICountryPickerPopoverViewController.h"

#import "STASDKUIEmergNumbersViewController.h"
#import "STASDKMCountry.h"

@interface STASDKUICountryPickerPopoverViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *countryPicker;

@property RLMArray<STASDKMCountry*> *countries;

@end


@implementation STASDKUICountryPickerPopoverViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.countryPicker.dataSource = self;
    self.countryPicker.delegate = self;

    [self loadCountries];

}

- (void)viewWillDisappear:(BOOL)animated {
    // Send back country to parent
    NSInteger row = [self.countryPicker selectedRowInComponent:0];
    if (self.countries.count > 0) {
        STASDKMCountry *country = [self.countries objectAtIndex:row];
        [self.parentVC onChangeCountry:country];
    } else {
        [self.parentVC onChangeCountry:NULL];
    }
}


- (void)loadCountries {
    self.countries = [STASDKMCountry allCountries];
}




#pragma mark - Picker Stuff


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.countries count];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    STASDKMCountry *country = [self.countries objectAtIndex:row];
    return country.name;
}

// Pulling selected row from picker in viewWillDisappear so we can
// effectively allow for selection of firstRow. Downside to this is that it does
// not allow the user to dismiss popup without selecting anything.
//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//
//}


#pragma mark - View Actions

- (IBAction)onFinished:(id)sender {
    // close
    [self dismissViewControllerAnimated:TRUE completion:NULL];
}

@end
