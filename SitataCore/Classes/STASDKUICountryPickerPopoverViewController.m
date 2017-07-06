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
#import "STASDKDataController.h"

@interface STASDKUICountryPickerPopoverViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *countryPicker;

@property RLMArray<STASDKMCountry*> *countries;

@property bool multiStage;

@end


@implementation STASDKUICountryPickerPopoverViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.multiStage) {
        [self.actionBtn setTitle:[[STASDKDataController sharedInstance] localizedStringForKey:@"NEXT"]];
    }
    self.countryPicker.dataSource = self;
    self.countryPicker.delegate = self;

    [self loadCountries];

}

- (void)viewWillDisappear:(BOOL)animated {
    // Send back country to parent
    if (!self.multiStage) {
        [self.delegate onChangeCountry:[self chosenCountry]];
    }
}


- (void)loadCountries {
    self.countries = [STASDKMCountry allCountries];
}

- (void)setForMultiStage {
    self.multiStage = YES;
}

- (STASDKMCountry*)chosenCountry {
    if (self.countries.count > 0) {
        NSInteger row = [self.countryPicker selectedRowInComponent:0];
        return [self.countries objectAtIndex:row];
    } else {
        return NULL;
    }
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

// close
- (IBAction)onFinished:(id)sender {

    if (self.multiStage) {
        // if multistage, then we don't dismiss this controller and assume delegate/parent will handle it
        // in this scenario,
        [self.delegate onChangeCountry:[self chosenCountry]];
    } else {
        // dismiss view controller and viewWillDisappear will be called
        [self dismissViewControllerAnimated:TRUE completion:NULL];
    }

}

@end
