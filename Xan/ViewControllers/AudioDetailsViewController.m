//
//  AudioDetailsViewController.m
//  Cube
//
//  Created by mac on 28/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "AudioDetailsViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "DepartMent.h"
#import "PopUpCustomView.h"
#import "InCompleteRecordViewController.h"
#import "Database.h"
#import "APIManager.h"
#import "AppPreferences.h"
#import "Constants.h"
#import "UIColor+ApplicationColors.h"

#define IMPEDE_PLAYBACK NO

@interface AudioDetailsViewController ()
{
    AVAudioPlayer       *player;
}
@end

@implementation AudioDetailsViewController

@synthesize transferDictationButton,deleteDictationButton,moreButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pausePlayerFromBackGround) name:NOTIFICATION_PAUSE_AUDIO_PALYER
                                               object:nil];
    
    popupView=[[UIView alloc]init];
    
    forTableViewObj=[[PopUpCustomView alloc]init];
    
    if (self.splitViewController == nil)
    {
        self.backImageView.hidden = false;
        self.backButton.hidden = false;
        
    }
    else
        if(self.splitViewController.isCollapsed == false)
        {
            self.backImageView.hidden = true;
            self.backButton.hidden = false;
            
        }
    
    NSString* dictatorName = [[NSUserDefaults standardUserDefaults] valueForKey:@"DictatorName"];
    
    self.dictatedByLabel.text = dictatorName;
    
    [self setTemplateDropDown];
    
}

-(void)setTemplateDropDown
{
    templateNamesDropdownMenu = [[MKDropdownMenu alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    templateNamesDropdownMenu.dataSource = self;
    templateNamesDropdownMenu.delegate = self;
    templateNamesDropdownMenu.layer.cornerRadius = 3.0;
    [templateNamesDropdownMenu setBackgroundDimmingOpacity:0];
    [templateNamesDropdownMenu setDropdownShowsBorder:true];
    [templateNamesDropdownMenu setBackgroundColor:[UIColor whiteColor]];
    templateNamesDropdownMenu.layer.borderWidth = 1.0;
    templateNamesDropdownMenu.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    [self.mkDropdwonRefView addSubview:templateNamesDropdownMenu];
    
    
    UITapGestureRecognizer* tapGestureRecogniser = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(disMissTemplateDropDown:)];
    
    //    tapGestureRecogniser.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecogniser];
    
}

-(void)setTemplateData
{
    if (([self.audioDetails.templateName isEqualToString:@"-1"] || self.audioDetails.templateName == NULL ) && selectedTemplateName == nil)
    {
        self.audioDetails.templateName = @"Select Template";
        selectedTemplateName = @"Select Template";
    }
    else
        if (selectedTemplateName == nil)
        {
            selectedTemplateName = self.audioDetails.templateName;
            recentlySelectedTemplateName = self.audioDetails.templateName;
        }
    
    if ([self.audioDetails.department.departmentName containsString:@"(Unassigned)"]) {
        templateNamesDropdownMenu.userInteractionEnabled = false;
    }
    
    NSString* deptId = self.audioDetails.department.Id;
    
    [self getTempliatFromDepartMentName:deptId];
    
    [templateNamesDropdownMenu reloadAllComponents];
    
}

-(void)disMissTemplateDropDown:(UITapGestureRecognizer *)gestureRecognizer
{
    [templateNamesDropdownMenu closeAllComponentsAnimated:true];
    
}

-(void)getTempliatFromDepartMentName:(NSString*)departmentId
{
    NSArray* templateListArray = [[Database shareddatabase] getTemplateListfromDeptName:departmentId];
    
    [AppPreferences sharedAppPreferences].tempalateListDict = [NSMutableDictionary new];
    
    for (Template* templateObj in templateListArray)
    {
        [[AppPreferences sharedAppPreferences].tempalateListDict setObject:templateObj.templateId forKey:templateObj.templateName];
    }
    
    templateNamesArray = [[[AppPreferences sharedAppPreferences].tempalateListDict allKeys] mutableCopy];
}

-(void)pausePlayerFromBackGround
{
    [player stop];
    
    UIView* popUpView= [[[UIApplication sharedApplication] keyWindow] viewWithTag:222];
    
    if ([popUpView isKindOfClass:[UIView class]])
    {
        [[[[UIApplication sharedApplication] keyWindow] viewWithTag:222] removeFromSuperview];
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    if (self.splitViewController.isCollapsed == false)
    {
        self.navigationController.navigationBar.hidden = true;
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:@"no" forKey:@"dismiss"];
    
    [self setTemplateData];
    
    if ([self.audioDetails.comment isEqualToString:@""] || self.audioDetails.comment == nil) {
        self.commentLabel.text = @"Add Comment";
       }
    else
    self.commentLabel.text = self.audioDetails.comment;
    
   
    if (![AppPreferences sharedAppPreferences].dismissAudioDetails && ![AppPreferences sharedAppPreferences].recordNew)
    {
        if (!transferDictationButton.isHidden) {// if not uploading then only keep more enabled
            moreButton.userInteractionEnabled=YES;
        }
        
        
        
        if (isDeleteEditTransferButtonsRemovedAfterTransfer == false)
        {
            [transferDictationButton setHidden:NO];
            
            [deleteDictationButton setHidden:NO];
        }
        
        
        self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
        
        transferDictationButton.layer.cornerRadius=4.0f;
        
        deleteDictationButton.layer.cornerRadius=4.0f;
        
        UILabel* filenameLabel=[self.view viewWithTag:501];
        
        UILabel* departmentLabel=[self.view viewWithTag:503];
        
        UILabel* dictatedOnLabel=[self.view viewWithTag:504];
        
        UILabel* transferStatusLabel=[self.view viewWithTag:505];
        
        UILabel* transferDateLabel=[self.view viewWithTag:506];
        
        UILabel* dictatedHeadingLabel=[self.view viewWithTag:2000];
        
        [[self.view viewWithTag:507] setHidden:YES];
        
        if ([self.selectedView isEqualToString:@"Awaiting Transfer"])
        {
            //            audioDetails = [app.awaitingFileTransferNamesArray objectAtIndex:self.selectedRow];
            
            if (![self.audioDetails.uploadStatus isEqualToString:@"Transfer Failed"])
            {
                if (isDeleteEditTransferButtonsRemovedAfterTransfer == false)
                {
                    [self performSelector:@selector(addEditDeleteAndUploadButtons) withObject:nil afterDelay:0.0];
                    //                    [self addEditDeleteAndUploadButtons];
                    
                }
            }
            
            [self setTransferStatus];
        }
        else
            if ([self.selectedView isEqualToString:@"Transferred Today"])
            {
                [transferDictationButton setTitle:@"Resend" forState:UIControlStateNormal];
                
                //                [self.mkDropdwonRefView setUserInteractionEnabled:false];
                
                NSString* tarnsferStatus = self.audioDetails.uploadStatus;
                
                if ([self.audioDetails.deleteStatus isEqualToString:@"Deleted"])//to check wether transferred file is deleted
                {
                    //
                    self.transferDateTitleLabel.text = @"Transfer Date";
                    
                    transferStatusLabel.text=[NSString stringWithFormat:@"%@, Deleted",tarnsferStatus];
                    
                    [transferDictationButton setHidden:YES];
                    
                    [deleteDictationButton setHidden:YES];
                    
                    [templateNamesDropdownMenu setUserInteractionEnabled:false];
                    
                    [moreButton setUserInteractionEnabled:false];
                    
                    [self.urgentCheckboxButton setUserInteractionEnabled:NO];
                    
                    [templateNamesDropdownMenu setUserInteractionEnabled:NO];
                    
                    [self.commentButton setUserInteractionEnabled:false];
                }
                else
                {
                    [self setTransferStatus];
                }
            }
        else
            if ([self.selectedView isEqualToString:@"Transfer Failed"])
                   {
                       //            audioDetails = [app.awaitingFileTransferNamesArray objectAtIndex:self.selectedRow];
                       
                       
                       
                       [self setTransferStatus];
                   }
            else
                if ([self.selectedView isEqualToString:@"Imported"])
                {
                    
                    self.audioDetails = [[AppPreferences sharedAppPreferences].importedFilesAudioDetailsArray objectAtIndex:self.selectedRow];
                    
                    [[self.view viewWithTag:507] setHidden:NO];
                    
                    if (isDeleteEditTransferButtonsRemovedAfterTransfer == false)
                    {
                        [self performSelector:@selector(addEditDeleteAndUploadButtons) withObject:nil afterDelay:0.0];
                        
                    }
                    
                    [self setTransferStatus];
                }
        
        
        if ([self.selectedView isEqualToString:@"Imported"])
        {
            filenameLabel.text= [self.audioDetails.fileName stringByDeletingPathExtension];
            
            dictatedHeadingLabel.text=@"Imported On";
            
            [[self.view viewWithTag:507] setHidden:NO];
            
        }
        else
        {
            filenameLabel.text = self.audioDetails.fileName;
        }
        
        dictatedOnLabel.text = self.audioDetails.recordingDate;;
        
        NSString* departmentName = self.audioDetails.department.departmentName;
        
        departmentLabel.text=departmentName;
        
        self.audioDetails.departmentCopy = self.audioDetails.department;
        
        transferDateLabel.text = self.audioDetails.transferDate;
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
        
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:SELECTED_DEPARTMENT_NAME_COPY];
        
        if ([self.audioDetails.priorityId isEqualToString:[NSString stringWithFormat:@"%d",  URGENT]])
        {
            self.urgentCheckBoxImageView.image = [UIImage imageNamed:@"CheckBoxSelected"];
            
            checkBoxSelected = true;
        }
        else
        {
            self.urgentCheckBoxImageView.image = [UIImage imageNamed:@"CheckBoxUnSelected"];
            
            checkBoxSelected = false;
        }
        
    }
    else
    {
        if ([AppPreferences sharedAppPreferences].recordNew)
        {
            [AppPreferences sharedAppPreferences].recordNew = false;
            
            UIViewController* vc= [self.storyboard instantiateViewControllerWithIdentifier:@"RecordViewController"];
            
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
            {
                [self.splitViewController presentViewController:vc animated:YES completion:nil];
            }
            else
            {
                [self presentViewController:vc animated:YES completion:nil];
            }
            
            
            [[NSUserDefaults standardUserDefaults] setValue:@"no" forKey:@"dismiss"];
        }
        else
        {
            [AppPreferences sharedAppPreferences].dismissAudioDetails = NO;
            
            [[[[self.view viewWithTag:900] viewWithTag:800] viewWithTag:801] removeFromSuperview];//remove uploading buuton
            
            [[[[self.view viewWithTag:900] viewWithTag:800] viewWithTag:802] removeFromSuperview];//remove delete button
            
            [[[[self.view viewWithTag:900] viewWithTag:800] viewWithTag:803] removeFromSuperview];//remove edit button
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    [self findDuplicateDepartmentNames];
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

-(void)setTransferStatus
{
    NSString* tarnsferStatus = self.audioDetails.uploadStatus;
    
    UILabel* transferStatusLabel=[self.view viewWithTag:505];
    
    if ([tarnsferStatus isEqualToString:@"Transfer Failed"])
    {
        self.transferDateTitleLabel.text = @"Transfer Failed Date";
        
        transferStatusLabel.text = @"Transfer Failed";
    }
    else if ([tarnsferStatus isEqualToString:@"NotTransferred"])
    {
        self.transferDateTitleLabel.text = @"Transfer Date";
        
        transferStatusLabel.text = @"Not Transferred";
        
    }
    else
    {
        self.transferDateTitleLabel.text = @"Transfer Date";
        
        transferStatusLabel.text = tarnsferStatus;
    }
}

-(void)addEditDeleteAndUploadButtons
{
    if (([[[self.view viewWithTag:900] viewWithTag:800] viewWithTag:801] == nil))
    {
        UIButton* uploadRecordButton;
        
        
        uploadRecordButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.origin.x+self.view.frame.size.width*0.095, transferDictationButton.frame.origin.y, self.view.frame.size.width*0.83, transferDictationButton.frame.size.height)];
        
        
        uploadRecordButton.tag = 801;
        
        //        uploadRecordButton.backgroundColor=[UIColor colorWithRed:250/255.0 green:162/255.0 blue:27/255.0 alpha:1];
        uploadRecordButton.backgroundColor = [UIColor darkHomeColor];
        
        [uploadRecordButton setTitle:@"Transfer Recording" forState:UIControlStateNormal];
        
        uploadRecordButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        
        [uploadRecordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        uploadRecordButton.layer.cornerRadius=5.0f;
        
        [uploadRecordButton addTarget:self action:@selector(transferDictationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* deleteRecordButton = [[UIButton alloc]initWithFrame:CGRectMake(uploadRecordButton.frame.origin.x, uploadRecordButton.frame.origin.y+uploadRecordButton.frame.size.height+12, uploadRecordButton.frame.size.width*0.48, uploadRecordButton.frame.size.height)];
        
        deleteRecordButton.tag = 802;
        
        //        deleteRecordButton.backgroundColor=[UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1];
        
        deleteRecordButton.backgroundColor=[UIColor CRedColor];
        
        [deleteRecordButton setTitle:@"Delete Recording" forState:UIControlStateNormal];
        
        deleteRecordButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        
        [deleteRecordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        deleteRecordButton.layer.cornerRadius=5.0f;
        
        [deleteRecordButton addTarget:self action:@selector(deleteRecording) forControlEvents:UIControlEventTouchUpInside];
       
        UIButton* editRecordButton=[[UIButton alloc]initWithFrame:CGRectMake(deleteRecordButton.frame.origin.x+deleteRecordButton.frame.size.width+uploadRecordButton.frame.size.width*0.04, deleteRecordButton.frame.origin.y,uploadRecordButton.frame.size.width*0.48, deleteRecordButton.frame.size.height)];
        
        editRecordButton.tag = 803;
        
        //        editRecordButton.backgroundColor=[UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1];
        
        editRecordButton.backgroundColor=[UIColor lightHomeColor];
        
        [editRecordButton setTitle:@"Edit Recording" forState:UIControlStateNormal];
        
        editRecordButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        
        [editRecordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        editRecordButton.layer.cornerRadius=5.0f;
        
        [editRecordButton addTarget:self action:@selector(showEditRecordingView) forControlEvents:UIControlEventTouchUpInside];
        
        //        NSArray* arr =  self.splitViewController.viewControllers;
        
        long viewWidth = self.splitViewController.primaryColumnWidth;
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {//for ipad
            
            uploadRecordButton.frame = CGRectMake((self.view.frame.size.width-viewWidth)*0.1, transferDictationButton.frame.origin.y, (self.view.frame.size.width-viewWidth)*0.8, transferDictationButton.frame.size.height);
            
            deleteRecordButton.frame = CGRectMake((self.view.frame.size.width-viewWidth)*0.1, uploadRecordButton.frame.origin.y+uploadRecordButton.frame.size.height+10, uploadRecordButton.frame.size.width*0.48, transferDictationButton.frame.size.height);
            
            editRecordButton.frame = CGRectMake(deleteRecordButton.frame.origin.x+deleteRecordButton.frame.size.width+uploadRecordButton.frame.size.width*0.04, uploadRecordButton.frame.origin.y+uploadRecordButton.frame.size.height+10, uploadRecordButton.frame.size.width*0.48, transferDictationButton.frame.size.height);
            
            //            uploadRecordButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
            //
            //            deleteRecordButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
            //
            //            editRecordButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
            
            
        }
        
        [[[self.view viewWithTag:900] viewWithTag:800] addSubview:uploadRecordButton];
        [[[self.view viewWithTag:900] viewWithTag:800] addSubview:deleteRecordButton];
        [[[self.view viewWithTag:900] viewWithTag:800] addSubview:editRecordButton];
    }
    
    
    [transferDictationButton removeFromSuperview];
    
    [deleteDictationButton removeFromSuperview];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME_COPY];
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SELECTED_DEPARTMENT_NAME];
    
    //    DepartMent *deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //
    //    DepartMent *deptObj1 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
}
-(void)popViewController:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)moreButtonClicked:(id)sender
{
    [templateNamesDropdownMenu closeAllComponentsAnimated:true];
    
    NSArray* subViewArray=[NSArray arrayWithObjects:@"Change Clinical Speciality", nil];
    
    UIView* pop=[[PopUpCustomView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x+self.view.frame.size.width-200, self.view.frame.origin.y+40, 200, 40) andSubViews:subViewArray :self];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:pop];
}

-(void)ChangeClinicalSpeciality
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    
    CGRect frame=CGRectMake(10.0f, self.view.center.y-150, self.view.frame.size.width - 20.0f, 200.0f);
    
    UITableView* tab= [forTableViewObj tableView:self frame:frame];
    
    [popupView addSubview:tab];
    
    //[popupView addGestureRecognizer:tap];
    [popupView setFrame:[[UIScreen mainScreen] bounds]];
    
    //[popupView addSubview:[self.view viewWithTag:504]];
    UIView *buttonsBkView = [[UIView alloc] initWithFrame:CGRectMake(tab.frame.origin.x, tab.frame.origin.y + tab.frame.size.height, tab.frame.size.width, 70.0f)];
    
    buttonsBkView.backgroundColor = [UIColor whiteColor];
    
    [popupView addSubview:buttonsBkView];
    
    UIButton* cancelButton=[[UIButton alloc]initWithFrame:CGRectMake(frame.size.width-200, 20.0f, 80, 30)];
    
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    
    [cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    //[cancelButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton* saveButton=[[UIButton alloc]initWithFrame:CGRectMake(cancelButton.frame.origin.x+cancelButton.frame.size.width+16, 20.0f, 80, 30)];
    
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    
    [saveButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //[saveButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    [saveButton addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    
    [buttonsBkView addSubview:cancelButton];
    
    [buttonsBkView addSubview:saveButton];
    
    
    popupView.tag=504;
    
    [popupView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:popupView];
    
}


- (IBAction)backButtonPressed:(id)sender
{
    [templateNamesDropdownMenu closeAllComponentsAnimated:true];
    
    [player stop];
    
    if (self.splitViewController.isCollapsed || self.splitViewController == nil)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    else
    {
        //        NSMutableArray* subVC = [[NSMutableArray alloc] initWithArray:[self.splitViewController viewControllers]];
        //
        //        [subVC removeLastObject];
        [self.navigationController popViewControllerAnimated:true];
        
        
    }
    
}

- (IBAction)deleteDictation:(id)sender
{
    
    [self deleteRecording];
    
}

-(void)deleteRecording
{
    alertController = [UIAlertController alertControllerWithTitle:@"Delete"
                                                          message:DELETE_MESSAGE
                                                   preferredStyle:UIAlertControllerStyleAlert];
    actionDelete = [UIAlertAction actionWithTitle:@"Delete"
                                            style:UIAlertActionStyleDestructive
                                          handler:^(UIAlertAction * action)
                    {
        APIManager* app=[APIManager sharedManager];
        
        Database* db=[Database shareddatabase];
        
        NSString* fileName = self.audioDetails.fileName;
        
        NSString* dateAndTimeString=[app getDateAndTimeString];
        
        [db updateAudioFileStatus:@"RecordingDelete" fileName:fileName dateAndTime:dateAndTimeString];
        
        [app deleteFile:[NSString stringWithFormat:@"%@backup",fileName]];
        
        [app deleteFile:[NSString stringWithFormat:@"%@copy",fileName]];
        
        [app deleteFile:[NSString stringWithFormat:@"%@editedCopy",fileName]];
        
         [self updateTempUrgentAndUIAfterUpload];
        
        BOOL delete= [app deleteFile:fileName];
        
        if ([self.selectedView isEqualToString:@"Imported"])
        {
            NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_IDENTIFIER];
            
            // NSString* sharedAudioFolderPathString=[sharedDefaults objectForKey:@"audioFolderPath"];
            
            NSMutableArray* sharedAudioNamesArray=[NSMutableArray new];
            
            NSArray* copyArray=[NSArray new];
            
            copyArray=[sharedDefaults objectForKey:@"audioNamesArray"];
            
            sharedAudioNamesArray=[copyArray mutableCopy];
            
            for (int i=0; i<sharedAudioNamesArray.count; i++)
            {
                
                NSString* pathExtension= [[sharedAudioNamesArray objectAtIndex:i] pathExtension];
                
                NSString* fileNameWithExtension=[NSString stringWithFormat:@"%@.%@",fileName,pathExtension];
                //
                if ([sharedAudioNamesArray containsObject:fileNameWithExtension])
                {
                    [sharedAudioNamesArray removeObject:fileNameWithExtension];
                    
                    break;
                    
                }
                
            }
            
            [sharedDefaults setObject:sharedAudioNamesArray forKey:@"audioNamesArray"];
            
            [sharedDefaults synchronize];
        }
        
        
        
        if (delete)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
        [self.delegate myClassDelegateMethod:nil];
        
    }]; //You can use a block here to handle a press on this button
    [alertController addAction:actionDelete];
    
    
    actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                            style:UIAlertActionStyleCancel
                                          handler:^(UIAlertAction * action)
                    {
        [alertController dismissViewControllerAnimated:YES completion:nil];
        
    }]; //You can use a block here to handle a press on this button
    
    [alertController addAction:actionCancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
}

- (IBAction)playRecordingButtonPressed:(id)sender
{
    [templateNamesDropdownMenu closeAllComponentsAnimated:true];
    
    if ([self.audioDetails.deleteStatus isEqualToString:@"Deleted"])//to check wether transferred file is deleted
    {
        alertController = [UIAlertController alertControllerWithTitle:@"File does not exist"
                                                              message:@""
                                                       preferredStyle:UIAlertControllerStyleAlert];
        actionDelete = [UIAlertAction actionWithTitle:@"Ok"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action)
                        {
            
        }]; //You can use a block here to handle a press on this button
        
        [alertController addAction:actionDelete];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    else
    {
        
        UIView * overlay1=[[PopUpCustomView alloc]initWithFrame:CGRectMake(self.view.frame.size.width*0.05, self.view.center.y-40, self.view.frame.size.width*0.9, 80) senderNameForSlider:self player:player];
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:overlay1];
        
        sliderPopUpView=  [overlay1 viewWithTag:223];
        
        audioRecordSlider=  [sliderPopUpView viewWithTag:224];
        
        UIImageView* pauseOrPlayImageView= [sliderPopUpView viewWithTag:226];
        
        UILabel* dateAndTimeLabel=[sliderPopUpView viewWithTag:225];
        
        //        dateAndTimeLabel.text=[audiorecordDict valueForKey:@"RecordCreatedDate"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString* dateStr = self.audioDetails.recordingDate;
        NSDate *date = [dateFormatter dateFromString:dateStr];
        
        // Convert date object into desired format
        [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
        NSString *newDateString = [dateFormatter stringFromDate:date];
        
        dateAndTimeLabel.text = newDateString;
        
        pauseOrPlayImageView.image=[UIImage imageNamed:@"Pause"];
        
        NSString* filName;
        
        
        filName = self.audioDetails.fileName;
        
        if (!IMPEDE_PLAYBACK)
        {
            [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryPlayback];
        }
        
        NSArray* pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   AUDIO_FILES_FOLDER_NAME,
                                   [NSString stringWithFormat:@"%@.caf", filName],
                                   nil];
        
        NSURL* recordedAudioURL = [NSURL fileURLWithPathComponents:pathComponents];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[recordedAudioURL path]])
        {
            pathComponents = [NSArray arrayWithObjects:
            [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
            AUDIO_FILES_FOLDER_NAME,
            [NSString stringWithFormat:@"%@.wav", filName],
            nil];
            
            recordedAudioURL = [NSURL fileURLWithPathComponents:pathComponents];
            
        }
                
        NSError* audioError;
        
        player= [[AVAudioPlayer alloc] initWithContentsOfURL:recordedAudioURL error:&audioError];
        
        player.delegate = self;
        
        [player prepareToPlay];
        NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSliderTime:) userInfo:nil repeats:YES];
        
        audioRecordSlider.maximumValue=player.duration;
        
        [player play];
        
        //        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
    }
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player1 successfully:(BOOL)flag
{
    UIImageView* pauseOrImageView= [sliderPopUpView viewWithTag:226];
    
    pauseOrImageView.image=[UIImage imageNamed:@"Play"] ;
    
    [player1 stop];
    
    UIView* popUpView= [[[UIApplication sharedApplication] keyWindow] viewWithTag:222];
    
    if ([popUpView isKindOfClass:[UIView class]])
    {
        [[[[UIApplication sharedApplication] keyWindow] viewWithTag:222] removeFromSuperview];
    }
    
}
-(void)playOrPauseButtonPressed
{
    UIImageView* pauseOrImageView= [sliderPopUpView viewWithTag:226];
    
    if ([pauseOrImageView.image isEqual:[UIImage imageNamed:@"Pause"]])
    {
        pauseOrImageView.image=[UIImage imageNamed:@"Play"] ;
        
        [player pause];
        
    }
    else
        if ([pauseOrImageView.image isEqual:[UIImage imageNamed:@"Play"]])
        {
            pauseOrImageView.image=[UIImage imageNamed:@"Pause"] ;
            
            [player play];
            
            //        [UIApplication sharedApplication].idleTimerDisabled = YES;
            
        }
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (popupView.superview != nil)
    {
        if (![touch.view isEqual:popupView])
        {
            return NO;
        }
        
        return YES;
    }
    if (sliderPopUpView.superview != nil)
    {
        UIImageView* pauseOrPlayImageView= [sliderPopUpView viewWithTag:226];
        
        if([pauseOrPlayImageView.image isEqual:[UIImage imageNamed:@"Play"]] && ![touch.view isDescendantOfView:sliderPopUpView])
        {
            return YES;
        }
        if([pauseOrPlayImageView.image isEqual:[UIImage imageNamed:@"Pause"]] && ![touch.view isDescendantOfView:sliderPopUpView])
        {
            return NO;
        }
        if ([touch.view isDescendantOfView:sliderPopUpView])
        {
            
            return NO;
        }
    }
    
    //    if (![touch.view isEqual:templateNamesDropdownMenu])
    //    {
    //        return NO;
    //    }
    
    return YES; // handle the touch
}
-(void)updateSliderTime:(id)sender
{
    audioRecordSlider.value = player.currentTime;
    
    
}
-(void)dismissPopView:(id)sender
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    
    
}
-(void)dismissPlayerView:(id)sender
{
    UIView* popUpView= [[[UIApplication sharedApplication] keyWindow] viewWithTag:222];
    
    if ([popUpView isKindOfClass:[UIView class]])
    {
        [[[[UIApplication sharedApplication] keyWindow] viewWithTag:222] removeFromSuperview];
    }
    
}
-(void)sliderValueChanged
{
    [templateNamesDropdownMenu closeAllComponentsAnimated:true];
    
    player.currentTime = audioRecordSlider.value;
    
}
- (IBAction)transferDictationButtonClicked:(id)sender
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        NSString* deptId = [[Database shareddatabase] getDepartMentIdFromDepartmentName:self.audioDetails.department.departmentName];

        if ([[AppPreferences sharedAppPreferences].inActiveDepartmentIdsArray containsObject:deptId])
                {
                    [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:DEACTIVATE_DEPARTMENT_MESSAGE withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
                    
                    return;
                }
        
        if ([self.selectedView isEqualToString:@"Transferred Today"])
        {
            alertController = [UIAlertController alertControllerWithTitle:RESEND_MESSAGE
                                                                  message:@""
                                                           preferredStyle:UIAlertControllerStyleAlert];
            actionDelete = [UIAlertAction actionWithTitle:@"Yes"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action)
                            {
                
                APIManager* app = [APIManager sharedManager];
                
                //                                NSString* date = [app getDateAndTimeString];
                NSString* date = @"NotApplicable";
                
                NSString* filName = self.audioDetails.fileName;
                
                
                 [self updateTempUrgentAndUIAfterUpload];
                
                [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUpload" fileName:filName];
                int mobileDictationIdVal = [[Database shareddatabase] getMobileDictationIdFromFileName:filName];
                
                [[Database shareddatabase] updateAudioFileUploadedStatus:@"Resend" fileName:filName dateAndTime:date mobiledictationidval:mobileDictationIdVal];
                
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    if ([AppPreferences sharedAppPreferences].isReachable)
                    {
                        [AppPreferences sharedAppPreferences].fileUploading=YES;
                    }
                    
                    [app uploadFileToServer:filName jobName:FILE_UPLOAD_API];
                    
                    
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^
                                   {
                        [[self.view viewWithTag:507] setHidden:YES];
                        
                        
                        
                        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                        {
                            [self.delegate myClassDelegateMethod:nil];
                            
                        }
                    });
                    
                });
                
            }]; //You can use a block here to handle a press on this button
            [alertController addAction:actionDelete];
            
            
            actionCancel = [UIAlertAction actionWithTitle:@"No"
                                                    style:UIAlertActionStyleCancel
                                                  handler:^(UIAlertAction * action)
                            {
                [alertController dismissViewControllerAnimated:YES completion:nil];
                
            }]; //You can use a block here to handle a press on this button
            [alertController addAction:actionCancel];
            
            
            
            
            
        }
        else
            if ([self.selectedView isEqualToString:@"Awaiting Transfer"])
            {
                
                alertController = [UIAlertController alertControllerWithTitle:TRANSFER_MESSAGE
                                                                      message:@""
                                                               preferredStyle:UIAlertControllerStyleAlert];
                
                actionDelete = [UIAlertAction actionWithTitle:@"Yes"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action)
                                {
                    
                    
                    APIManager* app = [APIManager sharedManager];
                    
                    NSString* filName = self.audioDetails.fileName;
                    
                    NSString* transferStatus = self.audioDetails.uploadStatus;
                    
                  
                    [self updateTempUrgentAndUIAfterUpload];
                    
                    if ([AppPreferences sharedAppPreferences].isReachable)
                    {
                        [AppPreferences sharedAppPreferences].fileUploading=YES;
                    }
                   
                   
                    
                    if ([transferStatus isEqualToString:@"Transfer Failed"])
                    {
                        int mobileDictationIdVal=[[Database shareddatabase] getMobileDictationIdFromFileName:filName];
                        
                        //                                        NSString* date=[app getDateAndTimeString];
                        NSString* date = @"NotApplicable";
                        
                        [[Database shareddatabase] updateAudioFileUploadedStatus:@"ResendFailed" fileName:filName dateAndTime:date mobiledictationidval:mobileDictationIdVal];
                    }
                    
                    [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUpload" fileName:filName];
                    
                    
                    [[[[self.view viewWithTag:900] viewWithTag:800] viewWithTag:801] removeFromSuperview];//remove uploading buuton
                    
                    [[[[self.view viewWithTag:900] viewWithTag:800] viewWithTag:802] removeFromSuperview];//remove delete button
                    
                    [[[[self.view viewWithTag:900] viewWithTag:800] viewWithTag:803] removeFromSuperview];//remove edit button
                    
                    
                    
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        [app uploadFileToServer:filName jobName:FILE_UPLOAD_API];
                        
                        
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            
                            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                            {
                                [self.delegate myClassDelegateMethod:nil];
                                
                            }
                        });
                        
                        
                        
                    });
                    
                }]; //You can use a block here to handle a press on this button
                
                [alertController addAction:actionDelete];
                
                
                actionCancel = [UIAlertAction actionWithTitle:@"No"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * action)
                                {
                    [alertController dismissViewControllerAnimated:YES completion:nil];
                    
                }]; //You can use a block here to handle a press on this button
                
                [alertController addAction:actionCancel];
                
                
            }
        
            else
                if ([self.selectedView isEqualToString:@"Transfer Failed"])                //for incomplete and failed transfer please recheck
                {
                    
                    alertController = [UIAlertController alertControllerWithTitle:TRANSFER_MESSAGE
                                                                          message:@""
                                                                   preferredStyle:UIAlertControllerStyleAlert];
                    
                    actionDelete = [UIAlertAction actionWithTitle:@"Yes"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
                        APIManager* app=[APIManager sharedManager];
                        
                        //                                        NSString* date=[app getDateAndTimeString];
                        NSString* date = @"NotApplicable";
                        
                        NSString* filName = self.audioDetails.fileName;
                        
                         [self updateTempUrgentAndUIAfterUpload];
                        
                        [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUpload" fileName:filName];
                        
                        int mobileDictationIdVal=[[Database shareddatabase] getMobileDictationIdFromFileName:filName];
                        
                        [[Database shareddatabase] updateAudioFileUploadedStatus:@"ResendFailed" fileName:filName dateAndTime:date mobiledictationidval:mobileDictationIdVal];
                        
                        
                        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                        {
                            [self.delegate myClassDelegateMethod:nil];
                            
                        }
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            
                            [app uploadFileToServer:filName jobName:FILE_UPLOAD_API];
                            
                            
                        });
                        
                        [[self.view viewWithTag:507] setHidden:YES];
                        
                        
                    }]; //You can use a block here to handle a press on this button
                    
                    [alertController addAction:actionDelete];
                    
                    actionCancel = [UIAlertAction actionWithTitle:@"No"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action)
                                    {
                        [alertController dismissViewControllerAnimated:YES completion:nil];
                        
                    }]; //You can use a block here to handle a press on this button
                    [alertController addAction:actionCancel];
                    
                    
                }
        
                else
                {
                    alertController = [UIAlertController alertControllerWithTitle:TRANSFER_MESSAGE
                                                                          message:@""
                                                                   preferredStyle:UIAlertControllerStyleAlert];
                    actionDelete = [UIAlertAction actionWithTitle:@"Yes"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
                        APIManager* app=[APIManager sharedManager];
                        
                        NSString* filName = self.audioDetails.fileName;
                        
                        //                                        NSString* date=[app getDateAndTimeString];
                        NSString* date = @"NotApplicable";
                        
                        [[[[self.view viewWithTag:900] viewWithTag:800] viewWithTag:801] removeFromSuperview];//remove uploading buuton
                        [[[[self.view viewWithTag:900] viewWithTag:800] viewWithTag:802] removeFromSuperview];//remove delete button
                        
                        [[[[self.view viewWithTag:900] viewWithTag:800] viewWithTag:803] removeFromSuperview];//remove edit button
                        
                        moreButton.userInteractionEnabled=NO;
                        
                        isDeleteEditTransferButtonsRemovedAfterTransfer = YES;
                        
                        [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUpload" fileName:filName];
                        
                        NSString* transferStatus = self.audioDetails.uploadStatus;
                        
                        if ([transferStatus isEqualToString:@"Transferred"])
                        {
                            int mobileDictationIdVal=[[Database shareddatabase] getMobileDictationIdFromFileName:filName];
                            
                            [[Database shareddatabase] updateAudioFileUploadedStatus:@"Resend" fileName:filName dateAndTime:date mobiledictationidval:mobileDictationIdVal];
                        }
                        
                        
                        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                        {
                            [self.delegate myClassDelegateMethod:nil];
                            
                        }
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            
                            
                            if ([AppPreferences sharedAppPreferences].isReachable)
                            {
                                [AppPreferences sharedAppPreferences].fileUploading=YES;
                            }
                            
                            [app uploadFileToServer:filName jobName:FILE_UPLOAD_API];
                            
                            [[self.view viewWithTag:507] setHidden:YES];
                            
                            //[self dismissViewControllerAnimated:YES completion:nil];
                            
                            
                        });
                        
                    }]; //You can use a block here to handle a press on this button
                    
                    [alertController addAction:actionDelete];
                    
                    
                    actionCancel = [UIAlertAction actionWithTitle:@"No"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action)
                                    {
                        [alertController dismissViewControllerAnimated:YES completion:nil];
                        
                    }]; //You can use a block here to handle a press on this button
                    [alertController addAction:actionCancel];
                    
                    
                }
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
    
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:nil withMessage:@"Please check your Internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
    
}

-(void)updateTempUrgentAndUIAfterUpload
{
    
    isDeleteEditTransferButtonsRemovedAfterTransfer = YES;
    
    [transferDictationButton setHidden:YES];
    
    [deleteDictationButton setHidden:YES];
    
    moreButton.userInteractionEnabled=NO;
    
    _commentButton.userInteractionEnabled=NO;
    
    if (checkBoxSelected)
    {
        [[Database shareddatabase] updatePriority:[NSString stringWithFormat:@"%d", URGENT] fileName:self.audioDetails.fileName];
    }
    else
    {
        [[Database shareddatabase] updatePriority:[NSString stringWithFormat:@"%d", NORMAL] fileName:self.audioDetails.fileName];
    }
    
    [self updateTemplateIdForFileName];
    
    [templateNamesDropdownMenu setUserInteractionEnabled:false];
    
    [self.urgentCheckboxButton setUserInteractionEnabled:false];
}
#pragma mark:TableView Datasource and Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Database* db=[Database shareddatabase];
    
    departmentObjectArray=[db getDepartMentObjList];
    
    return departmentObjectArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    cell = [tableview dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    UILabel* departmentLabel=[[UILabel alloc]initWithFrame:CGRectMake(40, 10, self.view.frame.size.width - 60.0f, 18)];

    if ([cell viewWithTag:200] != nil)
       {
           [[cell viewWithTag:200] removeFromSuperview];
       }
 
    UIButton* radioButton=[[UIButton alloc]initWithFrame:CGRectMake(10, 10, 18, 18)];
        
    departmentLabel.tag=200;
    
    radioButton.tag=100;
    
    DepartMent* dept= [departmentObjectArray objectAtIndex:indexPath.row] ;
         
         if ([[AppPreferences sharedAppPreferences].inActiveDepartmentIdsArray containsObject:dept.Id])
            {
                if ([duplicateDepartmentNamesArray containsObject:dept.departmentName]) {
                           
                           departmentLabel.text = [NSString stringWithFormat:@"%@ (%@ INACTIVE)",dept.departmentName,dept.Id];
                       }
                       else
                       {
                           departmentLabel.text = [NSString stringWithFormat:@"%@ (INACTIVE)",dept.departmentName];
                       }
                
            }
            else
            {
                if ([duplicateDepartmentNamesArray containsObject:dept.departmentName]) {
                            
                            departmentLabel.text = [NSString stringWithFormat:@"%@ (%@)",dept.departmentName,dept.Id];
                        }
                        else
                        departmentLabel.text = dept.departmentName;
               

            }
    
    if ([dept.Id isEqualToString:self.audioDetails.department.Id])
    {
        [radioButton setBackgroundImage:[UIImage imageNamed:@"RadioButton"] forState:UIControlStateNormal];
    }
    else
        [radioButton setBackgroundImage:[UIImage imageNamed:@"RadioButtonClear"] forState:UIControlStateNormal];
    
    [cell addSubview:radioButton];
    
    [cell addSubview:departmentLabel];
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    cell=[tableView cellForRowAtIndexPath:indexPath];
    
    UILabel* departmentNameLanel= [cell viewWithTag:200];
    
    if ([departmentNameLanel.text containsString:@"(INACTIVE)"])
    {
        [tableView reloadData];
        
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:DEACTIVATE_DEPARTMENT_MESSAGE withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
        
        return;
    }
    
    UIButton* radioButton=[cell viewWithTag:100];
    
    DepartMent *deptObj = [departmentObjectArray objectAtIndex:indexPath.row];
    
    self.audioDetails.department = deptObj;
    
    
    [radioButton setBackgroundImage:[UIImage imageNamed:@"RadioButton"] forState:UIControlStateNormal];
    
    [tableView reloadData];
    
}

-(void)cancel:(id)sender
{
    ////    NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
    ////
    ////    DepartMent *deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
    //
    //    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME_COPY];
    //
    ////    DepartMent *deptObj1 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //
    //    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SELECTED_DEPARTMENT_NAME];
        
    self.audioDetails.department = self.audioDetails.departmentCopy;
    
    [popupView removeFromSuperview];
}

-(void)save:(id)sender
{
    
    NSString* departmentName = self.audioDetails.department.departmentName;
    
    if ([departmentName containsString:@"Unassigned"]) {
        
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:SELECT_DEPARTMENT_MESSAGE withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
        
        [popupView removeFromSuperview];
        return;
    }
    
//    NSString* departmentId = [[Database shareddatabase] getDepartMentIdFromDepartmentName:departmentName];
    NSString* departmentId = self.audioDetails.department.Id;

    
    if ([[AppPreferences sharedAppPreferences].inActiveDepartmentIdsArray containsObject:departmentId])
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:DEACTIVATE_DEPARTMENT_MESSAGE withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
        
        return;
    }
    
    UILabel* transferredByLabel= [self.view viewWithTag:503];
    
    transferredByLabel.text = departmentName;
    
    UILabel* filenameLabel=[self.view viewWithTag:501];
    
    
    
    //    if (![self.selectedView isEqualToString:@"Transferred Today"])
    //    {
    [[Database shareddatabase] updateDepartment:departmentId fileName:filenameLabel.text];
    //    }
    
    
    
    self.audioDetails.departmentCopy = self.audioDetails.department;
    
    self.audioDetails.templateName = @"Select Template";
    
    [self getTempliatFromDepartMentName:departmentId];
    
    if(![self.audioDetails.deleteStatus isEqualToString:@"Deleted"]){
        templateNamesDropdownMenu.userInteractionEnabled = true;
    }
    
    recentlySelectedTemplateName = nil;
    
    [self setDefaultTemplate];
    
    [templateNamesDropdownMenu reloadAllComponents];
    
    
    [self.delegate myClassDelegateMethod:nil];
    
    [popupView removeFromSuperview];
    
}



-(void)hideTableView
{
    
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:504] removeFromSuperview];//
    
}
- (IBAction)editRecordingButtonPressed:(id)sender
{
    
    [self showEditRecordingView];
    
}

-(void)showEditRecordingView
{
    
    int audioHour= [self.audioDetails.currentDuration intValue]/(60*60);
    
    int audioHourByMod= [self.audioDetails.currentDuration intValue]%(60*60);
    
    int audioMinutes = audioHourByMod / 60;
    
    int audioSeconds = audioHourByMod % 60;
    
    NSString* audioDuration = [NSString stringWithFormat:@"%02d:%02d:%02d",audioHour,audioMinutes,audioSeconds];
    
    InCompleteRecordViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InCompleteRecordViewController"];
    
    vc.existingAudioFileName= self.audioDetails.fileName;
    
    vc.audioDuration = audioDuration;
    
    NSString* dataAndTime = self.audioDetails.recordingDate;
    
    NSArray* dateAndTimeArray = [dataAndTime componentsSeparatedByString:@" "];
    
    if (dateAndTimeArray.count>0)
    {
        
        vc.existingAudioDate = [dateAndTimeArray objectAtIndex:0];
        
    }
    
    int audioDurationSeconds = [self.audioDetails.currentDuration intValue];
    
    //int roundUpAudioDurationSeconds = ceil(audioDurationSeconds);
    
    vc.audioDurationInSeconds = audioDurationSeconds;
    
    vc.existingAudioDepartment= self.audioDetails.department;
    vc.existingAudioTemplateName = selectedTemplateName;
    vc.existingAudioComment = self.commentLabel.text;
    self.audioDetails.templateName = selectedTemplateName;
    [self updateTemplateIdForFileName];
    
    vc.isOpenedFromAudioDetails = YES;
    
    vc.selectedRowOfAwaitingList = self.selectedRow;
    
   
    if (checkBoxSelected)
       {
            vc.existingAudioPriorityId = [NSString stringWithFormat:@"%d", URGENT];
           self.audioDetails.priorityId = @"1";
           [[Database shareddatabase] updatePriority:[NSString stringWithFormat:@"%d", URGENT] fileName:self.audioDetails.fileName];
       }
       else
       {
           vc.existingAudioPriorityId = [NSString stringWithFormat:@"%d", NORMAL];
           self.audioDetails.priorityId = @"0";
           [[Database shareddatabase] updatePriority:[NSString stringWithFormat:@"%d", NORMAL] fileName:self.audioDetails.fileName];
       }
    vc.delegate = self;
    
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController:vc animated:YES completion:nil];
    
}

-(void)updateData:(NSDictionary *)delegateDict
{
    NSString* departmentName = [delegateDict objectForKey:@"DepartmentName"];
    NSString* tempName = [delegateDict objectForKey:@"TemplateName"];
    NSString* priorityId = [delegateDict objectForKey:@"PriorityId"];
    NSString* comment = [delegateDict objectForKey:@"Comment"];

    if (!(departmentName == nil))
    {
        self.audioDetails.department.departmentName = departmentName;
    }
    
    if (!(tempName == nil))
    {
        self.audioDetails.templateName = tempName;
        selectedTemplateName = tempName;
    }
    
    if (!(priorityId == nil))
    {
        self.audioDetails.priorityId = priorityId;
        
        if ([priorityId isEqualToString:[NSString stringWithFormat:@"%d", URGENT]])
        {
            self.urgentCheckBoxImageView.image = [UIImage imageNamed:@"CheckBoxSelected"];
            
            checkBoxSelected = true;
        }
        else
        {
            self.urgentCheckBoxImageView.image = [UIImage imageNamed:@"CheckBoxUnSelected"];
            
            checkBoxSelected = false;
        }
    }
    
    if (!(comment == nil))
       {
           self.audioDetails.comment = comment;
           
           if ([comment isEqualToString:@""]) {
               self.commentLabel.text = @"Add Comment";
           }
           else
           self.commentLabel.text = comment;
       }
    
}


#pragma Mark: Dropdwon Menu Datasource and Delegate




- (NSInteger)numberOfComponentsInDropdownMenu:(MKDropdownMenu *)dropdownMenu
{
    return 1;
}

- (NSInteger)dropdownMenu:(MKDropdownMenu *)dropdownMenu numberOfRowsInComponent:(NSInteger)component
{
    return templateNamesArray.count;
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForComponent:(NSInteger)component
{
    
    return [[NSAttributedString alloc] initWithString:selectedTemplateName
                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold],
                                                        NSForegroundColorAttributeName: [UIColor blackColor]}];
}

-(NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[NSAttributedString alloc] initWithString:[templateNamesArray objectAtIndex:row]
                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightLight],
                                                        NSForegroundColorAttributeName: [UIColor blackColor]}];
}

//- (NSString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//
//    return [templateNamesArray objectAtIndex:row];
//}

-(void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didOpenComponent:(NSInteger)component
{
    selectedTemplateName = @"Select Template";
    
    [self.scrollView setScrollEnabled:false];
    //    [self dropdownMenu:dropdownMenu attributedTitleForComponent:0];
    
    [dropdownMenu reloadAllComponents];
}


-(void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didCloseComponent:(NSInteger)component
{
    
    [self.scrollView setScrollEnabled:true];
    
    if ([selectedTemplateName isEqualToString:@"Select Template"] && recentlySelectedTemplateName!=nil)
    {
        //        [[Database shareddatabase] updateTemplateId:@"-1" fileName:self.recordedAudioFileName];
        
        [self setRecentlySelectedTemplate];
        
        [dropdownMenu reloadAllComponents];
    }
    else
        if([selectedTemplateName isEqualToString:@"Select Template"])
        {
            [self setDefaultTemplate];
            
            [dropdownMenu reloadAllComponents];
        }
    
    //    if ([selectedTemplateName isEqualToString:@"Select Template"])
    //    {
    //        [[Database shareddatabase] updateTemplateId:@"-1" fileName:self.audioDetails.fileName];
    //    }
}
-(void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedTemplateName = [templateNamesArray objectAtIndex:row];
    
    //    [dropdownMenu setSelectedComponentBackgroundColor:[UIColor lightGrayColor]];
    recentlySelectedTemplateName = selectedTemplateName;
    
    [dropdownMenu closeAllComponentsAnimated:YES];
    
    [dropdownMenu reloadAllComponents];
    
}


-(void)updateTemplateIdForFileName
{
    NSString* templateId = [[AppPreferences sharedAppPreferences].tempalateListDict objectForKey:selectedTemplateName];
    
    if (templateId == nil && [selectedTemplateName isEqualToString:@"Select Template"])//template was stored in db bt department unassigned later
    {
        templateId = @"-1";
    }
    
//    if (templateId == nil && ![self.audioDetails.department containsString:@"Unassigned"])//template was stored in db bt department unassigned later
//       {
//           templateId = @"-1";
//       }
    else
    if (templateId == nil || [self.audioDetails.department.departmentName containsString:@"Unassigned"]) {
       // tempId = nill hence template is deleted || if dept is unassigned then no template key value will be available hence fetch existing code
       templateId = [[Database shareddatabase] getTemplateIdFromFilename:self.audioDetails.fileName];
//        templateId = selectedTemplateName;
    }
    
    
    [[Database shareddatabase] updateTemplateId:templateId fileName:self.audioDetails.fileName];
}

-(void)setDefaultTemplate
{
    NSString* departmentId = [[Database shareddatabase] getDepartMentIdFromDepartmentName:self.audioDetails.department.departmentName];
    
    
    NSString* defaultTemplateName = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@DefaultTemplate",departmentId]];
    
    
    if (!(defaultTemplateName == nil || [defaultTemplateName isEqualToString:@""]))
    {
        selectedTemplateName = defaultTemplateName;
    }
    else
        selectedTemplateName = @"Select Template";
    
    //       if (![self.selectedView isEqualToString:@"Transferred Today"])
    //       {
    [self updateTemplateIdForFileName];
    //       }
    
    
}
-(void)setRecentlySelectedTemplate
{
    selectedTemplateName = recentlySelectedTemplateName;
    
//    [self updateTemplateIdForFileName];
}

- (IBAction)urgentCheckBoxButtonClicked:(id)sender
{
    if (checkBoxSelected)
    {
        self.urgentCheckBoxImageView.image = [UIImage imageNamed:@"CheckBoxUnSelected"];
        
        checkBoxSelected = false;
        
        self.audioDetails.priorityId = @"0";
        //        if (![self.selectedView isEqualToString:@"Transferred Today"]) // should not get updated for transferred today
        //        {
        //            [[Database shareddatabase] updatePriority:[NSString stringWithFormat:@"%d", NORMAL] fileName:self.audioDetails.fileName];
        //
        //        }
    }
    else
    {
        self.urgentCheckBoxImageView.image = [UIImage imageNamed:@"CheckBoxSelected"];
        
        checkBoxSelected = true;
        
        self.audioDetails.priorityId = @"1";
        //        if (![self.selectedView isEqualToString:@"Transferred Today"])
        //        {
        //            [[Database shareddatabase] updatePriority:[NSString stringWithFormat:@"%d", URGENT] fileName:self.audioDetails.fileName];
        //
        //        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if (textView.text.length == 255 && !([text length] == 0 && range.length > 0)) {
        
           [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:@"You have reached the maximum comment length to be entered" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
           
           return NO;
                                   
       }
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}

- (IBAction)commentButtonClicked:(id)sender {
    
    [self showCommentTextView];
    
}

-(void)showCommentTextView
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add Comment"
                                                                                message:@"\n\n\n\n\n\n\n\n"
                                                                         preferredStyle:UIAlertControllerStyleAlert];

      

       alertController.view.autoresizesSubviews = YES;
       __block UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
       textView.delegate = self;
       textView.translatesAutoresizingMaskIntoConstraints = NO;
       textView.autocorrectionType = UITextAutocorrectionTypeNo;
       textView.editable = YES;
       textView.returnKeyType = UIReturnKeyDone;
       textView.dataDetectorTypes = UIDataDetectorTypeAll;
       
    UIAlertAction* okay = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action) {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
            
            if (textView.text.length>255) {
                [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:@"You have reached the maximum comment length to be entered" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
                
                return ;
            }
            
           NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
            if ([textView.text isEqualToString:@""]) {
                self.commentLabel.text = @"Add Comment";
                self.audioDetails.comment = @"";
                
                [[Database shareddatabase] updateComment:@"" fileName:self.audioDetails.fileName];
            }
            else
            if ([[textView.text stringByTrimmingCharactersInSet: set] length] == 0)
            {
                [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:@"Comment can't contain only white spaces" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
            }
            else{
                self.commentLabel.text = textView.text;
                           
                self.audioDetails.comment = self.commentLabel.text;
                
                [[Database shareddatabase] updateComment:self.commentLabel.text fileName:self.audioDetails.fileName];
            }
           
        });
    }];
          UIAlertAction* cancel1 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alertController dismissViewControllerAnimated:YES completion:nil];
                                                         }];
          [alertController addAction:okay];
          [alertController addAction:cancel1];
       
       if (self.commentLabel.text == nil || [self.commentLabel.text isEqualToString:@""] || [self.commentLabel.text isEqualToString:@"Add Comment"]) {

       }
       else
       {
           textView.text =  self.commentLabel.text;
       }
       
       textView.userInteractionEnabled = YES;
       textView.backgroundColor = [UIColor whiteColor];
       textView.scrollEnabled = YES;
       NSLayoutConstraint *leadConstraint = [NSLayoutConstraint constraintWithItem:alertController.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:textView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-8.0];
       NSLayoutConstraint *trailConstraint = [NSLayoutConstraint constraintWithItem:alertController.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:textView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:8.0];

       NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:alertController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:textView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-64.0];
       NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:alertController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:textView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:64.0];
       [alertController.view addSubview:textView];
       [NSLayoutConstraint activateConstraints:@[leadConstraint, trailConstraint, topConstraint, bottomConstraint]];

       [self presentViewController:alertController animated:YES completion:^{

       }];
       

}
@end
