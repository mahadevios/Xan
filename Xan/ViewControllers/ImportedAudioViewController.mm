//
//  ImportedAudioViewController.m
//  Cube
//
//  Created by mac on 27/12/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "ImportedAudioViewController.h"
#import "AudioDetailsViewController.h"
#import "Database.h"
#import "APIManager.h"
#import "AppPreferences.h"
#import "Constants.h"

extern OSStatus DoConvertFile(CFURLRef sourceURL, CFURLRef destinationURL, OSType outputFormat, Float64 outputSampleRate);

@interface ImportedAudioViewController ()

@end

@implementation ImportedAudioViewController

@synthesize audioFilePath;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title=@"Imported Dictations";
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateFileUploadResponse:) name:NOTIFICATION_FILE_UPLOAD_API
                                               object:nil];
    // Do any additional setup after loading the view.
}

-(void)validateFileUploadResponse:(NSNotification*)obj
{
    [[Database shareddatabase] getlistOfimportedFilesAudioDetailsArray:5];

    [self.tableView reloadData];
}
-(void)popViewController:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)viewWillAppear:(BOOL)animated
{

    int count= [[Database shareddatabase] getCountOfTransfersOfDicatationStatus:@"RecordingPause"];
    
    [[Database shareddatabase] getlistOfimportedFilesAudioDetailsArray:5];//get count of imported non transferred files
    
    int importedFileCount=[AppPreferences sharedAppPreferences].importedFilesAudioDetailsArray.count;
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",count+importedFileCount] forKey:INCOMPLETE_TRANSFER_COUNT_BADGE];
    
    NSString* alertCount=[[NSUserDefaults standardUserDefaults] valueForKey:INCOMPLETE_TRANSFER_COUNT_BADGE];
    
    UIViewController *alertViewController = [self.tabBarController.viewControllers objectAtIndex:ALERT_TAB_LOCATION];
    
    if ([alertCount isEqualToString:@"0"])
    {
        alertViewController.tabBarItem.badgeValue =nil;
    }
    else
        alertViewController.tabBarItem.badgeValue = [[NSUserDefaults standardUserDefaults] valueForKey:INCOMPLETE_TRANSFER_COUNT_BADGE];
    

    [self.tableView reloadData];
    
    [self.tabBarController.tabBar setHidden:YES];
    
    if (self.splitViewController.isCollapsed)
    {
        
        
        self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
        [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];

        [self.tabBarController.tabBar setHidden:YES];
        
    }
    
    else
    {
        self.navigationItem.leftBarButtonItem = nil;
        
        self.navigationController.navigationBar.hidden = false;
        
        [self.tabBarController.tabBar setHidden:NO];
        
        NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIColor colorWithRed:250/255.0 green:162/255.0 blue:27/255.0 alpha:1],NSForegroundColorAttributeName,[UIFont systemFontOfSize:20.0 weight:UIFontWeightBold],NSFontAttributeName, nil];
        
        //            [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
        
        [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
        
    }
   

    
}
- (IBAction)backButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark: tableView delegates adn datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [AppPreferences sharedAppPreferences].importedFilesAudioDetailsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AudioDetails* audioDetails;
    
    audioDetails = [[AppPreferences sharedAppPreferences].importedFilesAudioDetailsArray objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    UILabel* departmentNameLabel=[cell viewWithTag:101];
    
    UILabel* recordingDurationLabel=[cell viewWithTag:102];
    
    UILabel* nameLabel=[cell viewWithTag:103];
    
    UILabel* dateLabel=[cell viewWithTag:104];
    
    UILabel* timeLabel=[cell viewWithTag:105];
    
    UILabel* statusLabel=[cell viewWithTag:106];

    NSString* dateAndTimeString = audioDetails.recordingDate;
    
    NSArray* dateAndTimeArray=[dateAndTimeString componentsSeparatedByString:@" "];
    
    //int audioMinutes= [[awaitingFileTransferDict valueForKey:@"CurrentDuration"] intValue]/60;
    
    //int audioSeconds= [[awaitingFileTransferDict valueForKey:@"CurrentDuration"] intValue]%60;
    
    departmentNameLabel.text = [audioDetails.fileName stringByDeletingPathExtension];
    
    int audioHour= [audioDetails.currentDuration intValue]/(60*60);
    int audioHourByMod= [audioDetails.currentDuration  intValue]%(60*60);
    
    int audioMinutes = audioHourByMod / 60;
    int audioSeconds = audioHourByMod % 60;
    
    recordingDurationLabel.text=[NSString stringWithFormat:@"%02d:%02d:%02d",audioHour,audioMinutes,audioSeconds];

    nameLabel.text = audioDetails.department;

    
    if ([audioDetails.dictationStatus isEqualToString:@"RecordingFileUpload"])
    {
        statusLabel.text=@"Uploading";
    }
    else
    {
        if ([audioDetails.uploadStatus isEqualToString:@"NotTransferred"])
        {
            statusLabel.text=@"Not Transferred";

        }
        else
            statusLabel.text = audioDetails.uploadStatus;
    }
    
    if (dateAndTimeArray.count>1)
    {
        
        dateLabel.text = [dateAndTimeArray objectAtIndex:0];
        
        timeLabel.text=[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:1]];
    }
    
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableview didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSDictionary* awaitingFileTransferDict;
    UITableViewCell* cell= [tableview cellForRowAtIndexPath:indexPath];
    
    UILabel* deleteStatusLabel=[cell viewWithTag:106];
    
    if(([deleteStatusLabel.text isEqual:@"Uploading"]))
    {
        
        alertController = [UIAlertController alertControllerWithTitle:@"Alert?"
                                                              message:@"File is in use!"
                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        actionDelete = [UIAlertAction actionWithTitle:@"Ok"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action)
                        {
                            [alertController dismissViewControllerAnimated:YES completion:nil];
                        }];
        
        [alertController addAction:actionDelete];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }

    else
    {
        AudioDetails* audioDetails;
        
        audioDetails = [[AppPreferences sharedAppPreferences].importedFilesAudioDetailsArray objectAtIndex:indexPath.row];
        
        AudioDetailsViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioDetailsViewController"];
    
        vc.selectedView=@"Imported";
        
        vc.selectedRow=indexPath.row;
        
        vc.audioDetails = audioDetails;
        
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        
        if (self.splitViewController.isCollapsed)
        {
            
            [self presentViewController:vc animated:YES completion:nil];
        }
        else
        {

            [self.navigationController pushViewController:vc animated:true];
        }
        

    }
        
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
