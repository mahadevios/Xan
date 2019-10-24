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
//    [UITabBarItem.appearance setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];
//    [UITabBarItem.appearance setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
   [[UITabBar appearance] setItemWidth:100];
    
    self.tabBar.selectionIndicatorImage = [UIImage imageNamed:@"Info"];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setTabBarBackgroundImage];
}

-(void)viewDidAppear:(BOOL)animated
{
   
}

-(void)setTabBarBackgroundImage
{
    UITabBar *tabBar = self.tabBar;
    CGSize imgSize = CGSizeMake(tabBar.frame.size.width/tabBar.items.count,tabBar.frame.size.height+0.5);
    
    //Create Image
    UIGraphicsBeginImageContextWithOptions(imgSize, NO, 0);
    UIBezierPath* p =
    [UIBezierPath bezierPathWithRect:CGRectMake(0,0,imgSize.width,imgSize.height+0.5)];
    [[UIColor colorWithRed:225/255.0 green:232/255.0 blue:246/255.0 alpha:1.0] setFill];
    [p fill];
    UIImage* finalImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [tabBar setSelectionIndicatorImage:finalImg];
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
//-(void)viewDidAppear:(BOOL)animated
//{
    
//    if ([self.isSplashScreenPresented isEqualToString:@""] || self.isSplashScreenPresented == nil)
//    {
//        [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SplashScreenViewController"] animated:NO completion:nil];
//        
//        self.isSplashScreenPresented = @"yes";
//    }
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
