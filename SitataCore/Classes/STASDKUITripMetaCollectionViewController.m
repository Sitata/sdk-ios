//
//  STASDKUITripMetaCollectionViewController.m
//  Pods
//
//  Created by Adam St. John on 2017-07-11.
//
//

#import "STASDKUITripMetaCollectionViewController.h"

#import "STASDKMTrip.h"
#import "STASDKUITripMetaCollectionViewCell.h"
#import "STASDKDefines.h"
#import "STASDKDataController.h"
#import <Realm/Realm.h>

@interface STASDKUITripMetaCollectionViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel *headerLbl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation STASDKUITripMetaCollectionViewController

static NSString * const reuseIdentifier = @"metaCell";
static NSInteger const kCardSize = 100;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes

    STASDKDataController *dataCtrl = [STASDKDataController sharedInstance];
    NSBundle *bundle = [dataCtrl sdkBundle];
    [self.collectionView registerNib:[UINib nibWithNibName:@"STASDKUITripMetaCollectionViewCell" bundle:bundle] forCellWithReuseIdentifier:reuseIdentifier];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;


    // Do any additional setup after loading the view.
    NSString *headerStr;

    if (self.mode == TripPurpose) {
        headerStr = [dataCtrl localizedStringForKey:@"TB_TRIP_TYPE_HEADER"];
    } else {
        // activities
        headerStr = [dataCtrl localizedStringForKey:@"TB_TRIP_ACTIVITIES_HEADER"];
//        "TB_TRIP_ACTIVITIES_HEADER" = "What Will You Be Doing?";
//        "TB_TRIP_ACTIVITIES_SUBHEAD" = "(You Can Select More Than One)";
    }

    self.headerLbl.text = headerStr;



    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.mode == TripPurpose) {
        return 3; //TripTypeEnumSize();
    } else {
        // trip activities
        return 28; //TripActivityEnumSize();
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STASDKUITripMetaCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    NSInteger index = indexPath.row;
    [cell setFor:self.mode atIndex:index];

    if (self.mode == TripPurpose) {
        if (self.trip.tripType == (int)index) {
            [cell setActive];
        } else {
            [cell setInactive];
        }
    } else {
        if ([self.trip hasActivity:(int)index]) {
            [cell setActive];
        } else {
            [cell setInactive];
        }
    }
    
    return cell;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                               duration:(NSTimeInterval)duration{

    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected!");
    if (self.mode == TripPurpose) {
        [self.theRealm transactionWithBlock:^{
            self.trip.tripType = (int)indexPath.row;
        }];
        [self.collectionView reloadData]; // we redraw all at once to effecively switch between them
    } else {
        // activities - toggle cell
        STASDKUITripMetaCollectionViewCell *cell = (STASDKUITripMetaCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
        [cell toggleActive];
        int index = (int)indexPath.row;

        [self.theRealm transactionWithBlock:^{
            if ([self.trip hasActivity:index]) {
                [self.trip removeActivity:index];
            } else {
                [self.trip addActivity:index];
            }
        }];
    }
}


#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    return CGSizeMake(kCardSize, kCardSize);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
    insetForSectionAtIndex:(NSInteger)section {


    CGFloat topBottomInset = self.view.frame.size.height / 14.0;

    if (self.mode == TripPurpose) {
        // centered items
        CGFloat spacing = 1.0f;
        NSInteger cellCount = [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:section];
        CGFloat cellWidth = ((UICollectionViewFlowLayout*)collectionViewLayout).itemSize.width+((UICollectionViewFlowLayout*)collectionViewLayout).minimumInteritemSpacing;
        CGFloat totalCellWidth = cellWidth * cellCount + spacing * (cellCount - 1);
        CGFloat contentWidth = collectionView.frame.size.width-collectionView.contentInset.left-collectionView.contentInset.right;

        if( totalCellWidth < contentWidth )
        {
            CGFloat padding = (contentWidth - totalCellWidth) / 2.0;
            return UIEdgeInsetsMake(topBottomInset, padding, topBottomInset, padding);
        } else {
            return UIEdgeInsetsMake(topBottomInset, topBottomInset, topBottomInset, topBottomInset);
        }


    } else {
        // activities
        CGFloat leftRightPadding = self.view.frame.size.width / 10.0f;
        return UIEdgeInsetsMake(topBottomInset, leftRightPadding, topBottomInset, leftRightPadding);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.view.frame.size.height / 14.0f;
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
