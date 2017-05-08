//
//  STASDKSuperFoldCell.h
//  Pods
//
//  Created by Adam St. John on 2017-04-30.
//
//

#import <UIKit/UIKit.h>



@interface STASDKSuperFoldCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *sectionLbl;
@property (weak, nonatomic) IBOutlet UILabel *contentLbl;
@property (weak, nonatomic) IBOutlet UIView *detailContainerView;
@property (weak, nonatomic) IBOutlet UIView *titleContainer;

@property (nonatomic, assign) BOOL withDetails;

- (void)animateOpen;
- (void)animateClosed;
- (void)setShadow;

@end
