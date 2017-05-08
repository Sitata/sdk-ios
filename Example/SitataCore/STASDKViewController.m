//
//  STASDKViewController.m
//  SitataCore
//
//  Created by Adam St. John on 12/20/2016.
//  Copyright (c) 2016 Adam St. John. All rights reserved.
//

#import "STASDKViewController.h"
#import <SitataCore/STASDKUI.h>


@interface STASDKViewController ()

@end

@implementation STASDKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onAlertsTouch:(id)sender {
    [STASDKUI showAlerts];
}

- (IBAction)onAdvisoriesTouch:(id)sender {
    [STASDKUI showAdvisories];
}

- (IBAction)onVaccinationsTouch:(id)sender {
    [STASDKUI showTripVaccinations];
}

- (IBAction)onMedicationsTouch:(id)sender {
    [STASDKUI showTripMedications];
}
- (IBAction)onDiseasesTouch:(id)sender {
    [STASDKUI showTripDiseases];
}
- (IBAction)onSafetyTouch:(id)sender {
    [STASDKUI showTripSafety];
}

- (IBAction)onHospitalsTouch:(id)sender {
    [STASDKUI showTripHospitals];
}
- (IBAction)onEmergTouch:(id)sender {
    [STASDKUI showEmergencyNumbers];
}

@end
