//
//  MainTabBarViewController.m
//  Cube
//
//  Created by mac on 27/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "AppPreferences.h"
#import "SplashScreenViewController.h"
@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   // [self.view.window.rootViewController dismissViewControllerAnimated:false completion:nil];
//    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:true completion:nil];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)viewWillAppear:(BOOL)animated
//{
//   
//}
-(void)viewDidAppear:(BOOL)animated
{
    
    if ([self.isSplashScreenPresented isEqualToString:@""] || self.isSplashScreenPresented == nil)
    {
        [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SplashScreenViewController"] animated:NO completion:nil];
        
        self.isSplashScreenPresented = @"yes";
    }
//    [self performSegueWithIdentifier:@"SP" sender:self];
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
