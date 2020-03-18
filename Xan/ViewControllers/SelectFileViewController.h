//
//  SelectFileViewController.h
//  Cube
//
//  Created by mac on 28/11/17.
//  Copyright © 2017 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonDelegate.h"
#import "EmptyViewController.h"

@interface SelectFileViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIDocumentInteractionControllerDelegate, UISplitViewControllerDelegate,UISearchBarDelegate, UISearchResultsUpdating>
{
    NSTimer* newRequestTimer;
    UIDocumentInteractionController* interactionController;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(readwrite , assign) id<CommonDelegate>delegate;
@property(nonatomic, strong)NSMutableArray* VRSDocFilesArray;
- (IBAction)backButtonPressed:(id)sender;
@property(nonatomic, strong)UIAlertController* alertController;
@property(nonatomic, strong)EmptyViewController* detailVC;
@property (weak, nonatomic) IBOutlet UIView *serachBarBGView;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSMutableArray* VRSDocFilesPredicateArray;
@end
