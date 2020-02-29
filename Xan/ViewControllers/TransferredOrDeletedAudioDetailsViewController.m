//
//  TransferredOrDeletedAudioDetailsViewController.m
//  Cube
//
//  Created by mac on 29/08/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "TransferredOrDeletedAudioDetailsViewController.h"
#import "PopUpCustomView.h"
#import "Database.h"
#import "APIManager.h"
#import "AppPreferences.h"
#import "Constants.h"

#define IMPEDE_PLAYBACK NO

@interface TransferredOrDeletedAudioDetailsViewController ()
{
    AVAudioPlayer       *player;
}

@end

@implementation TransferredOrDeletedAudioDetailsViewController
@synthesize listSelected,selectedRow,resendButton,deleteDictationButton,moreButton;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pausePlayerFromBackGround) name:NOTIFICATION_PAUSE_AUDIO_PALYER
                                               object:nil];
   
    popupView=[[UIView alloc]init];
    
    forTableViewObj=[[PopUpCustomView alloc]init];

    [self.splitViewController setPreferredDisplayMode:UISplitViewControllerDisplayModeAllVisible];

    if (self.splitViewController == nil)
    {
        self.backImageView.hidden = false;
    }
    else
    if(self.splitViewController.isCollapsed == false)
    {
        self.backImageView.hidden = true;
    }

    [self setTemplateDropDown];

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
    resendButton.layer.cornerRadius=4.0f;
    deleteDictationButton.layer.cornerRadius=4.0f;
    
    moreButton.userInteractionEnabled=YES;
    
    [self setAudioDetails];


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
    
    NSString* dictatorName = [[NSUserDefaults standardUserDefaults] valueForKey:@"DictatorName"];
    
    self.dictatedByLabel.text = dictatorName;
    
    if (([self.audioDetails.templateName isEqualToString:@"-1"] || self.audioDetails.templateName == nil || [self.audioDetails.department containsString:@"(Deleted)"]) && selectedTemplateName == nil)
    {
        self.audioDetails.templateName = @"Select Template";
        selectedTemplateName = @"Select Template";
    }
    else
        if (selectedTemplateName == nil)
        {
            selectedTemplateName = self.audioDetails.templateName;
        }
    
    [self.mkDropdwonRefView addSubview:templateNamesDropdownMenu];
    
    NSString* deptName = self.audioDetails.department;
    
    NSString* deptId = [[Database shareddatabase] getDepartMentIdFromDepartmentName:deptName];
    
    [self getTempliatFromDepartMentName:deptId];
    
    [templateNamesDropdownMenu reloadAllComponents];
    
    UITapGestureRecognizer* tapGestureRecogniser = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(disMissTemplateDropDown:)];
    
    //    tapGestureRecogniser.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecogniser];
    
    if ([self.audioDetails.priorityId isEqualToString:[NSString stringWithFormat:@"%d",  URGENT]])
    {
        self.urgentCheckBoxImageView.image = [UIImage imageNamed:@"CheckBoxSelected"];
        
        checkBoxSelected = true;
    }
}

-(void)disMissTemplateDropDown:(UITapGestureRecognizer *)gestureRecognizer
{
    [templateNamesDropdownMenu closeAllComponentsAnimated:true];
    
}
-(void)setAudioDetails
{
    UILabel* filenameLabel=[self.view viewWithTag:501];
    //UILabel* dictatedByLabel=[self.view viewWithTag:502];
    UILabel* departmentLabel=[self.view viewWithTag:503];
    UILabel* dictatedOnLabel=[self.view viewWithTag:504];
    UILabel* transferStatusLabel=[self.view viewWithTag:505];
    UILabel* transferDateLabel=[self.view viewWithTag:506];
    
    // UILabel* transferDateLabel=[self.view viewWithTag:506];
    APIManager* app=[APIManager sharedManager];
    if (self.listSelected==0)
    {
     
        transferStatusLabel.text=[NSString stringWithFormat:@"Transferred"];//if selected list is Transferred then we have status=Transferred ,only fetch delete status append it to transferStatusLabel
        [resendButton setHidden:NO];
        [deleteDictationButton setHidden:NO];
        
    }
    if (self.listSelected==1)
    {
        [moreButton setUserInteractionEnabled:NO];
        [_mkDropdwonRefView setUserInteractionEnabled:NO];
        [self.urgentCheckboxButton setUserInteractionEnabled:NO];
        [resendButton setHidden:YES];
        [deleteDictationButton setHidden:YES];
        NSString* transferStatusString;
        if (app.deletedListArray.count > 0)
        {
            
            transferStatusString = self.audioDetails.uploadStatus;
            
            if ([transferStatusString isEqualToString:@"TransferFailed"])
            {
                self.transferDateTitleLabel.text = @"Transfer Failed Date";
                transferStatusString = @"Transfer Failed";
            }
            else if ([transferStatusString isEqualToString:@"NotTransferred"])
            {
                transferStatusString = @"Not Transferred";
                
            }
            else
            {
                transferStatusString = transferStatusString;
            }
        }
        
        if (transferStatusString == NULL)
        {
            transferStatusLabel.text=[NSString stringWithFormat:@"Deleted"];//if selected list is delete then we have status=deleted ,only fetch transfer status append it to transferStatusLabel

        }
        else
        transferStatusLabel.text=[NSString stringWithFormat:@"Deleted, %@",transferStatusString];//if selected list is delete then we have status=deleted ,only fetch transfer status append it to transferStatusLabel
        
        
    }
    
    NSString* departmentName = self.audioDetails.department;
    
    departmentLabel.text=departmentName;
    
    self.audioDetails.departmentCopy = departmentName;
  
    filenameLabel.text = self.audioDetails.fileName;
    
    dictatedOnLabel.text = self.audioDetails.recordingDate;
 
    NSString* dateStr = self.audioDetails.recordingDate;

    dictatedOnLabel.text = dateStr;
    
    NSString* transferDateString = self.audioDetails.transferDate;

    transferDateLabel.text = transferDateString;

}

- (IBAction)backButtonPressed:(id)sender
{
    [templateNamesDropdownMenu closeAllComponentsAnimated:true];
    
    [player stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playRecordingButtonPressed:(id)sender
{
    
    if (self.listSelected==1)
    {
        
        alertController = [UIAlertController alertControllerWithTitle:@"File does not exist"
                                                              message:@""
                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        actionCancel = [UIAlertAction actionWithTitle:@"Ok"
                                                style:UIAlertActionStyleCancel
                                              handler:^(UIAlertAction * action)
                        {
                            [alertController dismissViewControllerAnimated:YES completion:nil];
                            
                        }]; //You can use a block here to handle a press on this button
        [alertController addAction:actionCancel];
        [self presentViewController:alertController animated:YES completion:nil];

    }
    else
    {
        [templateNamesDropdownMenu closeAllComponentsAnimated:true];
        
        UIView * overlay=[[PopUpCustomView alloc]initWithFrame:CGRectMake(self.view.frame.size.width*0.05, self.view.center.y-40, self.view.frame.size.width*0.9, 80) senderNameForSlider:self player:player];
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:overlay];
        
        sliderPopUpView=  [overlay viewWithTag:223];
        audioRecordSlider=  [sliderPopUpView viewWithTag:224];
        
        UIImageView* pauseOrPlayImageView= [sliderPopUpView viewWithTag:226];
        UILabel* dateAndTimeLabel=[sliderPopUpView viewWithTag:225];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString* dateStr = self.audioDetails.recordingDate;
        NSDate *date = [dateFormatter dateFromString:dateStr];
        
        [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
        NSString *newDateString = [dateFormatter stringFromDate:date];
        
        dateAndTimeLabel.text = newDateString;
        pauseOrPlayImageView.image=[UIImage imageNamed:@"Pause"];
        NSString* filName = self.audioDetails.fileName;
        if (!IMPEDE_PLAYBACK)
        {
            [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryPlayback];
        }
        NSArray* pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   AUDIO_FILES_FOLDER_NAME,
                                   [NSString stringWithFormat:@"%@.wav", filName],
                                   nil];
        NSURL* recordedAudioURL = [NSURL fileURLWithPathComponents:pathComponents];
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
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    UIImageView* pauseOrImageView= [sliderPopUpView viewWithTag:226];
    pauseOrImageView.image=[UIImage imageNamed:@"Play"] ;
    
    [player stop];
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
    
    return YES; // handle the touch
}
-(void)dismissPopView:(id)sender
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    
    
}
-(void)updateSliderTime:(id)sender
{
    audioRecordSlider.value = player.currentTime;
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

- (IBAction)deleteRecordinfButtonPressed:(id)sender
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

                        BOOL delete= [app deleteFile:fileName];
                        
                        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                        {
                            [self.delegate myClassDelegateMethod:nil];
                        }
                        else
                        {
                            if (delete)
                            {
                                [self dismissViewControllerAnimated:YES completion:nil];
                            }
                        }
                        
                        
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

- (IBAction)resendButtonClckied:(id)sender
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        NSString* deptId = [[Database shareddatabase] getDepartMentIdFromDepartmentName:self.audioDetails.department];

               if ([[AppPreferences sharedAppPreferences].inActiveDepartmentIdsArray containsObject:deptId])
                       {
                           [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:DEACTIVATE_DEPARTMENT_MESSAGE withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
                           
                           return;
                       }
        
        moreButton.userInteractionEnabled=NO;

    alertController = [UIAlertController alertControllerWithTitle:RESEND_MESSAGE
                                                          message:@""
                                                   preferredStyle:UIAlertControllerStyleAlert];
    actionDelete = [UIAlertAction actionWithTitle:@"Yes"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action)
                    {
                        APIManager* app=[APIManager sharedManager];
//                       NSString* date= [app getDateAndTimeString];
                        NSString* date = @"NotApplicable";
                        
                        
                        NSString* filName = self.audioDetails.fileName;
                        [resendButton setHidden:YES];
                        [deleteDictationButton setHidden:YES];
                        
                        [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUpload" fileName:filName];
                                           int mobileDictationIdVal=[[Database shareddatabase] getMobileDictationIdFromFileName:filName];
                                           
                        [[Database shareddatabase] updateAudioFileUploadedStatus:@"Resend" fileName:filName dateAndTime:date mobiledictationidval:mobileDictationIdVal];
                        
                        if (checkBoxSelected)
                        {
                             [[Database shareddatabase] updatePriority:[NSString stringWithFormat:@"%d", URGENT] fileName:self.audioDetails.fileName];
                        }
                        else
                        {
                             [[Database shareddatabase] updatePriority:[NSString stringWithFormat:@"%d", NORMAL] fileName:self.audioDetails.fileName];
                        }
                       
                        
                        [templateNamesDropdownMenu setUserInteractionEnabled:false];
                        
                        [self.urgentCheckboxButton setUserInteractionEnabled:false];

                        [self updateTemplateIdForFileName];
                        
                        [self.delegate myClassDelegateMethod:nil];

                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            
                            [app uploadFileToServer:filName jobName:FILE_UPLOAD_API];
                           
                        });
                        
                    }];
    [alertController addAction:actionDelete];
    
    
    actionCancel = [UIAlertAction actionWithTitle:@"No"
                                            style:UIAlertActionStyleCancel
                                          handler:^(UIAlertAction * action)
                    {
                        [alertController dismissViewControllerAnimated:YES completion:nil];
                        
                    }];
    [alertController addAction:actionCancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}
else
{
    [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
}


}

- (IBAction)moreButtonClicked:(id)sender
{
    [templateNamesDropdownMenu closeAllComponentsAnimated:true];
    
    NSArray* subViewArray=[NSArray arrayWithObjects:@"Change Department", nil];
    UIView* pop=[[PopUpCustomView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x+self.view.frame.size.width-160, self.view.frame.origin.y+40, 160, 40) andSubViews:subViewArray :self];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:pop];
}

-(void)ChangeDepartment
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
-(void)cancel:(id)sender
{
    
    NSString* departmentName = self.audioDetails.departmentCopy;
    
    self.audioDetails.department = departmentName;
    
    [popupView removeFromSuperview];
}

-(void)save:(id)sender
{
   
    NSString* departmentName = self.audioDetails.department;
    
    UILabel* transferredByLabel= [self.view viewWithTag:503];
    
    transferredByLabel.text = departmentName;
    
    UILabel* filenameLabel=[self.view viewWithTag:501];
    
    NSString* departmentId = [[Database shareddatabase] getDepartMentIdFromDepartmentName:departmentName];
    
    [[Database shareddatabase] updateDepartment:departmentId fileName:filenameLabel.text];
    
    self.audioDetails.departmentCopy = departmentName;

//    selectedTemplateName = @"Select Template";
//
//    [[Database shareddatabase] updateTemplateId:@"-1" fileName:self.audioDetails.fileName];
    [self getTempliatFromDepartMentName:departmentId];

    [self setDefaultTemplate];
        
    [templateNamesDropdownMenu reloadAllComponents];
    
    [self.delegate myClassDelegateMethod:nil];
    
    [popupView removeFromSuperview];
    
}


#pragma mark:TableView Datasource and Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Database* db=[Database shareddatabase];
    departmentNamesArray=[db getDepartMentNames];
    return departmentNamesArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    cell = [tableview dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
   
    UILabel* departmentLabel=[[UILabel alloc]initWithFrame:CGRectMake(40, 10, self.view.frame.size.width - 60.0f, 18)];
    // Configure the cell...
    
    if ([cell viewWithTag:200] != nil)
    {
        [[cell viewWithTag:200] removeFromSuperview];
    }
    UIButton* radioButton=[[UIButton alloc]initWithFrame:CGRectMake(10, 10, 18, 18)];
    departmentLabel.text = [departmentNamesArray objectAtIndex:indexPath.row];
    departmentLabel.tag=200;
    radioButton.tag=100;
    
    NSString* departmentName = self.audioDetails.department;
    
    if ([departmentName isEqualToString:departmentLabel.text])
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
    
    UIButton* radioButton=[cell viewWithTag:100];
    
    DepartMent *deptObj = [[DepartMent alloc]init];
    
    NSString* deptId= [[Database shareddatabase] getDepartMentIdFromDepartmentName:departmentNameLanel.text];
    
    if ([[AppPreferences sharedAppPreferences].inActiveDepartmentIdsArray containsObject:deptId])
         {
             [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:DEACTIVATE_DEPARTMENT_MESSAGE withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
             
             return;
         }
    
    deptObj.Id = deptId;
    
    deptObj.departmentName=departmentNameLanel.text;
    
    self.audioDetails.department = departmentNameLanel.text;
        
    [radioButton setBackgroundImage:[UIImage imageNamed:@"RadioButton"] forState:UIControlStateNormal];
    
    [tableView reloadData];
    
}

-(void)hideTableView
{
    
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:504] removeFromSuperview];//
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

-(void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didOpenComponent:(NSInteger)component
{
    [self.scrollView setScrollEnabled:false];
    
    selectedTemplateName = @"Select Template";
    
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
    
    [dropdownMenu closeAllComponentsAnimated:YES];
    
    [dropdownMenu reloadAllComponents];
    
}


-(void)updateTemplateIdForFileName
{
    NSString* templateId = [[AppPreferences sharedAppPreferences].tempalateListDict objectForKey:selectedTemplateName];
    
    if (templateId == nil)
    {
        templateId = @"-1";
    }
    
    [[Database shareddatabase] updateTemplateId:templateId fileName:self.audioDetails.fileName];
}

-(void)setDefaultTemplate
{
//    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
//    DepartMent* deptObj = [[DepartMent alloc] init];
//    deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSString* departmentId = [[Database shareddatabase] getDepartMentIdFromDepartmentName:self.audioDetails.department];

    NSString* defaultTemplateName = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@DefaultTemplate",departmentId]];
    
    
    if (!(defaultTemplateName == nil || [defaultTemplateName isEqualToString:@""]))
    {
        selectedTemplateName = defaultTemplateName;
    }
    else
        selectedTemplateName = @"Select Template";
    
    [self updateTemplateIdForFileName];
}
-(void)setRecentlySelectedTemplate
{
    selectedTemplateName = recentlySelectedTemplateName;
    
    [self updateTemplateIdForFileName];
}

- (IBAction)urgentCheckBoxButtonClicked:(id)sender
{
    if (checkBoxSelected)
    {
        self.urgentCheckBoxImageView.image = [UIImage imageNamed:@"CheckBoxUnSelected"];
        
        checkBoxSelected = false;
    }
    else
    {
        self.urgentCheckBoxImageView.image = [UIImage imageNamed:@"CheckBoxSelected"];
        
        checkBoxSelected = true;
    }
}
@end
