//
//  HomeViewController.h
//  Cube
//
//  Created by mac on 27/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Database.h"
#import "APIManager.h"
#import "AppPreferences.h"
#import "Constants.h"
#import "LoginViewController.h"
#import "CustomSplitViewController.h"

@interface HomeViewController : UIViewController<UISplitViewControllerDelegate>
{
    UITapGestureRecognizer* transferredTodayViewTapRecogniser;
    UITapGestureRecognizer* awaitingViewTapRecogniser;
    UITapGestureRecognizer* completedDocViewTapRecogniser;
    UITapGestureRecognizer* vrsDocViewTapRecogniser;

    UIView* overlayView;
    UITapGestureRecognizer* tap;
    APIManager* app;
    Database* db;
    UIAlertController *alertController;
    UIAlertAction *actionDelete;
    UIAlertAction *actionCancel;
    MBProgressHUD* hud;
    NSURLSession* session;
    BOOL isTemplateDataReceived;
    
    
}
@property (weak, nonatomic) IBOutlet UIView *transferredView;
@property (weak, nonatomic) IBOutlet UIView *awaitingTransferView;
@property (weak, nonatomic) IBOutlet UIView *transferFailedView;
@property (weak, nonatomic) IBOutlet UIView *VRSDOCFilesView;
@property (weak, nonatomic) IBOutlet UILabel *failedCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *VRSFilesCountLabel;
@property (strong, nonatomic) NSMutableArray *completedFilesResponseArray;
@property (strong, nonatomic) NSMutableArray *completedFilesForTableViewArray;
@property (strong, nonatomic) NSMutableArray *downloadingFilesDictationIdsArray;
@property (strong, nonatomic) NSArray *uploadedFilesArray;
@property (weak, nonatomic) IBOutlet UILabel *completedDocCountLabel;
@property (weak, nonatomic) IBOutlet UIView *transferFailedCountView;
@property (weak, nonatomic) IBOutlet UILabel *transferFailedCountLabel;
@property(nonatomic, strong)NSMutableArray* VRSDocFilesArray;
@property (weak, nonatomic) IBOutlet UIView *subTransferredView;
@property (weak, nonatomic) IBOutlet UIView *subAwaitingView;
@property (weak, nonatomic) IBOutlet UIView *subVRSView;
@property (weak, nonatomic) IBOutlet UILabel *dictatorNameLabel;
@property (nonatomic) __block NSInteger kAppITunesItemIdentifier;
@end
