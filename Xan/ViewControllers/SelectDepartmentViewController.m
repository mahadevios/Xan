//
//  SelectDepartmentViewController.m
//  Cube
//
//  Created by mac on 27/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "SelectDepartmentViewController.h"
#import "MainTabBarViewController.h"
#import "LoginViewController.h"
#import "DepartMent.h"
#import "RegistrationViewController.h"
#import "MainTabBarViewController.h"
#import "SharedSession.h"
#import "AppDelegate.h"

@interface SelectDepartmentViewController ()

@end

@implementation SelectDepartmentViewController
@synthesize tableView;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = @"Select Department";
    self.navigationItem.hidesBackButton=YES;
    departmentNameArray = [[Database shareddatabase] getDepartMentObjList];
    [self setSearchController];
    [self prepareForSearchBar];
    
}

-(void)viewDidAppear:(BOOL)animated
{
//    [self setRootView];
}

#pragma mark: Serach Controller Methods and Delegates
-(void)setSearchController
{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    [self.serachBarBGView addSubview:self.searchController.searchBar];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation=NO;
    //    self.navigationController.definesPresentationContext = YES;
}
-(void)prepareForSearchBar
{
    departmentNamesPredicateArray = [[Database shareddatabase] getDepartMentObjList];
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [searchController.searchBar setShowsCancelButton:YES animated:NO];
    
    if ([self.searchController.searchBar.text isEqual:@""])
    {
        
        departmentNameArray = [[NSMutableArray alloc] initWithArray:departmentNamesPredicateArray];
        
        [self.tableView reloadData];
        
    }
    else
    {
        NSArray *predicateResultArray = [[NSMutableArray alloc]init];

        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"departmentName CONTAINS [cd] %@", self.searchController.searchBar.text];
       
        //        NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"uploadStatus CONTAINS [cd] %@", self.searchController.searchBar.text];
        //        NSPredicate *predicate4 = [NSPredicate predicateWithFormat:@"department CONTAINS [cd] %@", self.searchController.searchBar.text];
        
        NSPredicate *mainPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate1]];
        
        predicateResultArray = [departmentNamesPredicateArray filteredArrayUsingPredicate:mainPredicate];
        
        departmentNameArray = [NSMutableArray arrayWithArray:predicateResultArray];

        [self.tableView reloadData];
    }
}




-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    [searchBar resignFirstResponder];
    
}- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return departmentNameArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UILabel* departmentNameLabel=[cell viewWithTag:101];
    DepartMent* deptObj = [departmentNameArray objectAtIndex:indexPath.row];
    departmentNameLabel.text = deptObj.departmentName;
    return cell;
}
- (void)tableView:(UITableView *)tableview didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    UITableViewCell* cell = [tableview cellForRowAtIndexPath:indexPath];
    UILabel* departmentNameLabel = [cell viewWithTag:101];
  
   
    
    DepartMent* deptObj = [[DepartMent alloc] init];
//    deptObj= [[Database shareddatabase] getDepartMentFromDepartmentName:departmentNameLabel.text];
    
    deptObj = [departmentNameArray objectAtIndex:indexPath.row];
//    NSData *dataa = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:deptObj];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SELECTED_DEPARTMENT_NAME];
    [[NSUserDefaults standardUserDefaults] synchronize];


    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLoadedFirstTime"];
    
    [self setRootView];
}

-(void)setRootView
{
    MainTabBarViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBarViewController"];
    
    [[Database shareddatabase] setDepartment];//to insert default department for imported files
    
    [self dismissViewControllerAnimated:true completion:nil];
    
    [[self presentingViewController] dismissViewControllerAnimated:true completion:nil];
    
    [[[UIApplication sharedApplication] keyWindow] setRootViewController:vc];

}
- (void) checkAndDismissViewController
{
    [self.view endEditing:YES];
    id viewController = [self topViewController];
    if([viewController isKindOfClass:[LoginViewController class]])
    {
        //do something
        [viewController dismissViewControllerAnimated:NO completion:nil];
    }
}

- (UIViewController *)topViewController
{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
