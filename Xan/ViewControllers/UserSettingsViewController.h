//
//  UserSettingsViewController.h
//  Cube
//
//  Created by mac on 29/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Database.h"
#import "APIManager.h"
#import "AppPreferences.h"
#import "Constants.h"
#import "MBProgressHUD.h"

@interface UserSettingsViewController : UIViewController<UIGestureRecognizerDelegate,UITextFieldDelegate>
{
    NSMutableArray* recordSettingsItemsarray;
    NSMutableArray* storageManagementItemsArray;
    NSMutableArray* PlaybackAutoRewindByArray;
    NSMutableArray* popUpOptionsArray;
    NSMutableArray* radioButtonArray;
    UITapGestureRecognizer* tap;
    UITapGestureRecognizer* tap1;
    MBProgressHUD* hud;
    UIView* abbreviationPopupView;
    AppPreferences* app;
}
@property (weak, nonatomic) IBOutlet UIView *versioSuperView;
@property (weak, nonatomic) IBOutlet UITableView *poUpTableView;
@property (weak, nonatomic) IBOutlet UITableView *userSettingsTableView;
- (IBAction)backButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *versionLabelXConstraint;
- (IBAction)versionUpdateButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *versionUpdateButton;
@end
