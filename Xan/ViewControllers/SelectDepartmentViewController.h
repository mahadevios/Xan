//
//  SelectDepartmentViewController.h
//  Cube
//
//  Created by mac on 27/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Database.h"
#import "Constants.h"
#import "APIManager.h"

@interface SelectDepartmentViewController : UIViewController<UISearchBarDelegate, UISearchResultsUpdating>
{
    NSMutableArray* departmentNameArray;
    NSMutableArray* departmentNamesPredicateArray;

//    UIAlertController *alertController;
//    UIAlertAction *actionDelete;
//    UIAlertAction *actionCancel;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *serachBarBGView;
@property (strong, nonatomic) UISearchController *searchController;

@end
