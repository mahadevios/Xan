//
//  ListViewController.h
//  Cube
//
//  Created by mac on 27/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Database.h"
#import "APIManager.h"
#import "AppPreferences.h"
#import "Constants.h"
#import "TransferredOrDeletedAudioDetailsViewController.h"

@interface ListViewController : UIViewController<UIGestureRecognizerDelegate,UISplitViewControllerDelegate,UISearchBarDelegate,UISearchResultsUpdating>
{
    UIAlertController *alertController;
    UIAlertAction *actionDelete;
    UIAlertAction *actionCancel;
    BOOL deleted;
    NSMutableArray* arrayOfMarked;
    BOOL isMultipleFilesActivated;
    BOOL toolBarAdded;
    UILabel* selectedCountLabel;
    BOOL collapseDetailViewController;
    TransferredOrDeletedAudioDetailsViewController* detailVC;
    BOOL isShownDetailsView;
    BOOL searchBecomeResponsderFromUploadAlert;
}
- (IBAction)segmentChanged:(id)sender;
@property (strong, nonatomic) NSMutableArray* checkedIndexPath;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property(nonatomic)BOOL longPressAdded;
@property(nonatomic, strong)NSString* currentViewName;
@property (strong, nonatomic) UISearchController *searchController;

@property (strong, nonatomic) NSMutableArray* transferredListPredicateArray;
@property (strong, nonatomic) NSMutableArray* deletedListPredicateArray;
@property (weak, nonatomic) IBOutlet UIView *serachBarBGView;




@end
