//
//  TransferListViewController.m
//  Cube
//
//  Created by mac on 28/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//
//self.checkedIndexPath contain file names to be upload,arrayOfMarked contain indexpathof selected cells

//check in cell for row at index path where we adding the indexpath to array
#import "TransferListViewController.h"
#import "AudioDetailsViewController.h"
#import "Database.h"
#import "APIManager.h"
#import "AppPreferences.h"
#import "Constants.h"
#import "UIColor+ApplicationColors.h"

@interface TransferListViewController ()

@end

@implementation TransferListViewController
@synthesize currentViewName, checkedIndexPath,longPressAdded;

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [self addGestureRecogniser];
    
    [self setSearchController];
//    [self beginAppearanceTransition:true animated:true];

    
}


-(void)viewWillAppear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateFileUploadResponse:) name:NOTIFICATION_FILE_UPLOAD_API
                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(fileUploadClicked:) name:NOTIFICATION_FILE_UPLOAD_CLICKED
//                                               object:nil];
    
    [self setUpNavigationView];
    
    [self setAudioDetailOrEmptyViewController:0];
    
    [self setFirstRowSelected];

    [self prepareForSearchBar];
    
    NSLog(@"1st parent = %@", self.parentViewController);
    
    NSLog(@"2nd parent = %@", self.parentViewController.parentViewController);

    NSLog(@"2nd parent = %@", self.parentViewController.parentViewController.parentViewController);

    self.parentViewController.parentViewController;
}

-(void)addGestureRecogniser
{
    if ([self.currentViewName isEqualToString:@"Awaiting Transfer"])
    {
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 1.0; //seconds
        
        lpgr.delegate = self;
        
        [self.tableView addGestureRecognizer:lpgr];
        
        self.checkedIndexPath = [[NSMutableArray alloc] init];
        
    }
    
    arrayOfMarked = [[NSMutableArray alloc]init];
    
    progressIndexPathArray = [[NSMutableArray alloc]init];
    
    indexPathFileNameDict = [NSMutableDictionary new];
    
    self.splitViewController.delegate = self;
    
    [self beginAppearanceTransition:true animated:true];
    
    [self.splitViewController setPreferredDisplayMode:UISplitViewControllerDisplayModeAllVisible];
}

-(void)setUpNavigationView
{
    self.navigationItem.title=self.currentViewName;
    
    if ([self.currentViewName isEqualToString:@"Transferred Today"])
    {
        self.navigationItem.title=@"Transferred Today";
    }
    
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
    
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = nil;
    
    APIManager* app=[APIManager sharedManager];
    
    app.awaitingFileTransferNamesArray = [[NSMutableArray alloc]init];
    
    app.todaysFileTransferNamesArray = [[NSMutableArray alloc]init];
    
    app.failedTransferNamesArray = [[NSMutableArray alloc]init];
    
    [self prepareDataSourceForTableView];
    
    [self.tableView reloadData];
    
    [self.tabBarController.tabBar setHidden:YES];
    
    
    if ([self.currentViewName isEqualToString:@"Awaiting Transfer"])
    {
        [self setTimer];
    }
    
}

-(void)setSearchController
{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    [self.serachBarBGView addSubview:self.searchController.searchBar];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
//    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.navigationController.definesPresentationContext = YES;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation=NO;
    self.navigationController.definesPresentationContext = YES;
}

-(void)prepareForSearchBar
{
    APIManager* app = [APIManager sharedManager];
    Database* db = [Database shareddatabase];
    if ([self.currentViewName isEqualToString:@"Transferred Today"])
    {
        app.todaysFileTransferNamesArray = [db getListOfFileTransfersOfStatus:@"Transferred"];
        self.genericFilesArray = [[NSMutableArray alloc] initWithArray:app.todaysFileTransferNamesArray];
        self.genericFilesPredicateArray = [[NSMutableArray alloc] initWithArray:app.todaysFileTransferNamesArray];
    }
    else
    if ([self.currentViewName isEqualToString:@"Awaiting Transfer"])
    {
        app.awaitingFileTransferNamesArray = [db getListOfFileTransfersOfStatus:@"RecordingComplete"];
        self.genericFilesArray = [[NSMutableArray alloc] initWithArray:app.awaitingFileTransferNamesArray];
        self.genericFilesPredicateArray = [[NSMutableArray alloc] initWithArray:app.awaitingFileTransferNamesArray];
    }
    else
    {
        app.failedTransferNamesArray = [db getListOfFileTransfersOfStatus:@"TransferFailed"];
        self.genericFilesArray = [[NSMutableArray alloc] initWithArray:app.failedTransferNamesArray];
        self.genericFilesPredicateArray = [[NSMutableArray alloc] initWithArray:app.failedTransferNamesArray];
    }
    
    
   
    
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    if ([self.searchController.searchBar.text isEqual:@""])
    {
        self.genericFilesArray = [[NSMutableArray alloc] initWithArray:self.genericFilesPredicateArray];

        [self.tableView reloadData];
      
    }
    else
    {
        self.genericFilesArray = [[NSMutableArray alloc]init];
        NSArray *predicateResultArray =[[NSMutableArray alloc]init];
        
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"fileName CONTAINS [cd] %@", self.searchController.searchBar.text];
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"recordingDate CONTAINS [cd] %@", self.searchController.searchBar.text];
        NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"uploadStatus CONTAINS [cd] %@", self.searchController.searchBar.text];
        NSPredicate *predicate4 = [NSPredicate predicateWithFormat:@"department CONTAINS [cd] %@", self.searchController.searchBar.text];

        NSPredicate *mainPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate1, predicate2, predicate3, predicate4]];
        
        predicateResultArray = [self.genericFilesPredicateArray filteredArrayUsingPredicate:mainPredicate];
        
        self.genericFilesArray = [NSMutableArray arrayWithArray:predicateResultArray];
        
        [self.tableView reloadData];
    }
}

-(void)setTimer
{

    progressTimer =  [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(updateProgresCount) userInfo:nil repeats:YES];

}


//-(void)setTimer1
//{
//    
//    progressTimer =  [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(updateProgresCount) userInfo:nil repeats:YES];
//    
//}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.checkedIndexPath removeAllObjects];
    
    [progressIndexPathArray removeAllObjects];

    [arrayOfMarked removeAllObjects];
    
    isMultipleFilesActivated=NO;
    self.tableView.allowsMultipleSelection = NO; // for ipad
    toolBarAdded=NO;
    
    [progressTimer invalidate];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.searchController removeFromParentViewController];
    
}

-(void)setAudioDetailOrEmptyViewController:(int)selectedIndex
{
    APIManager* app=[APIManager sharedManager];
    
    
    
    if (self.splitViewController != nil && self.splitViewController.isCollapsed == false) // if not collapsed that is reguler width hnce ipad
    {
        
        
        if ([self.currentViewName isEqualToString:@"Awaiting Transfer"])
        {
            
            if(self.genericFilesArray.count == 0) // if transferred count 0 then show empty VC  else show audio details
            {
                [self addEmptyVCToSplitVC];
            }
            else
            {
                if (isMultipleFilesActivated)
                {
                    [self addEmptyVCToSplitVC];
                }
                else
                {
                    BOOL isWithoutUploadingFileAvailable = false;
                    
                    for (int i = 0; i < self.genericFilesArray.count; i++)
                    {
                        AudioDetails *audioDetails = [self.genericFilesArray objectAtIndex:i];
                        
//                        NSDictionary* dict  = [AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict;
                        if (!(audioDetails.fileName || [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray containsObject:audioDetails.fileName]))
                        {
                            isWithoutUploadingFileAvailable = true;
                            
//                            selectedIndex = i;
                            
                            break;
                        }
//                        if ([[AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict valueForKey:[awaitingFileTransferDict valueForKey:@"RecordItemName"]]== NULL)
//                        {
//
//                            isWithoutUploadingFileAvailable = true;
//
//                            break;
//                        }
//                        if ([AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count < 1 && [AppPreferences sharedAppPreferences].filesInUploadingQueueArray.count < 1)//nothing in upload queue
//                        {
//                            
//                            isWithoutUploadingFileAvailable = true;
//                            
//                            break;
//                        }
                        
                    }
                    
                    if (isWithoutUploadingFileAvailable)
                    {
                         [self addAudioDetailsVCToSplitVC:selectedIndex];
                    }
                    else
                    {
                        [self addEmptyVCToSplitVC];
                    }
                   
                }
                
            }
        }
        else
            if ([self.currentViewName isEqualToString:@"Transferred Today"])
            {
                
                if(app.todaysFileTransferNamesArray.count == 0) // if transferred count 0 then show empty VC  else show audio details
                {
                    [self addEmptyVCToSplitVC];
                }
                else
                {
                    [self addAudioDetailsVCToSplitVC:selectedIndex];
                }
            }
        
    }
    
    
}

-(void)addEmptyVCToSplitVC
{
    UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EmptyViewController"];
    
    NSMutableArray* subVC = [[NSMutableArray alloc] initWithArray:[self.splitViewController viewControllers]];
    
    if (subVC.count > 1)
    {
        [subVC removeObjectAtIndex:1];
        
        [subVC addObject:vc];
        
    }
    else
    {
        [subVC addObject:vc];
    }
    
    [self.splitViewController setViewControllers:subVC];
    
}

-(void)addAudioDetailsVCToSplitVC:(int)selectedIndex
{
//    if (detailVC == nil)
//    {
        detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioDetailsViewController"];

//    }
    
    detailVC.delegate = self;
    
    detailVC.selectedView = self.currentViewName;
    //                detailVC.listSelected = 0;
    
    detailVC.selectedRow = selectedIndex;
    
    [self.splitViewController showDetailViewController:detailVC sender:self];
    
}


-(void)validateFileUploadResponse:(NSNotification*)obj
{
  
    NSString* fileName = obj.object;
    
    [progressTimer invalidate];
    
    [progressIndexPathArray removeAllObjects];
    
    [self.checkedIndexPath removeAllObjects];
    
    [arrayOfMarked removeAllObjects];
    
    isMultipleFilesActivated=NO;
    self.tableView.allowsMultipleSelection = NO; // for ipad
    [self hideAndShowUploadButton:NO];
    
    /////// remove the uploaded file obj from predicate array so when serach result clears then predicatearray copy will get replicate to original array
    BOOL isUploadedFileObjectFound = false;
    
    for (AudioDetails* audioDetails in self.genericFilesPredicateArray)
    {
        if ([audioDetails.fileName isEqualToString:fileName])
        {
            [self.genericFilesPredicateArray removeObject:audioDetails];
            
            isUploadedFileObjectFound = true;
        }
        
        if (isUploadedFileObjectFound)
        {
            break;
        }
    }
    
    [self prepareDataSourceForTableView];
    
    [self.tableView reloadData];//to update table agter getting file trnasfer response
    
    [self updateSerachBarManually];
    
    
    if ([self.currentViewName isEqualToString:@"Awaiting Transfer"])
    {
        //[self performSelector:@selector(setTimer) withObject:nil afterDelay:2.0];
        [self setTimer];
    }
   
    //[self.tableView endUpdates];
}

-(void)updateSerachBarManually
{
    self.searchController.active = YES;
    self.searchController.searchBar.text = self.searchController.searchBar.text;
    
}
-(void)updateProgresCount
{

    if (progressIndexPathArray.count>0)
    {
        if ([self.searchController.searchBar.text isEqualToString:@""] || self.searchController.searchBar.text == nil)
        {
            self.genericFilesArray = [[Database shareddatabase] getListOfFileTransfersOfStatus:@"RecordingComplete"] ;
            
            [self.tableView reloadRowsAtIndexPaths:progressIndexPathArray withRowAnimation:UITableViewRowAnimationNone];
       
        }
        

    }
    
    
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (self.navigationItem.title==self.currentViewName)//if navigation title=@"somevalue" then only handle longpress
    {
   
        isMultipleFilesActivated = YES;
        
        [self setAudioDetailOrEmptyViewController:0];
//        self.tableView.allowsMultipleSelection = YES; //for ipad

//        APIManager* app=[APIManager sharedManager];
        
        CGPoint p = [gestureRecognizer locationInView:self.tableView];
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
        
        UITableViewCell* cell=[self.tableView cellForRowAtIndexPath:indexPath];
        
        UILabel* deleteStatusLabel=[cell viewWithTag:105];
    
        
        if (cell.accessoryType == UITableViewCellAccessoryNone && (![deleteStatusLabel.text containsString:@"Uploading"]))
        {
            AudioDetails* audioDetails = [self.genericFilesArray objectAtIndex:indexPath.row];
            
            NSString* fileName = audioDetails.fileName;

            [self.checkedIndexPath addObject:fileName];
            
            [arrayOfMarked addObject:indexPath];
            
            [self hideAndShowUploadButton:YES];
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
//            longPressAdded=YES;
        }
        
    }
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

#pragma mark: tableView delegates adn datasource

-(void)prepareDataSourceForTableView
{
    Database* db=[Database shareddatabase];
    
    if ([self.currentViewName isEqualToString:@"Transferred Today"])
    {
        self.genericFilesArray = [db getListOfFileTransfersOfStatus:@"Transferred"];
        
    }
    else
    if ([self.currentViewName isEqualToString:@"Awaiting Transfer"])
    {
        self.genericFilesArray = [db getListOfFileTransfersOfStatus:@"RecordingComplete"];
        
    }
    else
    {
        self.genericFilesArray = [db getListOfFileTransfersOfStatus:@"TransferFailed"];
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.genericFilesArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    APIManager* app=[APIManager sharedManager];
    AudioDetails* audioDetails;
   
    audioDetails = [self.genericFilesArray objectAtIndex:indexPath.row];
   

    UITableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
   
    UILabel* departmentNameLabel=[cell viewWithTag:101];
    departmentNameLabel.text = audioDetails.fileName;
    NSString* dateAndTimeString = audioDetails.recordingDate;
    NSString* transferStatusString = audioDetails.uploadStatus;
    NSString* deleteStatusString = audioDetails.deleteStatus;
    NSArray* dateAndTimeArray=[dateAndTimeString componentsSeparatedByString:@" "];
    
    
    UILabel* recordingDurationLabel=[cell viewWithTag:102];
    
    UILabel* timeLabel=[cell viewWithTag:106];

    if (dateAndTimeArray.count>1)
    timeLabel.text=[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:1]];
    
    UILabel* nameLabel=[cell viewWithTag:103];
    nameLabel.text = audioDetails.department;
    
    UILabel* deleteStatusLabel=[cell viewWithTag:105];

    UILabel* dateLabel=[cell viewWithTag:104];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    
    if (dateAndTimeArray.count>1)
    {
        timeLabel.text=[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:1]];
        
        
        NSDate *date = [dateFormatter dateFromString:[dateAndTimeArray objectAtIndex:0]];
        
        // Convert date object into desired format
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        NSString *newDateString = [dateFormatter stringFromDate:date];
        
        dateLabel.text=[NSString stringWithFormat:@"%@",newDateString];
        
    }
    
   
    int audioHour= [audioDetails.currentDuration intValue]/(60*60);
    int audioHourByMod= [audioDetails.currentDuration intValue]%(60*60);
    
    int audioMinutes = audioHourByMod / 60;
    int audioSeconds = audioHourByMod % 60;
    
    recordingDurationLabel.text=[NSString stringWithFormat:@"%02d:%02d:%02d",audioHour,audioMinutes,audioSeconds];
    
    if ([self.currentViewName isEqualToString:@"Transferred Today"])
    {
        dateAndTimeString = audioDetails.currentDuration;
        dateAndTimeArray=nil;
        dateAndTimeArray=[dateAndTimeString componentsSeparatedByString:@" "];
        
        if (dateAndTimeArray.count>1)
        {
            
                timeLabel.text=[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:1]];
                
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                
                NSDate *date = [dateFormatter dateFromString:[dateAndTimeArray objectAtIndex:0]];
                
                // Convert date object into desired format
                [dateFormatter setDateFormat:@"dd-MM-yyyy"];
                NSString *newDateString = [dateFormatter stringFromDate:date];
                
                dateLabel.text=[NSString stringWithFormat:@"%@",newDateString];

                timeLabel.text=[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:1]];


        }
        

    }
    
    if ([transferStatusString  isEqualToString: @"TransferFailed"])
    {
        //        [deleteStatusLabel setHidden:false];
        deleteStatusLabel.text = @"Transfer Failed";
    }
    else
        {
            deleteStatusLabel.text=@"";
        }
    
    if ([deleteStatusString isEqualToString:@"Delete"])
    {
        deleteStatusLabel.hidden = NO;
        deleteStatusLabel.text=@"Deleted";
    }
    else
        if (![transferStatusString isEqualToString:@"TransferFailed"])
        {
            deleteStatusLabel.text=@"";

        }
    
 
    
    if ([audioDetails.dictationStatus isEqualToString:@"RecordingFileUpload"] && ([audioDetails.uploadStatus isEqualToString:@"NotTransferred"] || [audioDetails.uploadStatus isEqualToString:@"Resend"] || [audioDetails.uploadStatus isEqualToString:@"ResendFailed"]))
    {
        if (![progressIndexPathArray containsObject:indexPath])
        {
            [progressIndexPathArray addObject:indexPath];
           // [progressIndexPathArrayCopy addObject:indexPath];

            [indexPathFileNameDict setObject:indexPath forKey:departmentNameLabel.text];
        }
        //deleteStatusLabel.text=@"Uploading";
        if ([[AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict valueForKey:audioDetails.fileName]== NULL)
        {
            deleteStatusLabel.text= @"Uploading";
        }
        else
        deleteStatusLabel.text = [NSString stringWithFormat:@"Uploading %@",[[AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict valueForKey:audioDetails.fileName]];

    }
    else
    {
        if ([progressIndexPathArray containsObject:indexPath])
        {
            [progressIndexPathArray removeObject:indexPath];
            [indexPathFileNameDict removeObjectForKey:departmentNameLabel.text];
        }
    }
    
    if ([arrayOfMarked containsObject:indexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
 
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSDictionary* awaitingFileTransferDict;
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    APIManager* app=[APIManager sharedManager];

   

    if (isMultipleFilesActivated)
    {

        int uploadFileCount = 0;
        UILabel* deleteStatusLabel=[cell viewWithTag:105];
        AudioDetails *audioDetails= [app.awaitingFileTransferNamesArray objectAtIndex:indexPath.row];
        NSString* fileName = audioDetails.fileName;
        
        for (NSInteger i = 0; i < app.awaitingFileTransferNamesArray.count; ++i)
        {
            NSIndexPath* indexPath= [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell* cell= [self.tableView cellForRowAtIndexPath:indexPath];
            UILabel* deleteStatusLabel=[cell viewWithTag:105];
            if ([deleteStatusLabel.text containsString:@"Uploading"])
            {
                ++uploadFileCount;
            }
        }
        if ((self.genericFilesArray.count - uploadFileCount == 1) || (arrayOfMarked.count == self.genericFilesArray.count-uploadFileCount))
        {
            UIBarButtonItem* vc=self.navigationItem.rightBarButtonItem;
            UIToolbar* view=  vc.customView;
            NSArray* arr= [view items];
            UIBarButtonItem* button= [arr objectAtIndex:4];
            //UIButton* button=  [view viewWithTag:102];
            
            [button setTitle:@"Deselect all"];
        }
//        if (arrayOfMarked.count == app.awaitingFileTransferNamesArray.count-uploadFileCount)
//
//        {
//            UIBarButtonItem* vc=self.navigationItem.rightBarButtonItem;
//            UIToolbar* view=  vc.customView;
//            NSArray* arr= [view items];
//            UIBarButtonItem* button= [arr objectAtIndex:4];
//            //UIButton* button=  [view viewWithTag:102];
//
//            [button setTitle:@"Deselect all"];
//        }

        if (cell.accessoryType == UITableViewCellAccessoryNone && (![deleteStatusLabel.text containsString:@"Uploading"]))
        {
            
            [self.checkedIndexPath addObject:fileName];
            
            [arrayOfMarked addObject:indexPath];
            
            selectedCountLabel.text=[NSString stringWithFormat:@"%ld",arrayOfMarked.count];
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            //
            if (arrayOfMarked.count == self.genericFilesArray.count)
            {
                UIBarButtonItem* vc=self.navigationItem.rightBarButtonItem;
                UIToolbar* view=  vc.customView;
                NSArray* arr= [view items];
                UIBarButtonItem* button= [arr objectAtIndex:4];
                //UIButton* button=  [view viewWithTag:102];
                [button setTitle:@"Deselect all"];
            }
        }
        else if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            [self.checkedIndexPath removeObject:fileName];
            
            [arrayOfMarked removeObject:indexPath];
            
            
            selectedCountLabel.text=[NSString stringWithFormat:@"%lu",(unsigned long)arrayOfMarked.count];

            UIBarButtonItem* vc=self.navigationItem.rightBarButtonItem;
            
            UIToolbar* view=  vc.customView;
            
            NSArray* arr= [view items];
            
            UIBarButtonItem* button= [arr objectAtIndex:4];
            //UIButton* button=  [view viewWithTag:102];
            [button setTitle:@"Select all"];
            
        }
    
        if(arrayOfMarked.count > 0)
        {
            //Show upload files button
            [self hideAndShowUploadButton:YES];
        }
        else
        {
            //Remove upload files button.
            isMultipleFilesActivated = NO;
            
            self.tableView.allowsMultipleSelection = NO;
            
            [self hideAndShowUploadButton:NO];
        }
    }
else//to disaalow single row while that row is uploading
    if ([self.currentViewName isEqualToString:@"Awaiting Transfer"])
    {
        UILabel* deleteStatusLabel=[cell viewWithTag:105];

        if(([deleteStatusLabel.text containsString:@"Uploading"]))
        {
            alertController = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                  message:@"File is in use"
                                                           preferredStyle:UIAlertControllerStyleAlert];
            actionDelete = [UIAlertAction actionWithTitle:@"Ok"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action)
                            {
                                [alertController dismissViewControllerAnimated:YES completion:nil];
                            }]; //You can use a block here to handle a press on this button
            [alertController addAction:actionDelete];
            
            
           
            [self presentViewController:alertController animated:YES completion:nil];

        }
        else
        {
//            cell.selectionStyle = UITableViewCellSelectionStyleDefault;

            if (self.splitViewController.isCollapsed == true || self.splitViewController == nil)
            {
//                if (detailVC == nil)
//                {
                    detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioDetailsViewController"];

//                }
                detailVC.selectedRow=indexPath.row ;
                detailVC.selectedView=self.currentViewName;
                [self presentViewController:detailVC animated:YES completion:nil];
//                self.tableView.allowsMultipleSelection = NO;
            
            }
            else
            {
                [self setAudioDetailOrEmptyViewController:indexPath.row];

            }
           
         }

        
    }
    else
    if ([self.currentViewName isEqualToString:@"Transferred Today"])
    {
        if (self.splitViewController.isCollapsed == true || self.splitViewController == nil)
        {
            AudioDetailsViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioDetailsViewController"];
            vc.selectedRow=indexPath.row ;
            vc.selectedView=self.currentViewName;
            [self.navigationController presentViewController:vc animated:YES completion:nil];
            //                self.tableView.allowsMultipleSelection = NO;
            
        }
        else
        {
            [self setAudioDetailOrEmptyViewController:indexPath.row];
            
        }
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;

        AudioDetailsViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioDetailsViewController"];
        vc.selectedRow=indexPath.row ;
        vc.selectedView=self.currentViewName;
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    }

}

//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
//{
//    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
//
//    if ([self.currentViewName isEqualToString:@"Awaiting Transfer"])
//    {    UILabel* deleteStatusLabel=[cell viewWithTag:105];
//
//        if(([deleteStatusLabel.text containsString:@"Uploading"]))
//        {
//            alertController = [UIAlertController alertControllerWithTitle:@"Alert?"
//                                                                  message:@"File is in use!"
//                                                           preferredStyle:UIAlertControllerStyleAlert];
//            actionDelete = [UIAlertAction actionWithTitle:@"Ok"
//                                                    style:UIAlertActionStyleDefault
//                                                  handler:^(UIAlertAction * action)
//                            {
//                                [alertController dismissViewControllerAnimated:YES completion:nil];
//                            }]; //You can use a block here to handle a press on this button
//            [alertController addAction:actionDelete];
//
//
//
//            [self presentViewController:alertController animated:YES completion:nil];
//
//        }
//        else
//            if (isMultipleFilesActivated)
//            {
//                if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
//                {
//                    cell.accessoryType = UITableViewCellAccessoryNone;
//                    NSDictionary* awaitingFileTransferDict= [[APIManager sharedManager].awaitingFileTransferNamesArray objectAtIndex:indexPath.row];
//                    NSString* fileName=[awaitingFileTransferDict valueForKey:@"RecordItemName"];
//                    [arrayOfMarked removeObject:indexPath];
//                    selectedCountLabel.text=[NSString stringWithFormat:@"%ld",arrayOfMarked.count];
//
//                    [self.checkedIndexPath removeObject:fileName];
//
//                    //
//                    UIBarButtonItem* vc=self.navigationItem.rightBarButtonItem;
//                    UIToolbar* view=  vc.customView;
//                    NSArray* arr= [view items];
//                    UIBarButtonItem* button= [arr objectAtIndex:4];
//                    //UIButton* button=  [view viewWithTag:102];
//                    [button setTitle:@"Select all"];
//
//                }
//
//                if(arrayOfMarked.count > 0)
//                {
//                    //Show upload files button
//                    [self hideAndShowUploadButton:YES];
//                }
//                else
//                {
//                    //Remove upload files button.
//                    isMultipleFilesActivated = NO;
//                    self.tableView.allowsMultipleSelection = NO;
//
//                    [self hideAndShowUploadButton:NO];
//                }
//
//
//            }
//
//
//
//    }
//
//}

-(void)setFirstRowSelected
{
    if (self.splitViewController != nil) // for ipad reguler width reguler height
    {
        
        if ([self.currentViewName isEqualToString:@"Awaiting Transfer"] && self.genericFilesArray.count >0)
        {
            
            for (int i = 0; i < self.genericFilesArray.count; i++)
            {
                AudioDetails* audioDetails = [self.genericFilesArray objectAtIndex:i];
                
                //                 if ([[AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict valueForKey:[awaitingFileTransferDict valueForKey:@"RecordItemName"]]== NULL)
                //                if ([AppPreferences sharedAppPreferences].filesInUploadingQueueArray.count < 1 && [AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count < 1)
                if (!([[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray containsObject:audioDetails.fileName] || [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray containsObject:audioDetails.fileName]))
                    
                {
                    NSIndexPath *firstRowPath = [NSIndexPath indexPathForRow:i inSection:0];
                    
                    [self.tableView selectRowAtIndexPath:firstRowPath animated:NO scrollPosition: UITableViewScrollPositionNone];
                    
                    [self tableView:self.tableView didSelectRowAtIndexPath:firstRowPath];
                    
                    break;
                }
                
            }
            
            
            
        }
        else
            if ([self.currentViewName isEqualToString:@"Transferred Today"] && self.genericFilesArray.count >0)
            {
                NSIndexPath *firstRowPath = [NSIndexPath indexPathForRow:0 inSection:0];
                
                [self.tableView selectRowAtIndexPath:firstRowPath animated:NO scrollPosition: UITableViewScrollPositionNone];
                
                [self tableView:self.tableView didSelectRowAtIndexPath:firstRowPath];
            }
    }
    
}

- (void) hideAndShowUploadButton:(BOOL)isShown
{
    if (isShown)
    {
        self.navigationItem.title=@"";
        if (!toolBarAdded)
        {
            [self addToolbar];

        }

    }
    else
    {
        toolBarAdded=NO;
        self.navigationItem.title=self.currentViewName;

        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];

        
    }
}

//- (void) hideAndShowLeftBarButton:(BOOL)isShown
//{
//    if (isShown)
//    {
//        self.navigationItem.title=@"";
////        if (!toolBarAdded)
////        {
//            [self addLeftBarButton];
//            
//       // }
//        
//    }
//    else
//    {
//        toolBarAdded=NO;
//        self.navigationItem.title=self.currentViewName;
//        
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];;
//        
//    }
//}


-(void)addToolbar
{
    toolBarAdded=YES;
    
    // right bar button tool bar
    UIToolbar *tools = [[UIToolbar alloc]
                        initWithFrame:CGRectMake(-50.0f, 10.0f, 187.0f, 44.01f)]; // 44.01 shifts it up 1px for some reason
    tools.barTintColor = [UIColor appNavyBlueColor];
    tools.translucent = NO;
    tools.tag=101;
    tools.clipsToBounds = YES;

    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:5];
    
    UIBarButtonItem *bi = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteMutipleFiles)];
    [bi setTintColor:[UIColor whiteColor]];
    [buttons addObject:bi];
    
     //Create a spacer.
    bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    bi.width = 12.0f;
    [bi setTintColor:[UIColor whiteColor]];
    [buttons addObject:bi];
    
    bi = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Upload"] style:UIBarButtonItemStylePlain target:self action:@selector(uploadMultipleFilesToserver)];
    [bi setTintColor:[UIColor whiteColor]];
    [buttons addObject:bi];

    bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    bi.width = 9.0f;
    [bi setTintColor:[UIColor whiteColor]];
    [buttons addObject:bi];
    
    bi = [[UIBarButtonItem alloc]initWithTitle:@"Select all" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllFiles:)];
    bi.tag=102;
    [bi setTintColor:[UIColor whiteColor]];
    [buttons addObject:bi];

    [tools setItems:buttons animated:NO];
    UIBarButtonItem *threeButtons = [[UIBarButtonItem alloc] initWithCustomView:tools];
    self.navigationItem.rightBarButtonItem = threeButtons;

    
    self.navigationItem.leftBarButtonItem=nil;
     // left bar button tool bar
    UIToolbar *tools1 = [[UIToolbar alloc]
                         initWithFrame:CGRectMake(0.0f, 0.0f, 95.0f, 44.01f)]; // 44.01 shifts it up 1px for some reason
    tools1.tag=101;
    tools1.layer.borderColor = [[UIColor whiteColor] CGColor];
    tools1.clipsToBounds = YES;
    tools1.barTintColor = [UIColor appNavyBlueColor];
    tools1.translucent = NO;

    NSMutableArray *buttons1 = [[NSMutableArray alloc] initWithCapacity:4];
    UIBarButtonItem *bi1 = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
    bi1.imageInsets=UIEdgeInsetsMake(0, -30, 0, 0);
    [bi1 setTintColor:[UIColor whiteColor]];
    [buttons1 addObject:bi1];
    
    //Create a spacer.
    bi1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    bi1.width = 8.0f;
    [bi1 setTintColor:[UIColor whiteColor]];
    [buttons1 addObject:bi1];

    // Add profile button.
    selectedCountLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 5, 30, 20)];
    selectedCountLabel.text=[NSString stringWithFormat:@"%ld",arrayOfMarked.count];
    selectedCountLabel.textColor = [UIColor whiteColor];
    bi1 = [[UIBarButtonItem alloc]initWithCustomView:selectedCountLabel];
    [bi1 setTintColor:[UIColor whiteColor]];
    [buttons1 addObject:bi1];
    
    bi1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    bi1.width = -15.0f;
    [bi1 setTintColor:[UIColor whiteColor]];
    [buttons1 addObject:bi1];
    
    bi1 = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Check"] style:UIBarButtonItemStylePlain target:self action:nil];
    [bi1 setTintColor:[UIColor whiteColor]];
    [buttons1 addObject:bi1];
  
    // Add buttons to toolbar and toolbar to nav bar.
    [tools1 setItems:buttons1 animated:NO];
    UIBarButtonItem *threeButtons1 = [[UIBarButtonItem alloc] initWithCustomView:tools1];
    self.navigationItem.leftBarButtonItem = threeButtons1;

    
    int uploadFileCount=0;
    for (NSInteger i = 0; i < self.genericFilesArray.count; ++i)
    {
        NSIndexPath* indexPath= [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell* cell= [self.tableView cellForRowAtIndexPath:indexPath];
        UILabel* deleteStatusLabel=[cell viewWithTag:105];
        if ([deleteStatusLabel.text containsString:@"Uploading"])
        {
            ++uploadFileCount;
        }
    }
    if ([APIManager sharedManager].awaitingFileTransferNamesArray.count-uploadFileCount==1)
    {
        UIBarButtonItem* vc=self.navigationItem.rightBarButtonItem;
        UIToolbar* view=  vc.customView;
        NSArray* arr= [view items];
        UIBarButtonItem* button= [arr objectAtIndex:4];
        //UIButton* button=  [view viewWithTag:102];
        
        [button setTitle:@"Deselect all"];
    }

    

//    navigationController.navigationBar.tintColor = .white
}


-(void)deleteMutipleFiles
{
    NSString* deleteMessage;
    if (arrayOfMarked.count > 1)
    {
        deleteMessage = DELETE_MESSAGE_MULTIPLES;
    }
    else
    {
        deleteMessage = DELETE_MESSAGE;
    }
    alertController = [UIAlertController alertControllerWithTitle:@"Delete"
                                                          message:deleteMessage
                                                   preferredStyle:UIAlertControllerStyleAlert];
    
    
    actionDelete = [UIAlertAction actionWithTitle:@"Delete"
                                            style:UIAlertActionStyleDestructive
                                          handler:^(UIAlertAction * action)
                    {
                        
                        for (int i=0; i<arrayOfMarked.count; i++)
                            
                        {
                            Database* db=[Database shareddatabase];
                            APIManager* app=[APIManager sharedManager];
                            NSString* dateAndTimeString=[app getDateAndTimeString];
                            NSIndexPath* indexPath=[arrayOfMarked objectAtIndex:i];
                            
                            AudioDetails* audioDetails = [self.genericFilesArray objectAtIndex:indexPath.row];
                            NSString* fileName = audioDetails.fileName;
                            self.navigationItem.title=self.currentViewName;
                            self.navigationItem.rightBarButtonItem = nil;
                            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
                            self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];

                            toolBarAdded=NO;
                            [db updateAudioFileStatus:@"RecordingDelete" fileName:fileName dateAndTime:dateAndTimeString];
                            [app deleteFile:fileName];
                            [app deleteFile:[NSString stringWithFormat:@"%@backup",fileName]];
                          
                        }
                        [arrayOfMarked removeAllObjects];
                        [self.checkedIndexPath removeAllObjects];
                        
                        [self prepareDataSourceForTableView];
                        
                        self.genericFilesPredicateArray = [[NSMutableArray alloc] initWithArray:self.genericFilesArray];
                        
                        [self updateSerachBarManually];

                        [self.tableView reloadData];

                    }]; //You can use a block here to handle a press on this button
    [alertController addAction:actionDelete];
    
    
    actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                            style:UIAlertActionStyleCancel
                                          handler:^(UIAlertAction * action)
                    {
                        [alertController dismissViewControllerAnimated:YES completion:nil];
                        
                            
                            self.navigationItem.title=self.currentViewName;
                            self.navigationItem.rightBarButtonItem = nil;
                        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
                        self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];

                            isMultipleFilesActivated=NO;
                        self.tableView.allowsMultipleSelection = NO; // for ipad

                            toolBarAdded=NO;
                            
                        [arrayOfMarked removeAllObjects];
                        [self.checkedIndexPath removeAllObjects];
                        [self prepareDataSourceForTableView];
                        [self.tableView reloadData];
                        
                    }]; //You can use a block here to handle a press on this button
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

-(void)uploadMultipleFilesToserver
{
    NSString* transferMessage;
    if (arrayOfMarked.count > 1)
    {
        transferMessage = TRANSFER_MESSAGE_MULTIPLES;
    }
    else
    {
        transferMessage = TRANSFER_MESSAGE;
    }
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {

    alertController = [UIAlertController alertControllerWithTitle:transferMessage
                                                          message:@""
                                                   preferredStyle:UIAlertControllerStyleAlert];
    actionDelete = [UIAlertAction actionWithTitle:@"Yes"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            
                       
                        isMultipleFilesActivated = NO;
                        self.tableView.allowsMultipleSelection = NO; // for ipad

                        NSMutableArray* aarayOfMarkedCopy=[[NSMutableArray alloc]init];
                        for (int i=0; i<arrayOfMarked.count; i++)
                            
                        {
                            isMultipleFilesActivated=NO;

                            APIManager* app=[APIManager sharedManager];
                            NSIndexPath* indexPath=[arrayOfMarked objectAtIndex:i];
                            //[aarayOfMarkedCopy addObject:[arrayOfMarked objectAtIndex:i]];
                            AudioDetails* audioDetails = [self.genericFilesArray objectAtIndex:indexPath.row];
                            NSString* fileName = audioDetails.fileName;
                            
                            self.navigationItem.title=self.currentViewName;
                            self.navigationItem.rightBarButtonItem = nil;
                            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
                            self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];

                            toolBarAdded=NO;
                            
                            NSString* transferStatus = audioDetails.uploadStatus;

                            if ([transferStatus isEqualToString:@"TransferFailed"])
                            {
                                int mobileDictationIdVal=[[Database shareddatabase] getMobileDictationIdFromFileName:fileName];
                                
                                NSString* date=[app getDateAndTimeString];
                                
                                [[Database shareddatabase] updateAudioFileUploadedStatus:@"ResendFailed" fileName:fileName dateAndTime:date mobiledictationidval:mobileDictationIdVal];
                            }
                            
                            [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUpload" fileName:fileName];
                            
                        }
                        [arrayOfMarked removeAllObjects];//array of marked is for to get marked cells(objects),got the file names from arrayof marked,update the db hence remove all objects,and rload table
                        //[self.tableView reloadData];
                        [aarayOfMarkedCopy addObjectsFromArray:self.checkedIndexPath];
                        
                        [self.checkedIndexPath removeAllObjects];
                        
                        [self prepareDataSourceForTableView]; // get the updated data(i.e. searched and long press uploaded) and after getting that data update predicate array with the updated data so when serach bar get clear "genericFilesArray" will get appropriate data
                        
                        self.genericFilesPredicateArray = [[NSMutableArray alloc] initWithArray:self.genericFilesArray];

                        [self updateSerachBarManually];
                            
                        [self.tableView reloadData];
//                            [self updateSerachBarManually];
                        for (int i=0; i<aarayOfMarkedCopy.count; i++)
                        {
                             NSString* fileName=[aarayOfMarkedCopy objectAtIndex:i];
                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                 
                                APIManager* app=[APIManager sharedManager];
                                
                                [app uploadFileToServer:fileName jobName:FILE_UPLOAD_API];
                                
                            });
                        }
                        isMultipleFilesActivated=NO;
                        self.tableView.allowsMultipleSelection = NO; // for ipad

                             });
                    }]; //You can use a block here to handle a press on this button
    [alertController addAction:actionDelete];
    
    
    actionCancel = [UIAlertAction actionWithTitle:@"No"
                                            style:UIAlertActionStyleCancel
                                          handler:^(UIAlertAction * action)
                    {
                        [alertController dismissViewControllerAnimated:YES completion:nil];

                        self.navigationItem.title=self.currentViewName;
                        self.navigationItem.rightBarButtonItem = nil;
                        
                        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
                        self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];

                        isMultipleFilesActivated=NO;
                        self.tableView.allowsMultipleSelection = NO; // for ipad
                        toolBarAdded=NO;

                        [self.checkedIndexPath removeAllObjects];
                        [arrayOfMarked removeAllObjects];
                        [self prepareDataSourceForTableView];
                        [self.tableView reloadData];

                    }]; //You can use a block here to handle a press on this button
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
    
    else
    {
        self.navigationItem.title=self.currentViewName;
        self.navigationItem.rightBarButtonItem = nil;
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];

        isMultipleFilesActivated=NO;
        self.tableView.allowsMultipleSelection = NO; // for ipad
        toolBarAdded=NO;
        
        [self.checkedIndexPath removeAllObjects];
        [arrayOfMarked removeAllObjects];
        [self prepareDataSourceForTableView];
        [self.tableView reloadData];

        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }

    
}

-(void)selectAllFiles:(UIBarButtonItem*)sender
{
    
    if ([sender.title isEqualToString:@"Select all"])
    {
        sender.title=@"Deselect all";
        [self.checkedIndexPath removeAllObjects];
        [arrayOfMarked removeAllObjects];
        APIManager* app=[APIManager sharedManager];
        Database* db=[Database shareddatabase];
        self.genericFilesArray = [db getListOfFileTransfersOfStatus:@"RecordingComplete"];

        for (NSInteger i = 0; i < self.genericFilesArray.count; ++i)
        {
          NSIndexPath* indexPath= [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell* cell= [self.tableView cellForRowAtIndexPath:indexPath];
            AudioDetails* audioDetails = [self.genericFilesArray objectAtIndex:i];
            NSString* fileName = audioDetails.fileName;

//            NSLog(@"filename = %@, dic status = %@",fileName, [awaitingFileTransferDict valueForKey:@"DictationStatus"]);
            
           if (![audioDetails.dictationStatus isEqualToString:@"RecordingFileUpload"])
            {

                [arrayOfMarked addObject:indexPath];
                [cell setSelected:YES];
                [self.checkedIndexPath addObject:fileName];

            }
            selectedCountLabel.text=[NSString stringWithFormat:@"%ld",arrayOfMarked.count];

        }
        [self prepareDataSourceForTableView];
        [self.tableView reloadData];
    }
    else
    {
        sender.title=@"Select all";
        self.navigationItem.title=self.currentViewName;
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
        
        isMultipleFilesActivated=NO;
        self.tableView.allowsMultipleSelection = NO; // for ipad
        [self.checkedIndexPath removeAllObjects];
        [arrayOfMarked removeAllObjects];
        selectedCountLabel.text=[NSString stringWithFormat:@"%ld",arrayOfMarked.count];

        toolBarAdded=NO;
        [self prepareDataSourceForTableView];
        [self.tableView reloadData];
        
        
    }

    

}

- (void)myClassDelegateMethod:(AudioDetailsViewController *)sender
{
    [self prepareDataSourceForTableView];
    [self.tableView reloadData];
    
    [self addEmptyVCToSplitVC];

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

@end
