//
//  ChangePasswordViewController.m
//  Cube
//
//  Created by mac on 11/08/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "MBProgressHUD.h"
#import "LoginViewController.h"
#import "Keychain.h"
#import "MainTabBarViewController.h"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController
@synthesize pinCode1TextField,pinCode2TextField,pinCode3TextField,pinCode4TextField,navigationBarView,pinCode5TextField,pinCode6TextField,pinCode7TextField,pinCode8TextField,submitButton,cancelButton,window,hud;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

-(void)viewWillAppear:(BOOL)animated
{
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    //[self setNeedsStatusBarAppearanceUpdate];

//    navigationBarView.backgroundColor=[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    [pinCode1TextField becomeFirstResponder];
    pinCode1TextField.delegate=self;
    pinCode2TextField.delegate=self;
    pinCode3TextField.delegate=self;
    pinCode4TextField.delegate=self;
    
    pinCode5TextField.delegate=self;
    pinCode6TextField.delegate=self;
    pinCode7TextField.delegate=self;
    pinCode8TextField.delegate=self;
    
    pinCode1TextField.layer.cornerRadius=4.0f;
    pinCode1TextField.layer.masksToBounds=YES;
    pinCode1TextField.layer.borderColor=[[UIColor grayColor]CGColor];
    pinCode1TextField.layer.borderWidth= 1.0f;
    
    pinCode2TextField.layer.cornerRadius=4.0f;
    pinCode2TextField.layer.masksToBounds=YES;
    pinCode2TextField.layer.borderColor=[[UIColor grayColor]CGColor];
    pinCode2TextField.layer.borderWidth= 1.0f;
    
    pinCode3TextField.layer.cornerRadius=4.0f;
    pinCode3TextField.layer.masksToBounds=YES;
    pinCode3TextField.layer.borderColor=[[UIColor grayColor]CGColor];
    pinCode3TextField.layer.borderWidth= 1.0f;
    
    pinCode4TextField.layer.cornerRadius=4.0f;
    pinCode4TextField.layer.masksToBounds=YES;
    pinCode4TextField.layer.borderColor=[[UIColor grayColor]CGColor];
    pinCode4TextField.layer.borderWidth= 1.0f;
    
    pinCode5TextField.layer.cornerRadius=4.0f;
    pinCode5TextField.layer.masksToBounds=YES;
    pinCode5TextField.layer.borderColor=[[UIColor grayColor]CGColor];
    pinCode5TextField.layer.borderWidth= 1.0f;
    
    pinCode6TextField.layer.cornerRadius=4.0f;
    pinCode6TextField.layer.masksToBounds=YES;
    pinCode6TextField.layer.borderColor=[[UIColor grayColor]CGColor];
    pinCode6TextField.layer.borderWidth= 1.0f;
    
    pinCode7TextField.layer.cornerRadius=4.0f;
    pinCode7TextField.layer.masksToBounds=YES;
    pinCode7TextField.layer.borderColor=[[UIColor grayColor]CGColor];
    pinCode7TextField.layer.borderWidth= 1.0f;
    
    pinCode8TextField.layer.cornerRadius=4.0f;
    pinCode8TextField.layer.masksToBounds=YES;
    pinCode8TextField.layer.borderColor=[[UIColor grayColor]CGColor];
    pinCode8TextField.layer.borderWidth= 1.0f;
    
    submitButton.layer.cornerRadius=4.0f;
    cancelButton.layer.cornerRadius=4.0f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pinChangeResponseCheck:) name:NOTIFICATION_PIN_CANGE_API
                                               object:nil];

}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
   if (string.length > 0 && ![[NSScanner scannerWithString:string] scanInt:NULL])
           return NO;
       
       NSUInteger oldLength = [textField.text length];
       NSUInteger replacementLength = [string length];
       NSUInteger rangeLength = range.length;
       
       NSUInteger newLength = oldLength - rangeLength + replacementLength;
       
       // This 'tabs' to next field when entering digits
       if (newLength == 1) {
           if (textField == pinCode1TextField)
           {
               [self performSelector:@selector(setNextResponder:) withObject:pinCode2TextField afterDelay:0.05];
           }
           else if (textField == pinCode2TextField)
           {
               [self performSelector:@selector(setNextResponder:) withObject:pinCode3TextField afterDelay:0.05];
           }
           else if (textField == pinCode3TextField)
           {
               [self performSelector:@selector(setNextResponder:) withObject:pinCode4TextField afterDelay:0.05];
           }
           
           if (textField == pinCode5TextField)
           {
               [self performSelector:@selector(setNextResponder:) withObject:pinCode6TextField afterDelay:0.05];
           }
           else if (textField == pinCode6TextField)
           {
               [self performSelector:@selector(setNextResponder:) withObject:pinCode7TextField afterDelay:0.05];
           }
           else if (textField == pinCode7TextField)
           {
               [self performSelector:@selector(setNextResponder:) withObject:pinCode8TextField afterDelay:0.05];
           }
       }
       //this goes to previous field as you backspace through them, so you don't have to tap into them individually
       else if (oldLength > 0 && newLength == 0) {
           if (textField == pinCode4TextField)
           {
               [self performSelector:@selector(setNextResponder:) withObject:pinCode3TextField afterDelay:0.05];
           }
           else if (textField == pinCode3TextField)
           {
               [self performSelector:@selector(setNextResponder:) withObject:pinCode2TextField afterDelay:0.05];
           }
           else if (textField == pinCode2TextField)
           {
               [self performSelector:@selector(setNextResponder:) withObject:pinCode1TextField afterDelay:0.05];
           }
           
           if (textField == pinCode8TextField)
           {
               [self performSelector:@selector(setNextResponder:) withObject:pinCode7TextField afterDelay:0.05];
           }
           else if (textField == pinCode7TextField)
           {
               [self performSelector:@selector(setNextResponder:) withObject:pinCode6TextField afterDelay:0.05];
           }
           else if (textField == pinCode6TextField)
           {
               [self performSelector:@selector(setNextResponder:) withObject:pinCode5TextField afterDelay:0.05];
           }
       }
       
       return newLength <= 1;
}

- (void)setNextResponder:(UITextField *)nextResponder
{
    [nextResponder becomeFirstResponder];
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
     if (textField == pinCode1TextField)
       {
           [pinCode2TextField becomeFirstResponder];
       }
       else if (textField == pinCode2TextField)
       {
           [pinCode3TextField becomeFirstResponder];
       }
       else if (textField == pinCode3TextField)
       {
           [pinCode4TextField becomeFirstResponder];
       }
    
    if (textField == pinCode5TextField)
       {
           [pinCode6TextField becomeFirstResponder];
       }
       else if (textField == pinCode6TextField)
       {
           [pinCode7TextField becomeFirstResponder];
       }
       else if (textField == pinCode7TextField)
       {
           [pinCode8TextField becomeFirstResponder];
       }
    
    
    return NO;
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

- (IBAction)backButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)submitButtonClicked:(id)sender
{
    NSString* title;
    NSString* message;
    UIAlertAction *actionOk;
    NSString* oldPin=[NSString stringWithFormat:@"%@%@%@%@",pinCode1TextField.text,pinCode2TextField.text,pinCode3TextField.text,pinCode4TextField.text];
      NSString* newPin=[NSString stringWithFormat:@"%@%@%@%@",pinCode5TextField.text,pinCode6TextField.text,pinCode7TextField.text,pinCode8TextField.text];
    if ([pinCode1TextField.text isEqual:@""] || [pinCode2TextField.text isEqual:@""]|| [pinCode3TextField.text isEqual:@""] || [pinCode4TextField.text isEqual:@""] || [pinCode5TextField.text isEqual:@""] || [pinCode6TextField.text isEqual:@""]|| [pinCode7TextField.text isEqual:@""] || [pinCode8TextField.text isEqual:@""])
    {
        if ([pinCode1TextField.text isEqual:@""] || [pinCode2TextField.text isEqual:@""]|| [pinCode3TextField.text isEqual:@""] || [pinCode4TextField.text isEqual:@""])
        {
            title = @"Please enter valid old Pin";
            message = @"";
            alertController = [UIAlertController alertControllerWithTitle:title
                                                                  message:message
                                                           preferredStyle:UIAlertControllerStyleAlert];
            actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action)
                        {
//                            pinCode1TextField.text=@"";pinCode2TextField.text=@"";pinCode3TextField.text=@"";pinCode4TextField.text=@"";
//                            pinCode5TextField.text=@"";pinCode6TextField.text=@"";pinCode7TextField.text=@"";pinCode8TextField.text=@"";
//                            [pinCode1TextField becomeFirstResponder];
                        }]; //You can use a block here to handle a press on this button
            [alertController addAction:actionOk];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        if ([pinCode5TextField.text isEqual:@""] || [pinCode6TextField.text isEqual:@""]|| [pinCode7TextField.text isEqual:@""] || [pinCode8TextField.text isEqual:@""])
        {
            title = @"Please enter valid new Pin";
            message = @"";
            alertController = [UIAlertController alertControllerWithTitle:title
                                                                  message:message
                                                           preferredStyle:UIAlertControllerStyleAlert];
            actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action)
                        {
//                            pinCode1TextField.text=@"";pinCode2TextField.text=@"";pinCode3TextField.text=@"";pinCode4TextField.text=@"";
//                            pinCode5TextField.text=@"";pinCode6TextField.text=@"";pinCode7TextField.text=@"";pinCode8TextField.text=@"";
//                            [pinCode1TextField becomeFirstResponder];
                        }]; //You can use a block here to handle a press on this button
            [alertController addAction:actionOk];
            [self presentViewController:alertController animated:YES completion:nil];
        }
       

    }
    else
    if ([[AppPreferences sharedAppPreferences].userObj.userPin isEqualToString:oldPin] && [oldPin isEqualToString:newPin])
    {
        title=@"Old and New Pin are same";
        message=@"Please Enter New Pin!";
        alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action)
                                   {
                                       pinCode5TextField.text=@"";
                                       pinCode6TextField.text=@"";
                                       pinCode7TextField.text=@"";
                                       pinCode8TextField.text=@"";
                                       [pinCode5TextField becomeFirstResponder];
                                   }]; //You can use a block here to handle a press on this button
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
        if(![[AppPreferences sharedAppPreferences].userObj.userPin isEqualToString:oldPin])
        {
            alertController = [UIAlertController alertControllerWithTitle:@"Old PIN is Incorrect"
                                                                  message:@""
                                                           preferredStyle:UIAlertControllerStyleAlert];
            actionDelete = [UIAlertAction actionWithTitle:@"Ok"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action)
                            {
                                pinCode1TextField.text=@"";
                                pinCode2TextField.text=@"";
                                pinCode3TextField.text=@"";
                                pinCode4TextField.text=@"";
                                pinCode5TextField.text=@"";
                                pinCode6TextField.text=@"";
                                pinCode7TextField.text=@"";
                                pinCode8TextField.text=@"";
                                [pinCode1TextField becomeFirstResponder];
                                [alertController dismissViewControllerAnimated:YES completion:nil];
                                
                            }]; //You can use a block here to handle a press on this button
            [alertController addAction:actionDelete];
            
            
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    else
    {
       
        if ([AppPreferences sharedAppPreferences].isReachable)
        {
            hud.minSize = CGSizeMake(150.f, 100.f);
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.label.text = @"Updating Pin...";
            hud.detailsLabel.text = @"Please wait";
            
            NSString*     macId=[Keychain getStringForKey:@"udid"];
            [AppPreferences sharedAppPreferences].userObj = nil;
            [[APIManager sharedManager] changePinOldPin:oldPin NewPin:newPin macID:macId];
        }
        else
        {
            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:NO_INTERNET_TITLE_MESSAGE withMessage:NO_INTERNET_DETAIL_MESSAGE withCancelText:nil withOkText:@"OK" withAlertTag:1000];
        }
    
    }
}



-(void) LogoutAndPresentLoginVC
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    
    [AppPreferences sharedAppPreferences].userObj = nil;
    
    UIViewController* vc= [self.storyboard  instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
      
//      [self presentViewController:vc animated:true completion:nil];
    UIViewController *topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topRootViewController.presentedViewController)
    {
        topRootViewController = topRootViewController.presentedViewController;
    }
    
    if (![topRootViewController isKindOfClass: [LoginViewController class]])
    {
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [topRootViewController presentViewController:vc animated:YES completion:nil];
        
    }
    
//     [[[[UIApplication sharedApplication] keyWindow] rootViewController]  presentViewController:vc animated:YES completion:nil];
}

-(void)pinChangeResponseCheck:(NSNotification*)notificationObject
{
    [hud removeFromSuperview];
    NSString* errorString = [notificationObject.object valueForKey:@"error"];
    
    NSString* messageString = [notificationObject.object valueForKey:@"message"];
           
    if (errorString != nil && messageString != nil) {
        
        NSString* failedMessage = @"File uploading failed";
        if (errorString != nil) {
            failedMessage = [NSString stringWithFormat:@"%@, file uploading failed",errorString];
        }
        
        if (errorString != nil && messageString != nil) {
            failedMessage = [NSString stringWithFormat:@"%@, %@, file uploading failed",errorString,messageString];
        }
        else if (messageString != nil){
            failedMessage = [NSString stringWithFormat:@"%@, file uploading failed",messageString];
            
        }
        // to logout user out of the application once session expires
         if ([errorString isEqualToString:@"Unauthorized"] || [messageString isEqualToString:@"Unauthorized"]) {
            failedMessage = @"Your session has timed out. Please login using your PIN and try again.";
             //[hud isHidden];
             [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:failedMessage withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
             
             [self clearAllTestFields];
             
             [self LogoutAndPresentLoginVC];
        }
          
        
        return;
    }
        
    NSDictionary* responseDict=notificationObject.object;
    NSString* responseCodeString=  [responseDict valueForKey:RESPONSE_CODE];
    NSString* pinChangeSuccess=  [responseDict valueForKey:@"pinChangeSuccess"];
    NSString* oldPin=  [responseDict valueForKey:@"oldDevicePin"];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
   
    if ([responseCodeString intValue]==200 && [pinChangeSuccess intValue]==1 && [oldPin intValue]==1)
    {

        
        alertController = [UIAlertController alertControllerWithTitle:@"Pin changed successfully"
                                                              message:@"Please login with new Pin"
                                                       preferredStyle:UIAlertControllerStyleAlert];
        actionDelete = [UIAlertAction actionWithTitle:@"Ok"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action)
                        {
                            MainTabBarViewController * vc = [[UIApplication sharedApplication].keyWindow rootViewController];
                            
                            vc.selectedIndex = 0;
                            
                            LoginViewController* regiController=(LoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                            [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
                            
            
                            regiController.modalPresentationStyle = UIModalPresentationFullScreen;
            
                            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:regiController
                                                                                                         animated:NO
                                                                                                       completion:nil];
                            [alertController dismissViewControllerAnimated:NO completion:nil];
                        }]; //You can use a block here to handle a press on this button
        [alertController addAction:actionDelete];
        
        
       
        
        [self presentViewController:alertController animated:YES completion:nil];
        

        
        
    }
    else
        if ([responseCodeString intValue]==401 && [oldPin intValue]==0)
        {
            // gotResponse=true;
            alertController = [UIAlertController alertControllerWithTitle:@"Old Pin is incorrect"
                                                                  message:@""
                                                           preferredStyle:UIAlertControllerStyleAlert];
            actionDelete = [UIAlertAction actionWithTitle:@"Ok"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action)
                            {
                                [self clearAllTestFields];
                                [pinCode1TextField becomeFirstResponder];
                                [alertController dismissViewControllerAnimated:YES completion:nil];
                            
                            }]; //You can use a block here to handle a press on this button
            [alertController addAction:actionDelete];
            
            
            
            [self presentViewController:alertController animated:YES completion:nil];

            
        }
        else
            if ([responseCodeString intValue]==401 && [pinChangeSuccess intValue]==0 && [oldPin intValue]==1)
            {
                // gotResponse=true;
                alertController = [UIAlertController alertControllerWithTitle:@"Pin change failed"
                                                                      message:@"Please try again!"
                                                               preferredStyle:UIAlertControllerStyleAlert];
                actionDelete = [UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action)
                                {
                                    [self clearAllTestFields];
                    
                                    [pinCode1TextField becomeFirstResponder];
                                    [alertController dismissViewControllerAnimated:YES completion:nil];
                                    
                                }]; //You can use a block here to handle a press on this button
                [alertController addAction:actionDelete];
                
                
              
                
                [self presentViewController:alertController animated:YES completion:nil];

                
            }
    else
    {
        alertController = [UIAlertController alertControllerWithTitle:@"Pin change failed"
                                                                message:@"Please try again!"
                                                         preferredStyle:UIAlertControllerStyleAlert];
          actionDelete = [UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action)
                          {
                              [self clearAllTestFields];
              
                              [pinCode1TextField becomeFirstResponder];
                              [alertController dismissViewControllerAnimated:YES completion:nil];
                              
                          }]; //You can use a block here to handle a press on this button
          [alertController addAction:actionDelete];
          
          
        
          
          [self presentViewController:alertController animated:YES completion:nil];
    }

}
    - (IBAction)cancelButtonClicked:(id)sender
{
    [self clearAllTestFields];
    
    [pinCode1TextField becomeFirstResponder];
    
}

-(void) clearAllTestFields
{
    pinCode1TextField.text=@"";
    pinCode2TextField.text=@"";
    pinCode3TextField.text=@"";
    pinCode4TextField.text=@"";
    pinCode5TextField.text=@"";
    pinCode6TextField.text=@"";
    pinCode7TextField.text=@"";
    pinCode8TextField.text=@"";
}
@end
