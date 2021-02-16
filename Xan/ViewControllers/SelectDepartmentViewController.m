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

//my comment
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
//    self.navigationItem.title = @"Clinical Speciality";
    self.navigationItem.title = @"Department";
    self.navigationItem.hidesBackButton=YES;
//    [self.serachBarBGView setBackgroundColor:[UIColor whiteColor]];
    departmentObjectArray = [[Database shareddatabase] getDepartMentObjList];
    if (departmentObjectArray.count == 0)
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No Department Added" withMessage:@"Please contact ACE Administrator" withCancelText:@"Cancel" withOkText:nil withAlertTag:1000];
    }
    [self findDuplicateDepartmentNames];
    [self setSearchController];
    [self prepareForSearchBar];
//    self.definesPresentationContext = true;
//    
//    self.extendedLayoutIncludesOpaqueBars = YES;
    
}

-(void)findDuplicateDepartmentNames
{
    departmentNamesArray = [[Database shareddatabase] getDepartMentNames];
       
       NSMutableArray *unique = [NSMutableArray array];
       duplicateDepartmentNamesArray = [NSMutableArray array];

       for (NSString* deptName in departmentNamesArray) {
           if (![unique containsObject:deptName]) {
               [unique addObject:deptName];
           }
           else
           {
               [duplicateDepartmentNamesArray addObject:deptName];
           }
       }
      
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
    
       if (UIScreen.mainScreen.traitCollection.userInterfaceStyle==UIUserInterfaceStyleDark){
           self.searchController.searchBar.barTintColor = [UIColor whiteColor];
           self.searchController.searchBar.searchTextField.textColor = [UIColor blackColor];
           self.searchController.searchBar.searchTextField.leftView.tintColor = [UIColor blackColor];

       }
    
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
        
        departmentObjectArray = [[NSMutableArray alloc] initWithArray:departmentNamesPredicateArray];
        
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
        
        departmentObjectArray = [NSMutableArray arrayWithArray:predicateResultArray];

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
    return departmentObjectArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    
    UILabel* departmentNameLabel=[cell viewWithTag:101];

    
   if (departmentNameLabel.text != nil)
      {
          departmentNameLabel.text = @"";
       }
      
       
    
    DepartMent* dept = [departmentObjectArray objectAtIndex:indexPath.row];
    
    if ([[AppPreferences sharedAppPreferences].inActiveDepartmentIdsArray containsObject:dept.Id]) {
          
        if ([duplicateDepartmentNamesArray containsObject:dept.departmentName]) {
            
            departmentNameLabel.text = [NSString stringWithFormat:@"%@ (%@ INACTIVE)",dept.departmentName,dept.Id];
        }
        else
        {
            departmentNameLabel.text = [NSString stringWithFormat:@"%@ (INACTIVE)",dept.departmentName];
        }
        

      }
      else
      {
          if ([duplicateDepartmentNamesArray containsObject:dept.departmentName]) {
              
              departmentNameLabel.text = [NSString stringWithFormat:@"%@ (%@)",dept.departmentName,dept.Id];
          }
          else
          departmentNameLabel.text = dept.departmentName;
      }
   
    return cell;
}
- (void)tableView:(UITableView *)tableview didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//if (UIScreen.mainScreen.traitCollection.userInterfaceStyle==UIUserInterfaceStyleDark){
//
//   [[tableView cellForRowAtIndexPath:indexPath] setBackgroundColor:[UIColor redColor]];
//}
    DepartMent* deptObj = [[DepartMent alloc] init];
    
    deptObj = [departmentObjectArray objectAtIndex:indexPath.row];

    if ([[AppPreferences sharedAppPreferences].inActiveDepartmentIdsArray containsObject:deptObj.Id])
    {
        [tableView reloadData];
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:DEACTIVATE_DEPARTMENT_MESSAGE withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
        
        return;
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:deptObj];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SELECTED_DEPARTMENT_NAME];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLoadedFirstTime"];
    
    [self setRootView];
}

//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (UIScreen.mainScreen.traitCollection.userInterfaceStyle==UIUserInterfaceStyleDark){
//    NSIndexPath *currentSelectedIndexPath = [tableView indexPathForSelectedRow];
//    if (currentSelectedIndexPath != nil)
//    {
//        [[tableView cellForRowAtIndexPath:currentSelectedIndexPath] setBackgroundColor:[UIColor whiteColor]];
//    }
//    }
//    return indexPath;
//}
//
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (UIScreen.mainScreen.traitCollection.userInterfaceStyle==UIUserInterfaceStyleDark){
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//
//    if (cell.isSelected == YES)
//    {
//        [cell setBackgroundColor: [UIColor redColor]];
//    }
//    else
//    {
//        [cell setBackgroundColor:[UIColor whiteColor]];
//    }
//    }
//}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = false;
}
-(void)setRootView
{
    MainTabBarViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBarViewController"];
    
    [[Database shareddatabase] setDepartment];//to insert default department for imported files
    
//    self.searchController.active = NO;
//
//    self.searchController.active = NO;
//    [self searchBarSearchButtonClicked:self.searchController.searchBar];

//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

   
//    [self.searchController dismissViewControllerAnimated:true completion:nil];
//    [self.searchController removeFromParentViewController];
//    [self.serachBarBGView removeFromSuperview];
    
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    self.definesPresentationContext = true;
    
        
    // [appDelegate.window makeKeyWindow];
    //    UIWindow* winow = [[UIApplication sharedApplication] keyWindow];
    
    
//    self.searchController.active = NO; // Add this !
    
   
    
    

//    [[self presentingViewController] dismissViewControllerAnimated:true completion:nil];

   
//    [self.searchController.searchBar resignFirstResponder];

    
    
//    [self dismissViewControllerAnimated:true completion:nil];
//
//      [[[UIApplication sharedApplication] keyWindow] setRootViewController:vc];
//    id vc1 = [self presentingViewController];
    
    [[self presentingViewController] dismissViewControllerAnimated:true completion:nil];

    [self checkAndDismissViewController];
    
    
    [[[UIApplication sharedApplication] keyWindow] setRootViewController:vc];
    
    

}
- (void) checkAndDismissViewController
{
    [self.view endEditing:YES];
    id viewController = [self topViewController];
//    if([viewController isKindOfClass:[LoginViewController class]])
//    {
//        //do something
        [viewController dismissViewControllerAnimated:NO completion:nil];
//    }
//    NSLog(@"");
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
