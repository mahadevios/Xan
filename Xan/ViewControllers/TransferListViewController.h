//
//  TransferListViewController.h
//  Cube
//
//  Created by mac on 28/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioDetailsViewController.h"

@interface TransferListViewController : UIViewController<UIGestureRecognizerDelegate,UISplitViewControllerDelegate,UISearchBarDelegate, UISearchResultsUpdating,MyClassDelegate>
{

    UIAlertController *alertController;
    UIAlertAction *actionDelete;
    UIAlertAction *actionCancel;
    BOOL deleted;
    NSDictionary* audiorecordDict;
    NSMutableArray* cellSelected;
    BOOL isMultipleFilesActivated;
    BOOL toolBarAdded;
    NSMutableArray* arrayOfMarked;
    UILabel* selectedCountLabel;
    NSMutableArray* progressIndexPathArray;
    NSMutableArray* progressIndexPathArrayCopy;

    NSMutableDictionary* indexPathFileNameDict;

    NSTimer* progressTimer;
    
    BOOL suspended;
    
    AudioDetailsViewController* detailVC;
    
    BOOL searchBecomeResponsderFromUploadAlert;
    
    

}
@property(nonatomic,strong)NSString* currentViewName;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray* checkedIndexPath;

@property (strong, nonatomic) UISearchController *searchController;

@property (strong, nonatomic) NSMutableArray* genericFilesArray;

@property (strong, nonatomic) NSMutableArray* genericFilesPredicateArray;

@property(nonatomic)BOOL longPressAdded;

@property (weak, nonatomic) IBOutlet UIView *serachBarBGView;

@end
