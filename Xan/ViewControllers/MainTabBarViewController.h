//
//  MainTabBarViewController.h
//  Cube
//
//  Created by mac on 27/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTabBarViewController : UITabBarController

@property(nonatomic, strong) NSString* isSplashScreenPresented;
@property (weak, nonatomic) IBOutlet UITabBar *bottomTabBar;

@end
