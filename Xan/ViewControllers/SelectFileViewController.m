//
//  SelectFileViewController.m
//  Cube
//
//  Created by mac on 28/11/17.
//  Copyright © 2017 Xanadutec. All rights reserved.
//

#import "SelectFileViewController.h"
#import "TableViewButton.h"
#import "Database.h"
#import "Constants.h"
#import "DocFileDetails.h"
#import "AppPreferences.h"
//#import "UIColor+ApplicationColors.h"


@interface SelectFileViewController ()

@end

@implementation SelectFileViewController

@synthesize VRSDocFilesArray,alertController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //APIManager* app = [APIManager sharedManager];
    
    VRSDocFilesArray = [NSMutableArray new];
    
    self.VRSDocFilesPredicateArray = [NSMutableArray new];
    
    VRSDocFilesArray = [[Database shareddatabase] getVRSDocFiles];

    self.VRSDocFilesPredicateArray = [[Database shareddatabase] getVRSDocFiles];

    self.navigationItem.title = @"VRS Text Files";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
    
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];

    [self.tabBarController.tabBar setHidden:YES];
    
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        self.splitViewController.delegate = self;
        
        [self beginAppearanceTransition:true animated:true];
        
        [self.splitViewController setPreferredDisplayMode:UISplitViewControllerDisplayModeAllVisible];
    }
    
    self.definesPresentationContext = true;
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self setSearchController];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
  
//    [UINavigationBar appearance].opaque = YES;

    VRSDocFilesArray = [[Database shareddatabase] getVRSDocFiles];
    
    self.VRSDocFilesPredicateArray = [[Database shareddatabase] getVRSDocFiles];

    self.searchController.searchBar.text = @"";
    
    [self.searchController.searchBar resignFirstResponder];
    
    [self.searchController.searchBar setShowsCancelButton:NO animated:NO];
    
    [self.tableView reloadData];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}
-(void)viewDidAppear:(BOOL)animated
{
    if (self.splitViewController.isCollapsed == false) // if not collapsed that is reguler width hnce ipad
    {
        [self showDetailVCForDocxFile];
        
    }
//    [UINavigationBar appearance].backgroundColor = [UIColor blueColor];
//    //    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
//    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
//    
//    [UINavigationBar appearance].translucent = NO;
    
}
-(void)showDetailVCForDocxFile
{
    self.detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EmptyViewController"];
    
    self.detailVC.usedByVCName = @"VRSVC";
    
    self.detailVC.dataToShowCount = VRSDocFilesArray.count;
    
    if (VRSDocFilesArray.count > 0)
    {
        DocFileDetails* docFileDetails = [VRSDocFilesArray objectAtIndex:0];
        
        NSString* destpath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@",DOC_VRS_FILES_FOLDER_NAME,docFileDetails.docFileName]];
        
        NSString* newDestPath = [destpath stringByAppendingFormat:@".txt"];
        
        self.detailVC.docxFileToShowPath = newDestPath;
    }
   
    
    [self.splitViewController showDetailViewController:self.detailVC sender:self];

    //                detailVC.listSelected = 0;
   
    
}
-(void)popViewController:(id)sender
{
    if (self.splitViewController.isCollapsed == true || self.splitViewController == nil)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:false completion:nil];
    }
    [self.tabBarController.tabBar setHidden:NO];
    
}

#pragma mark: Serach Controller Methods and Delegates
-(void)setSearchController
{
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    [self.serachBarBGView addSubview:self.searchController.searchBar];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    //    self.tableView.tableHeaderView = self.searchController.searchBar;
//    self.navigationController.definesPresentationContext = YES;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation=NO;
    //    self.navigationController.definesPresentationContext = YES;
}


//-(void)prepareForSearchBar
//{
//    self.inCompleteListPredicateArray = [db getListOfFileTransfersOfStatus:@"RecordingPause"];
//}


- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [searchController.searchBar setShowsCancelButton:YES animated:NO];
    
    if ([self.searchController.searchBar.text isEqual:@""])
    {
        
        VRSDocFilesArray = [[NSMutableArray alloc] initWithArray:self.VRSDocFilesPredicateArray];
        
        [self.tableView reloadData];
        
    }
    else
    {
        
        NSArray *predicateResultArray = [[NSMutableArray alloc]init];
        
        self.VRSDocFilesPredicateArray =  [[Database shareddatabase] getVRSDocFiles];
        
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"docFileName CONTAINS [cd] %@", self.searchController.searchBar.text];
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"createdDate CONTAINS [cd] %@", self.searchController.searchBar.text];
                NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"departmentName CONTAINS [cd] %@", self.searchController.searchBar.text];
        //        NSPredicate *predicate4 = [NSPredicate predicateWithFormat:@"department CONTAINS [cd] %@", self.searchController.searchBar.text];
        
        NSPredicate *mainPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate1, predicate2, predicate3]];
        
        predicateResultArray = [self.VRSDocFilesPredicateArray filteredArrayUsingPredicate:mainPredicate];
        
        VRSDocFilesArray = [NSMutableArray arrayWithArray:predicateResultArray];
        
        [self.tableView reloadData];
    }
    
}
-(void)updateSerachBarManually
{
    self.searchController.active = YES;
    self.searchController.searchBar.text = self.searchController.searchBar.text;
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    
    [searchBar resignFirstResponder];
    
    [self prepareDataSourceForTableView];
    
    [self.tableView reloadData];
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    [searchBar resignFirstResponder];
    
}

-(void)prepareDataSourceForTableView
{
    VRSDocFilesArray =  [[Database shareddatabase] getVRSDocFiles];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return VRSDocFilesArray.count;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
    DepartMent *deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    DocFileDetails* docFileDetails = [VRSDocFilesArray objectAtIndex:indexPath.row];
    
    NSString* dateAndTimeString = docFileDetails.createdDate;
    
    NSArray* dateAndTimeArray=[dateAndTimeString componentsSeparatedByString:@" "];
    
    UILabel* fileNameLabel = [cell viewWithTag:101];

    UILabel* timeLabel = [cell viewWithTag:102];

    UILabel* departmentLabel=[cell viewWithTag:103];

    UILabel* dateLabel=[cell viewWithTag:104];

    TableViewButton* deleteButton = [cell viewWithTag:105];

    deleteButton.indexPathRow = indexPath.row;

    [deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    if (dateAndTimeArray.count>2)
    {
        
        timeLabel.text=[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:1]];
        
//        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
//        NSDate *date = [dateFormatter dateFromString:[dateAndTimeArray objectAtIndex:0]];
        
        // Convert date object into desired format
//        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
//        NSString *newDateString = [dateFormatter stringFromDate:date];
        
        dateLabel.text=[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:0]];
        
        timeLabel.text=[NSString stringWithFormat:@"%@ %@",[dateAndTimeArray objectAtIndex:1],[dateAndTimeArray objectAtIndex:2]];
        
        
    }
//    if (dateAndTimeArray.count>1)
//        timeLabel.text=[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:1]];
    
//    dateLabel.text=[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:0]];
    if (docFileDetails.departmentName == nil || [docFileDetails.departmentName  isEqual: @""])
    {
        docFileDetails.departmentName = deptObj.departmentName;
    }
    else
    departmentLabel.text = docFileDetails.departmentName;
    
    fileNameLabel.text = docFileDetails.docFileName;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[AppPreferences sharedAppPreferences] showHudWithTitle:@"Opening File.." detailText:@"Please wait"];
        [self setTimer];


    });

    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UILabel* fileNameLabel = [cell viewWithTag:101];
    
//    NSString* destpath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@",DOC_VRS_FILES_FOLDER_NAME,fileNameLabel.text]];
    
    NSString* destpath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@",AUDIO_FILES_FOLDER_NAME,@"TPr12d120200318-12"]];
    
//    NSString* newDestPath = [destpath stringByAppendingFormat:@".txt"];
    
    NSString* newDestPath = [destpath stringByAppendingFormat:@".wav"];

    if (self.splitViewController.isCollapsed == true || self.splitViewController == nil)
    {
        UIDocumentInteractionController* interactionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:newDestPath]];
        
//        interactionController set
        interactionController.delegate = self;
        
        
//        [interactionController presentPreviewAnimated:true];

        [interactionController presentOpenInMenuFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
    }
    else
    {

        
        [self.detailVC showDocxFile:newDestPath];
    }
    
    
    //[interactionController presentOpenInMenuFromRect:self.view.frame inView:self.view animated:true];
    //[self dismissViewControllerAnimated:true completion:nil];

}

-(void)deleteButtonClicked:(TableViewButton*)sender
{
    alertController = [UIAlertController alertControllerWithTitle:@"Delete Text File?"
                                                          message:@"Are you sure you want to delete this text file?"
                                                   preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* actionCreate = [UIAlertAction actionWithTitle:@"Delete"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * action)
                                   {
                                       dispatch_async(dispatch_get_main_queue(), ^
                                                      {
                                                          //NSLog(@"Reachable");
                                                          //[[AppPreferences sharedAppPreferences] showHudWithTitle:@"Creating Doc File" detailText:@"Please wait.."];
                                                          DocFileDetails* docFileDetails = [VRSDocFilesArray objectAtIndex:sender.indexPathRow];
                                                          
                                                          [[Database shareddatabase] deleteDocFileRecordFromDatabase:docFileDetails.docFileName];
                                                          
                                                          [self deleteDocFile:docFileDetails.docFileName];
                                                          
                                                          NSIndexPath* indexPath = [NSIndexPath indexPathForRow:sender.indexPathRow inSection:0];
                                                          
                                                          [VRSDocFilesArray removeObjectAtIndex:sender.indexPathRow];
                                                          
                                                          [self.tableView deleteRowsAtIndexPaths:[[NSArray alloc] initWithObjects:indexPath, nil]  withRowAnimation:UITableViewRowAnimationTop];
                                                          
                                                          self.VRSDocFilesPredicateArray = [[Database shareddatabase] getVRSDocFiles];

                                                          [self.tableView reloadData];
//                                                              [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Doc File Created" withMessage:@"Doc file crated successfully, check doc files in alert tab" withCancelText:@"Cancel" withOkText:@"Ok" withAlertTag:1000];
                                                          
                                                          //[[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
                                                          
                                                      });
                                   }]; //You can use a block here to handle a press on this button
    
    UIAlertAction* actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action)
                                   {
                                       
                                   }];
    
    [alertController addAction:actionCreate];
    
    [alertController addAction:actionCancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)deleteDocFile:(NSString*)docFileName
{
    NSString* docFilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@",DOC_VRS_FILES_FOLDER_NAME,docFileName]];
    
    docFilePath = [docFilePath stringByAppendingFormat:@".txt"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:docFilePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:docFilePath error:nil];
    }
}

-(CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
    return self.view.frame;

}
-(UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    return self.navigationController.view;

}

-(UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
//    [[UINavigationBar appearance] setTintColor:self.navigationController.navigationBar.tintColor];
//    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
//
//    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
//
//    [[UINavigationBar appearance] setBackgroundImage:[self.class imageFromColor:self.navigationController.navigationBar.barTintColor] forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setTranslucent:false];
    return self.navigationController;
}

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
-(void)documentInteractionControllerWillBeginPreview:(UIDocumentInteractionController *)controller
{
    //dispatch_async(dispatch_get_main_queue(), ^{
        
        [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];

    //});
}



//- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
//    if ([self isWhatsApplication:application]) {
//
//        controller.UTI = @"net.whatsapp.image";
//    }
//}
//
//- (BOOL)isWhatsApplication:(NSString *)application {
//    if ([application rangeOfString:@"whats"].location == NSNotFound) { // unfortunately, no other way...
//        return NO;
//    } else {
//        return YES;
//    }
//}

-(void)setTimer
{
    newRequestTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime:) userInfo:nil repeats:NO];
    
}

-(void)updateTime:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
    
    [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
    
    });
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}
@end
