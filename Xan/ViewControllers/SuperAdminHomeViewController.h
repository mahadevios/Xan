//
//  SuperAdminHomeViewController.h
//  Xan
//
//  Created by Martina Makasare on 7/23/19.
//  Copyright © 2019 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SuperAdminHomeViewController : UIViewController

{
    UITapGestureRecognizer* hospitalViewTapRecogniser;
    UITapGestureRecognizer* departmentViewTapRecogniser;
    UITapGestureRecognizer* practitionerViewTapRecogniser;
    UITapGestureRecognizer* secretaryViewTapRecogniser;
}
@property (weak, nonatomic) IBOutlet UIView *hospitalView;
@property (weak, nonatomic) IBOutlet UIView *departmentView;
@property (weak, nonatomic) IBOutlet UIView *practitionerView;
@property (weak, nonatomic) IBOutlet UIView *secretaryView;
@property (weak, nonatomic) IBOutlet UILabel *hospitalLabel;
@property (weak, nonatomic) IBOutlet UILabel *practitionerLabel;
@property (weak, nonatomic) IBOutlet UILabel *secretaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *Department;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

NS_ASSUME_NONNULL_END
