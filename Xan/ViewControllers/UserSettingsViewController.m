//
//  UserSettingsViewController.m
//  Cube
//
//  Created by mac on 29/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "UserSettingsViewController.h"
#import "SwitchCreation.h"
#import "PopUpCustomView.h"
#import <StoreKit/SKStoreProductViewController.h>

@interface UserSettingsViewController ()<SKStoreProductViewControllerDelegate>

@end

@implementation UserSettingsViewController
@synthesize poUpTableView;
@synthesize userSettingsTableView;
- (void)viewDidLoad
{
    [super viewDidLoad];
   
    poUpTableView.layer.cornerRadius=2.0f;
    _versionUpdateButton.layer.cornerRadius = 4.0f;
    app = [AppPreferences sharedAppPreferences];
//
    recordSettingsItemsarray=[[NSMutableArray alloc]initWithObjects:@"Pause recording after",@"Confirm before saving",@"Alert before recording",@"Back to home after dictation",@"Login everytime coming from background", nil];
    //@"Login everytime when app opens"
    storageManagementItemsArray=[[NSMutableArray alloc]initWithObjects:@"Low storage threshold",@"Purge deleted and transferred data by", nil];

    PlaybackAutoRewindByArray=[[NSMutableArray alloc]initWithObjects:@"Change your pin", nil];

    popUpOptionsArray=[[NSMutableArray alloc]init];
    radioButtonArray=[[NSMutableArray alloc]init];
   
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [[self.view viewWithTag:112] setHidden:YES];
    abbreviationPopupView.tag=121;
    tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(disMissPopView:)];
    tap.delegate=self;
    [[self.view viewWithTag:112] addGestureRecognizer:tap];
    
    tap1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(disMissPopView:)];
    tap1.delegate=self;
    
    self.navigationItem.title=@"User Settings";
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
    
   
    
//    if (app.isUpdateAvailable) {
//
//        [_versionUpdateButton setHidden:NO];
//    }
//    else
//    {
//         _versionLabelXConstraint.constant = 0;// make it center to view
//        [self.view addConstraint:_versionLabelXConstraint];
//         [_versionUpdateButton setHidden:YES];
//    }
  
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
       
       NSString* bundleVersion = infoDictionary[@"CFBundleShortVersionString"];
       
       [[NSUserDefaults standardUserDefaults] setValue:bundleVersion forKey:CURRENT_VESRION];
    
    NSString* currentVersion = [[NSUserDefaults standardUserDefaults] valueForKey:CURRENT_VESRION];
       
       _versionLabel.text = [NSString stringWithFormat:@"V %@",currentVersion];
    
    if (app.isReachable) {
              [self checkCurrentVersion];
         }
         else
         {
             _versionLabelXConstraint.constant = 0;// make it center to view
             [self.view addConstraint:_versionLabelXConstraint];
             [_versionUpdateButton setHidden:YES];
         }
  
    
}

-(void)viewDidAppear:(BOOL)animated
{
   
}

-(void)viewWillDisappear:(BOOL)animated
{
 //[APIManager sharedManager].userSettingsOpened=NO;
    [APIManager sharedManager].userSettingsClosed=YES;
}
-(void)popViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //NSLog(@"section");
    if ([tableView isEqual:self.poUpTableView])
    {
        return 1;
    }
    else
        return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //    NSLog(@"viewforHeader");
    
    if ([tableView isEqual:self.userSettingsTableView])
    {
        
        UIView* sectionHeaderView=[[UIView alloc]initWithFrame:CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, 60)];
        sectionHeaderView.backgroundColor=[UIColor colorWithRed:214/255.0 green:214/255.0 blue:226/255.0 alpha:1];
        
        UILabel* sectionTitleLabel=[[UILabel alloc]initWithFrame:CGRectMake(16, 20, tableView.frame.size.width*0.9, 17)];
        [sectionTitleLabel setTextColor:[UIColor blackColor]];
        [sectionTitleLabel setFont:[UIFont systemFontOfSize:16.0]];
        [sectionHeaderView addSubview:sectionTitleLabel];
        
        //for upper undeline view of section
        if (section!=0)
        {
            UIView* lineView=[[UIView alloc]initWithFrame:CGRectMake(tableView.frame.origin.x, 0, tableView.frame.size.width, 1)];
            lineView.backgroundColor=[UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1];
            [sectionHeaderView addSubview:lineView];
        }
        
        //for lower underline view of section
        UIView* lineView1=[[UIView alloc]initWithFrame:CGRectMake(tableView.frame.origin.x, 60, tableView.frame.size.width, 1)];
        lineView1.backgroundColor=[UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1];
        [sectionHeaderView addSubview:lineView1];
        
        if (section==0)
        {
            sectionTitleLabel.text=@"Record Settings";
            return sectionHeaderView;
        }
        else
            if (section==1)
            {
                sectionTitleLabel.text=@"Storage Management";
                return sectionHeaderView;
            }
            else
                if (section==2)
                {
                    sectionTitleLabel.text=@"Account Settings";
                    return sectionHeaderView;
                }
                else
                    return sectionHeaderView;
    }
    else
    {
        UIView* sectionHeaderView=[[UIView alloc]initWithFrame:CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, 60)];
        UILabel* sectionTitleBackgroundLabelLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
        sectionTitleBackgroundLabelLabel.backgroundColor=[UIColor whiteColor];

        UILabel* sectionTitleLabel=[[UILabel alloc]initWithFrame:CGRectMake(16, 20, tableView.frame.size.width, 17)];
        //sectionTitleLabel.backgroundColor=[UIColor whiteColor];
        [sectionTitleLabel setTextColor:[UIColor blackColor]];
        [sectionTitleLabel setFont:[UIFont systemFontOfSize:16.0]];
        UIFont *currentFont = sectionTitleLabel.font;
        UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",currentFont.fontName] size:currentFont.pointSize];
        sectionTitleLabel.font = newFont;
        [sectionHeaderView addSubview:sectionTitleBackgroundLabelLabel];

        [sectionHeaderView addSubview:sectionTitleLabel];

        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedRowAndSection"] isEqualToString:@"00"])
        {
            sectionTitleLabel.text=@"Select Time";
        }
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedRowAndSection"] isEqualToString:@"04"])
        {
            sectionTitleLabel.text=@"";
        }
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedRowAndSection"] isEqualToString:@"10"])
        {
            sectionTitleLabel.text=@"Select Low Storage Threshold";
        }
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedRowAndSection"] isEqualToString:@"11"])
        {
            sectionTitleLabel.text=@"Set Number Of Days";
        }
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedRowAndSection"] isEqualToString:@"20"])
        {
            sectionTitleLabel.text=@"";
        }
        
        return sectionHeaderView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    if ([tableView isEqual:poUpTableView])
    {
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedRowAndSection"] isEqualToString:@"10"] || [[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedRowAndSection"] isEqualToString:@"11"])
        {
            return 40;
        }
        else
            return 50;
    }
    else
        return 60;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:poUpTableView])
    {
        return 40;
    }
    else
        return 50;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if ([tableView isEqual:self.userSettingsTableView])
    {
        
        if (section==0)
        {
            return recordSettingsItemsarray.count;
        }
        else
            if (section==1)
            {
                return storageManagementItemsArray.count;
            }
            else
                if (section==2)
                {
                    return PlaybackAutoRewindByArray.count;
                }
                else
                    return 0;
    }
    else
        return popUpOptionsArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableview isEqual:self.userSettingsTableView])
    {
        UITableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.tag=indexPath.row;
        if (indexPath.section==0)
        {
            UILabel* nameLabel= [cell viewWithTag:101];
            nameLabel.text=[recordSettingsItemsarray objectAtIndex:indexPath.row];
            [nameLabel setTextColor:[UIColor blackColor]];
            if (indexPath.row!=0)
            {
                SwitchCreation* switchobj=[SwitchCreation new];
                switchobj.tableview=tableview;
                switchobj.cell=cell;
                switchobj.label=nameLabel;
                [self performSelector:@selector(createSwitch:) withObject:switchobj afterDelay:0.0];
                
            }
            
            
        }
        //CGRectMake(self.view.frame.origin.x+10, self.view.frame.origin.y+20, self.view.frame.size.width-40, 200)
        //to remove underline of last row of section so that scetion view underline does not ger override
        if (indexPath.section==0 && indexPath.row==recordSettingsItemsarray.count-1)
        {
            UIView* vw=[cell viewWithTag:102];
            [vw removeFromSuperview];
        }
        if (indexPath.section==1 && indexPath.row==storageManagementItemsArray.count-1)
        {
            UIView* vw=[cell viewWithTag:102];
            [vw removeFromSuperview];
        }
        if (indexPath.section==1)
        {
            UILabel* nameLabel= [cell viewWithTag:101];
            nameLabel.text=[storageManagementItemsArray objectAtIndex:indexPath.row];
            [nameLabel setTextColor:[UIColor blackColor]];
        }
        if (indexPath.section==2)
        {
            UILabel* nameLabel= [cell viewWithTag:101];
            nameLabel.text=[PlaybackAutoRewindByArray objectAtIndex:indexPath.row];
            [nameLabel setTextColor:[UIColor blackColor]];
        }
        
        return cell;
    }
    else
    {
        UITableViewCell *cell1 = [tableview dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
        UILabel* selectOptionLabel= [cell1 viewWithTag:114];
        selectOptionLabel.text=[popUpOptionsArray objectAtIndex:indexPath.row];
        [selectOptionLabel setTextColor:[UIColor blackColor]];

        if (radioButtonArray.count==0)
        {
            UIButton* button=[[UIButton alloc]initWithFrame:CGRectMake(10, 10, 19, 19)];
            [button setBackgroundColor:[UIColor clearColor]];
            [button setBackgroundImage:[UIImage imageNamed:@"RadioButtonClear"] forState:UIControlStateNormal];
            
            UIButton* button1=[[UIButton alloc]initWithFrame:CGRectMake(10, 10, 19, 19)];
            [button1 setBackgroundColor:[UIColor clearColor]];
            [button1 setBackgroundImage:[UIImage imageNamed:@"RadioButtonClear"] forState:UIControlStateNormal];
            
            UIButton* button2=[[UIButton alloc]initWithFrame:CGRectMake(10, 10, 19, 19)];
             [button2 setBackgroundColor:[UIColor clearColor]];
            [button2 setBackgroundImage:[UIImage imageNamed:@"RadioButtonClear"] forState:UIControlStateNormal];
            
            UIButton* button3=[[UIButton alloc]initWithFrame:CGRectMake(10, 10, 19, 19)];
            [button3 setBackgroundColor:[UIColor clearColor]];
            [button3 setBackgroundImage:[UIImage imageNamed:@"RadioButtonClear"] forState:UIControlStateNormal];
            radioButtonArray=[NSMutableArray arrayWithObjects:button,button1,button2,button3, nil];
            
            
            
        }
        
        
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedRowAndSection"] isEqualToString:@"00"])
        {
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:SAVE_DICTATION_WAITING_SETTING] isEqualToString:selectOptionLabel.text])
            {
                UIButton* button=[[UIButton alloc]initWithFrame:CGRectMake(10, 10, 19, 19)];
                [button setBackgroundImage:[UIImage imageNamed:@"RadioButton"] forState:UIControlStateNormal];
                [radioButtonArray replaceObjectAtIndex:indexPath.row withObject:button];
            }
            
            
            [cell1 addSubview:[radioButtonArray objectAtIndex:indexPath.row]];
            
        }
        
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedRowAndSection"] isEqualToString:@"10"])
        {
//            NSString* lowSto =  [[NSUserDefaults standardUserDefaults] valueForKey:LOW_STORAGE_THRESHOLD];
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:LOW_STORAGE_THRESHOLD] isEqualToString:selectOptionLabel.text])
            {
                UIButton* button=[[UIButton alloc]initWithFrame:CGRectMake(10, 10, 19, 19)];
                [button setBackgroundImage:[UIImage imageNamed:@"RadioButton"] forState:UIControlStateNormal];
                [radioButtonArray replaceObjectAtIndex:indexPath.row withObject:button];
            }
            
            [cell1 addSubview:[radioButtonArray objectAtIndex:indexPath.row]];
            
            
        }
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedRowAndSection"] isEqualToString:@"11"])
        {
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:PURGE_DELETED_DATA] isEqualToString:selectOptionLabel.text])
            {
                UIButton* button=[[UIButton alloc]initWithFrame:CGRectMake(10, 10, 19, 19)];
                [button setBackgroundImage:[UIImage imageNamed:@"RadioButton"] forState:UIControlStateNormal];
                [radioButtonArray replaceObjectAtIndex:indexPath.row withObject:button];
            }
            
            
            [cell1 addSubview:[radioButtonArray objectAtIndex:indexPath.row]];
            
            
        }
        
        //selectOptionLabel.text=@"asdssdjkkjjkjkiloljlklkkkjklkljkljkljkljkl";
        return cell1;
    }
}

-(void)createSwitch:(SwitchCreation*)sender
{
    BOOL flag=false;
    for (UIView* subview in sender.cell.subviews)
    {
        if ([subview isKindOfClass:[UISwitch class]])
        {
            flag=true;
        }
    }
    
    if (flag==false)
    {
        UISwitch *onoff = [[UISwitch alloc] initWithFrame: CGRectMake(sender.tableview.frame.size.width-80,sender.label.frame.origin.y-7, 0, 0)];
        onoff.tag=sender.cell.tag;
        if (onoff.tag==1)
        {
            [onoff setOn:[[NSUserDefaults standardUserDefaults] boolForKey:CONFIRM_BEFORE_SAVING_SETTING]];
        }

        if (onoff.tag==2)
        {
            [onoff setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ALERT_BEFORE_RECORDING]];
        }
        if (onoff.tag==3)
        {
            [onoff setOn:[[NSUserDefaults standardUserDefaults] boolForKey:BACK_TO_HOME_AFTER_DICTATION]];
        }
        if (onoff.tag==4)
        {
            [onoff setOn:[[NSUserDefaults standardUserDefaults] boolForKey:LOGIN_EVERYTIME]];
        }
      
        [onoff addTarget: self action: @selector(flip:) forControlEvents:UIControlEventValueChanged];
        [sender.cell addSubview:onoff];
    }
    
}

-(void)flip:(UISwitch*)sender
{
    if (sender.tag==1)
    {
        bool confirmBeforeSaving=sender.isOn;
        [[NSUserDefaults standardUserDefaults] setBool:confirmBeforeSaving forKey:CONFIRM_BEFORE_SAVING_SETTING];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CONFIRM_BEFORE_SAVING_SETTING_ALTERED];

    }
    if (sender.tag==2)
    {
        bool alertBeforeSaving=sender.isOn;
        [[NSUserDefaults standardUserDefaults] setBool:alertBeforeSaving forKey:ALERT_BEFORE_RECORDING];

    }
    if (sender.tag==3)
    {
        bool backToHomeAfterDictation=sender.isOn;
        [[NSUserDefaults standardUserDefaults] setBool:backToHomeAfterDictation forKey:BACK_TO_HOME_AFTER_DICTATION];

    }
    if (sender.tag==4)
    {
        bool backToHomeAfterDictation=sender.isOn;
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LOGIN_EVERYTIME_SETTING_ALTERED];

        [[NSUserDefaults standardUserDefaults] setBool:backToHomeAfterDictation forKey:LOGIN_EVERYTIME];

    }
    //NSLog(@"%ld",sender.tag);
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:userSettingsTableView])
    {
        
        
        if ((indexPath.section==0 && indexPath.row==0) || indexPath.section==1)
        {
            [[[[UIApplication sharedApplication] keyWindow] viewWithTag:112] setHidden:NO];
            
            [[self.view viewWithTag:112] setFrame:[[UIScreen mainScreen] bounds]];
            
            [[self.view viewWithTag:112] setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
            
            if (indexPath.section==0)
            {
                if (indexPath.row==0)
                {
                    popUpOptionsArray=nil;
                    popUpOptionsArray=[[NSMutableArray alloc]initWithObjects:@"15 min",@"30 min",@"40 min", nil];
                    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld%ld",indexPath.section,indexPath.row] forKey:@"selectedRowAndSection"];
                    [self.poUpTableView reloadData];
                }
                
            }
            if (indexPath.section==1)
            {
                if (indexPath.row==0)
                {
                    popUpOptionsArray=nil;
                    popUpOptionsArray=[[NSMutableArray alloc]initWithObjects:@"512 MB",@"1 GB",@"2 GB",@"3 GB", nil];
                    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld%ld",indexPath.section,indexPath.row] forKey:@"selectedRowAndSection"];
                    [self.poUpTableView reloadData];
                }
                if (indexPath.row==1)
                {
                    popUpOptionsArray=nil;
                    popUpOptionsArray=[[NSMutableArray alloc]initWithObjects:@"Do not purge",@"15 days",@"30 days",@"90 days", nil];
                    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld%ld",indexPath.section,indexPath.row] forKey:@"selectedRowAndSection"];
                    
                    // we have removed 20 days option from settings, since if user had selected 20 days option and it has been stored in defaults. tableview will not show the 20 days. hence we are setting default
                    
                    bool isDayStore = false;
                    for (int i = 0; i < popUpOptionsArray.count; i++)
                    {
                       NSString* selectedDays = [[NSUserDefaults standardUserDefaults] valueForKey:PURGE_DELETED_DATA];
                       NSString* daysOption = [popUpOptionsArray objectAtIndex:i];
                        if (selectedDays == daysOption)
                        {
                            isDayStore = true;
                        }

                    }
                    
                    if (!isDayStore)
                    {
                        [[NSUserDefaults standardUserDefaults] setValue:@"15 days" forKey:PURGE_DELETED_DATA];

                    }
                    [self.poUpTableView reloadData];
                    
                }
            }
            
        }
        
//        if (indexPath.section==0 && indexPath.row==4)
//        {
//
//            abbreviationPopupView=  [[PopUpCustomView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x+20, self.view.frame.origin.y+100, self.view.frame.size.width-40, 200) sender:self];
//            [abbreviationPopupView addGestureRecognizer:tap1];
//            abbreviationPopupView.tag=121;
//            [[[UIApplication sharedApplication] keyWindow] addSubview:abbreviationPopupView];
//
//        }
        if (indexPath.section==2 && indexPath.row==0)
        {
            UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;

            [self presentViewController:vc animated:YES completion:nil];
        }
    }
    
    else
    {
        [self.poUpTableView reloadData];
        UITableViewCell* selectedCell=   [tableView cellForRowAtIndexPath:indexPath];
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedRowAndSection"] isEqualToString:@"00"])
        {
            UILabel* timeLabel= [selectedCell viewWithTag:114];
            [timeLabel setTextColor:[UIColor blackColor]];
            [[NSUserDefaults standardUserDefaults] setValue:timeLabel.text forKey:SAVE_DICTATION_WAITING_SETTING];
            
            UIButton* button = [radioButtonArray objectAtIndex:indexPath.row];
            [button setBackgroundImage:[UIImage imageNamed:@"RadioButton"] forState:UIControlStateNormal];
            for (int i=0; i<radioButtonArray.count; i++)
            {
                if (i==indexPath.row)
                {
                    UIButton* button = [radioButtonArray objectAtIndex:indexPath.row];
                    [button setBackgroundImage:[UIImage imageNamed:@"RadioButton"] forState:UIControlStateNormal];
                    
                }
                else
                {
                    UIButton* button = [radioButtonArray objectAtIndex:i];
                    [button setBackgroundImage:[UIImage imageNamed:@"RadioButtonClear"] forState:UIControlStateNormal];
                    
                }
            }
            
            
        }
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedRowAndSection"] isEqualToString:@"10"])
        {
            UILabel* timeLabel= [selectedCell viewWithTag:114];
            [timeLabel setTextColor:[UIColor blackColor]];
            [[NSUserDefaults standardUserDefaults] setValue:timeLabel.text forKey:LOW_STORAGE_THRESHOLD];
            
            
            for (int i=0; i<radioButtonArray.count; i++)
            {
                if (i==indexPath.row)
                {
                    UIButton* button = [radioButtonArray objectAtIndex:indexPath.row];
                    [button setBackgroundImage:[UIImage imageNamed:@"RadioButton"] forState:UIControlStateNormal];
                    
                }
                else
                {
                    UIButton* button = [radioButtonArray objectAtIndex:i];
                    [button setBackgroundImage:[UIImage imageNamed:@"RadioButtonClear"] forState:UIControlStateNormal];
                    
                }
            }
        }
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedRowAndSection"] isEqualToString:@"11"])
        {
            UILabel* timeLabel= [selectedCell viewWithTag:114];
            [timeLabel setTextColor:[UIColor blackColor]];
            [[NSUserDefaults standardUserDefaults] setValue:timeLabel.text forKey:PURGE_DELETED_DATA];
            
            for (int i=0; i<radioButtonArray.count; i++)
            {
                if (i==indexPath.row)
                {
                    UIButton* button = [radioButtonArray objectAtIndex:indexPath.row];
                    [button setBackgroundImage:[UIImage imageNamed:@"RadioButton"] forState:UIControlStateNormal];
                    
                }
                else
                {
                    UIButton* button = [radioButtonArray objectAtIndex:i];
                    [button setBackgroundImage:[UIImage imageNamed:@"RadioButtonClear"] forState:UIControlStateNormal];
                    
                }
            }
            
        }
        [self performSelector:@selector(hideTableView) withObject:nil afterDelay:0.2];
        
    }
    
    
}

-(void)hideTableView
{
    radioButtonArray=nil;
    radioButtonArray=[[NSMutableArray alloc]init];
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:112] setHidden:YES];//
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.poUpTableView.superview != nil)
    {
        if ([touch.view isDescendantOfView:self.poUpTableView])
        {
            return NO;
        }
    }
    
    return YES; // handle the touch
}

-(void)disMissPopView:(id)sender
{
    
    radioButtonArray=nil;
    radioButtonArray=[[NSMutableArray alloc]init];
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:112] setHidden:YES];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancel:(id)sender
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:121] removeFromSuperview];
    
}

-(void)save:(id)sender
{
    UITextField* abbreviationTextfiled= [[[[UIApplication sharedApplication] keyWindow] viewWithTag:121] viewWithTag:122];
    if (abbreviationTextfiled.text.length==0)
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"MOB-" forKey:RECORD_ABBREVIATION];
        
    }
    if (abbreviationTextfiled.text.length>0)
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@-",abbreviationTextfiled.text] forKey:RECORD_ABBREVIATION];
        
    }
    //NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:RECORD_ABBREVIATION]);
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:121] removeFromSuperview];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 5;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(uint64_t)getFreeDiskspace {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        //        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        //NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalFreeSpace;
}

- (IBAction)backButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)versionUpdateButtonClicked:(id)sender {
//    [AppPreferences sharedAppPreferences].doOpeniTunesFromSettings = YES;
//    [self dismissViewControllerAnimated:true completion:nil];
    

           if ([AppPreferences sharedAppPreferences].isReachable)
           {
               [self addHud];
                              
               [self openStoreProductViewControllerWithITunesItemIdentifier:app.kAppITunesItemIdentifier];
           }
       
    
}

-(void)addHud
{
    hud.minSize = CGSizeMake(150.f, 100.f);
    hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"Connecting";
    hud.detailsLabel.text = @"Please wait";
}

-(void)changeButtonTitle:(NSString*)title
{
    if ([title isEqualToString:@"Checking for Update"]) {
        [self.versionUpdateButton setTitle:@"Checking for Update" forState:UIControlStateNormal];
        [self.versionUpdateButton setUserInteractionEnabled:NO];
    }
    else
        if ([title isEqualToString:@"Already upto Date"]) {
               [self.versionUpdateButton setTitle:@"Already upto Date" forState:UIControlStateNormal];
               [self.versionUpdateButton setUserInteractionEnabled:NO];
           }
    else
        if ([title isEqualToString:@"Update Available"]) {
                      [self.versionUpdateButton setTitle:@"Update Available" forState:UIControlStateNormal];
                      [self.versionUpdateButton setUserInteractionEnabled:YES];
                  }
}
-(void) checkCurrentVersion
{
    [self changeButtonTitle:@"Checking for Update"];
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    NSString* bundleVersion = infoDictionary[@"CFBundleShortVersionString"];
    
    [[NSUserDefaults standardUserDefaults] setValue:bundleVersion forKey:CURRENT_VESRION];
           
       NSString* appID = infoDictionary[@"CFBundleIdentifier"];
       
       NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/lookup?bundleId=%@", appID]];
       
       NSURLSession         *  session = [NSURLSession sharedSession];
       
       
       NSURLSessionDataTask *  theTask = [session dataTaskWithRequest: [NSURLRequest requestWithURL: url] completionHandler:
                                          ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                                          {
                                              NSDictionary* lookup = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                              
                                              if ([lookup[@"resultCount"] integerValue] == 1)
                                              {
                                                  
                                                  NSString* appStoreVersion = lookup[@"results"][0][@"version"];
                                                 
                                                  NSInteger kAppITunesItemIdentifier = [lookup[@"results"][0][@"trackId"] integerValue];

                                                  [AppPreferences sharedAppPreferences].kAppITunesItemIdentifier = kAppITunesItemIdentifier;
                                                  
                                                  NSString* currentVersion = infoDictionary[@"CFBundleShortVersionString"];
                                                 
                                                  if (![appStoreVersion isEqualToString:currentVersion])

                                                  {
                                                      dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                         [self changeButtonTitle:@"Update Available"];
                                                             });
//                                                      [AppPreferences sharedAppPreferences].isUpdateAvailable = true;
                                                  }
                                                  else
                                                  {
                                                      dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                      [self changeButtonTitle:@"Already upto Date"];
                                                          });
//                                                      [AppPreferences sharedAppPreferences].isUpdateAvailable = false;
                                                  }
                                              }
           else
           {
               dispatch_async(dispatch_get_main_queue(), ^(void) {
                    _versionLabelXConstraint.constant = 0;// make it center to view
                          [self.view addConstraint:_versionLabelXConstraint];
                          [_versionUpdateButton setHidden:YES];
                   });
           }
       }];
                                                  
    [theTask resume];
}
#pragma mark: SKStoreVC to check and open new update


- (void)openStoreProductViewControllerWithITunesItemIdentifier:(NSInteger)iTunesItemIdentifier {
    
    SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
     storeViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    storeViewController.delegate = self;
    
    NSNumber *identifier = [NSNumber numberWithInteger:iTunesItemIdentifier];
    
    NSDictionary *parameters = @{ SKStoreProductParameterITunesItemIdentifier:identifier };
   
    [storeViewController loadProductWithParameters:parameters
                                   completionBlock:^(BOOL result, NSError *error) {
                                       if (result)
                                       {
                                           UIViewController *topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                                               
                                               while (topRootViewController.presentedViewController)
                                               {
                                                   topRootViewController = topRootViewController.presentedViewController;
                                               }
                                               
                                           //    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                                               UIViewController *viewController = topRootViewController;
                                          
                                           dispatch_async(dispatch_get_main_queue(), ^(void) {
                                               [hud removeFromSuperview];
                                                  });
                                           
                                           [viewController presentViewController:storeViewController
                                             animated:YES
                                           completion:nil];
                                       }
                                       else{
                                           dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                                                         [hud removeFromSuperview];
                                                                                            });
                                       }
                                           
//                                       else NSLog(@"SKStoreProductViewController: %@", error);
                                   }];
    
}


- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}


@end
