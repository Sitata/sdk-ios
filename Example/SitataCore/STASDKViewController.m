//
//  STASDKViewController.m
//  SitataCore
//
//  Created by Adam St. John on 12/20/2016.
//  Copyright (c) 2016 Adam St. John. All rights reserved.
//

#import "STASDKViewController.h"
#import <SitataCore/STASDKUI.h>
#import <SitataCore/STASDKMTrip.h>


#import <SitataCore/STASDKController.h>
#import <SitataCore/STASDKMTraveller.h>
#import <SitataCore/STASDKMUserSettings.h>


@interface STASDKViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@end

@implementation STASDKViewController

NSArray *cellNames;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    cellNames = @[@"alerts", @"advisories", @"diseases", @"vaccinations", @"medications", @"hospitals", @"safety", @"emerg", @"tripBuilder", @"test"];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellName = [cellNames objectAtIndex:[indexPath row]];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellName forIndexPath:indexPath];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellName = [cellNames objectAtIndex:[indexPath row]];

    if ([cellName isEqualToString:@"alerts"]) {
        [STASDKUI showAlerts];
    } else if ([cellName isEqualToString:@"advisories"]) {
        [STASDKUI showAdvisories];
    } else if ([cellName isEqualToString:@"diseases"]) {
        [STASDKUI showTripDiseases];
    } else if ([cellName isEqualToString:@"vaccinations"]) {
        [STASDKUI showTripVaccinations];
    } else if ([cellName isEqualToString:@"medications"]) {
        [STASDKUI showTripMedications];
    } else if ([cellName isEqualToString:@"hospitals"]) {
        [STASDKUI showTripHospitals];
    } else if ([cellName isEqualToString:@"safety"]) {
        [STASDKUI showTripSafety];
    } else if ([cellName isEqualToString:@"emerg"]) {
        [STASDKUI showEmergencyNumbers];
    } else if ([cellName isEqualToString:@"tripBuilder"]) {
        [self doTripBuilder];
    } else if ([cellName isEqualToString:@"test"]) {

        // TODO: DO TEST STUFF HERE AND THEN REMOVE
//
//        
        STASDKMTraveller *trav = [STASDKMTraveller findFirst];
        STASDKMUserSettings *settings = trav.settings;
        RLMRealm *realm = [[STASDKController sharedInstance] theRealm];
        [realm transactionWithBlock:^{
            settings.sendAllGoodPush = YES;
            settings.sendAllGoodEmail = true;
        }];
        NSError *error;
        [settings backgroundUpdate:&error];
    }
}

- (IBAction)onAlerts:(id)sender {
    [STASDKUI showAlerts];
}
- (IBAction)onAdvisories:(id)sender {
    [STASDKUI showAdvisories];
}
- (IBAction)onDiseases:(id)sender {
    [STASDKUI showTripDiseases];
}
- (IBAction)onVaccines:(id)sender {
    [STASDKUI showTripVaccinations];
}
- (IBAction)onMedications:(id)sender {
    [STASDKUI showTripMedications];
}
- (IBAction)onHospitals:(id)sender {
    [STASDKUI showTripHospitals];
}
- (IBAction)onSafety:(id)sender {
    [STASDKUI showTripSafety];
}
- (IBAction)onEmerg:(id)sender {
    [STASDKUI showEmergencyNumbers];
}
- (IBAction)onTripBuilder:(id)sender {
    [self doTripBuilder];
}


- (void)doTripBuilder {
    STASDKMTrip *trip = [STASDKMTrip currentTrip];
    [STASDKUI showTripBuilder:trip.identifier];
}



@end
