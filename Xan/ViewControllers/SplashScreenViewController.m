//
//  SplashScreenViewController.m
//  Cube
//
//  Created by mac on 31/08/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "SplashScreenViewController.h"
#import "LoginViewController.h"
#import "RegistrationViewController.h"
#import "PinRegistrationViewController.h"
#import "UIDevice+Identifier.h"
#import "PopUpCustomView.h"
#import "NSData+AES256.h"
#import "Keychain.h"
#import "TandCViewController.h"

@interface SplashScreenViewController ()

@end

@implementation SplashScreenViewController
@synthesize hud;

- (void)viewDidLoad
{
    [super viewDidLoad];
   
//    [[APIManager sharedManager] downloadAudioFile];

}



-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceRegistrationResponseCheck:) name:NOTIFICATION_CHECK_DEVICE_REGISTRATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeAlertView) name:kReachabilityChangedNotification
                                               object:nil];
    
    NSString*  macId = @"";
    macId = [Keychain getStringForKey:@"udid"];
    
    
    if (macId.length <= 0 || macId == nil)
    {
        macId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [Keychain setString:macId forKey:@"udid"];
    }
    
    //NSLog(@"%@",macId);
    
    //    hud.minSize = CGSizeMake(150.f, 100.f);
    //    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //    hud.mode = MBProgressHUDModeIndeterminate;
    //    hud.label.text = @"Loading";
    //    hud.detailsLabel.text = @"Please wait";
    
    
    //[self checkDeviceRegistration];
//    NSLog(@"Registering for push notifications...");
//    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    if ([AppPreferences sharedAppPreferences].recordNewOffline == YES)
    {
        //        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"dismiss"];
        
        [[[[UIApplication sharedApplication] keyWindow] viewWithTag:222] removeFromSuperview];
        
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RecordViewController"];
        
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [self presentViewController:vc  animated:YES completion:nil];
        
        
    }
    else
    {
        [self performSelector:@selector(checkDeviceRegistration) withObject:nil afterDelay:0.0];

    }
    
     [[NSUserDefaults standardUserDefaults] setValue:@"no" forKey:@"dismiss"]; // for offline record- user pressed stop - net on - upload later - it comes to this view and not recordtabVC - hence need to set dismiss no for subsequent use

}


-(void)checkDeviceRegistration
{
    NSString*     macId = [Keychain getStringForKey:@"udid"];
    //macId=[NSString stringWithFormat:@"%@1234",macId];
    if ([AppPreferences sharedAppPreferences].isReachable)
    {
        if (!APIcalled)
        {
//            [[APIManager sharedManager] testFileName:@"sampleFileName"];
            
            [[APIManager sharedManager] checkDeviceRegistrationMacID:macId];
            APIcalled=true;
        }
    }
    else
    {

        [self addAlertView];

    }
    
    
}

-(void)addAlertView
{

    UIView* view=[[[UIApplication sharedApplication] keyWindow] viewWithTag:222];
   
    
    if (view==NULL)
    {
        
        UIView* internetMessageView;
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            internetMessageView=   [[PopUpCustomView alloc]initWithFrame:CGRectMake(self.view.frame.size.width*0.24, self.view.center.y+50,self.view.frame.size.width*0.52, 120) offlineFrame:CGRectMake(20, self.view.center.y+150,self.view.frame.size.width, 50) senderForInternetMessage:self];        }
        else
        {
           internetMessageView=   [[PopUpCustomView alloc]initWithFrame:CGRectMake(20, self.view.center.y+50,self.view.frame.size.width-40, 120) offlineFrame:CGRectMake(20, self.view.center.y+150,self.view.frame.size.width, 50) senderForInternetMessage:self];
        }
        
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:internetMessageView];
    }
    else
    {
        UIView* popupView= [view viewWithTag:223];
        UIButton* retryButton= [popupView viewWithTag:225];
        [retryButton setEnabled:YES];
        
       [retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    }

}
-(void)refresh:(UIButton*)sender
{
    
    [sender setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
     [sender setEnabled:NO];

    [self performSelector:@selector(checkDeviceRegistration) withObject:nil afterDelay:0.1];
    
}

-(void)goOfflineButtonClicked:(UIButton*)sender
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:222] removeFromSuperview];
    
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RecordViewController"];
    
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    
     [self presentViewController:vc animated:NO completion:nil];
}

-(void)removeAlertView
{
    if ([AppPreferences sharedAppPreferences].isReachable && (self.isViewLoaded && self.view.window))
    {
        [[[[UIApplication sharedApplication] keyWindow] viewWithTag:222] removeFromSuperview];//to remove no internet message
        NSString*     macId=[Keychain getStringForKey:@"udid"];
        //macId=[NSString stringWithFormat:@"%@123456",macId];
        if (!APIcalled)
        {

//            [[APIManager sharedManager] testFileName:@"sampleFileName"];

            [[APIManager sharedManager] checkDeviceRegistrationMacID:macId];

            APIcalled=true;

        }

    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERNET_MESSAGE object:nil];

    }

}
-(void)deviceRegistrationResponseCheck:(NSNotification *)responseDictObject
{
    
    NSDictionary* responseDict=responseDictObject.object;
    NSString* responseCodeString=  [responseDict valueForKey:RESPONSE_CODE];
    NSString* responsePinString=  [responseDict valueForKey:RESPONSE_PIN_VERIFY];
    NSString* tAndcString=  [responseDict valueForKey:RESPONSE_TC_FLAG];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    [hud hideAnimated:YES];
    
    if ([responseCodeString intValue] == -1001) // for internet loss in between
    {
      
        NSString* responseMessageString=  [responseDict valueForKey:RESPONSE_MESSAGE];
        
        NSString* title = @"Error occured!";
        NSString* message = [NSString stringWithFormat:@"%@",responseMessageString];
        
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title
                                                              message:message
                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Retry"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action)
                    {
                        APIcalled = NO;
                        
                        [self checkDeviceRegistration];
                    }]; //You can use a block here to handle a press on this button
        
        [alertController addAction:actionOk];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    else
        if ([responseCodeString intValue]==2001) // for unexpected response
        {
            [hud hideAnimated:YES];
        }
        else
            if ([responseCodeString intValue]==401 && [responsePinString intValue]==0)
            {
                
                RegistrationViewController* regiController=(RegistrationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"RegistrationViewController"];

                regiController.modalPresentationStyle = UIModalPresentationFullScreen;
                
                [self presentViewController:regiController animated:NO completion:NULL];
                
//                 [self performSegueWithIdentifier:@"SPToAcRegi" sender:nil];
                
            }
            else
                if ([responseCodeString intValue]==200 && [responsePinString intValue]==0)
                {
                    
                    PinRegistrationViewController* regiController=(PinRegistrationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PinRegistrationViewController"];

                    regiController.modalPresentationStyle = UIModalPresentationFullScreen;
                    
                    [self presentViewController:regiController animated:NO completion:NULL];
                    
//                    [self performSegueWithIdentifier:@"SPToPINRegi" sender:nil];

                    
                }
                else
                    if ([responseCodeString intValue]==200 && [responsePinString intValue]==1 && [tAndcString intValue] == 0)
                    {
                        
                        TandCViewController *viewController = (TandCViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TandCViewController"];

                        viewController.modalPresentationStyle = UIModalPresentationFullScreen;

                        [self presentViewController:viewController animated:NO completion:NULL];
                        
//                        [self performSegueWithIdentifier:@"SPToTC" sender:nil];

                        
                    }
                    else
                        if ([responseCodeString intValue]==200 && [responsePinString intValue]==1 && [tAndcString intValue] == 1)
                        {
                            
                            LoginViewController *viewController = (LoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                            
                             viewController.modalPresentationStyle = UIModalPresentationFullScreen;

//                            LoginViewController *viewController1 = (LoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];

                            [self presentViewController:viewController animated:NO completion:NULL];
//                            [self performSegueWithIdentifier:@"SPToPINLogin" sender:nil];

                            
                        }
                        else
                        {
                            
                            if ([[AppPreferences sharedAppPreferences] isReachable])
                            {
                                
                                [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Something went wrong!" withMessage:@"Please try again" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
                                
                            }
                            else
                            {
                                
                                [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:nil withMessage:@"Please check your Internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
                                
                            }
                            
                        }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    //NSLog(@"disappesred");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
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
