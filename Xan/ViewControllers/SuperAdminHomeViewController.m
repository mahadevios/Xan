//
//  SuperAdminHomeViewController.m
//  Xan
//
//  Created by Martina Makasare on 7/23/19.
//  Copyright © 2019 Xanadutec. All rights reserved.
//

#import "SuperAdminHomeViewController.h"

@interface SuperAdminHomeViewController ()

@end

@implementation SuperAdminHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hospitalView.layer.cornerRadius = 10.0;
    self.hospitalView.layer.shadowColor = [[UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1] CGColor];
    self.hospitalView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.hospitalView.layer.shadowRadius = 12.0;
    self.hospitalView.layer.shadowOpacity = 1;
    self.departmentView.layer.cornerRadius = 10.0;
    self.departmentView.layer.shadowColor = [[UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1] CGColor];
    self.departmentView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.departmentView.layer.shadowRadius = 12.0;
    self.departmentView.layer.shadowOpacity = 0.7;
    self.practitionerView.layer.cornerRadius = 10.0;
    self.practitionerView.layer.shadowColor = [[UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1] CGColor];
    self.practitionerView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.practitionerView.layer.shadowRadius = 12.0;
    self.practitionerView.layer.shadowOpacity = 0.7;
    self.secretaryView.layer.cornerRadius = 10.0;
    self.secretaryView.layer.shadowColor = [[UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1] CGColor];
    self.secretaryView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.secretaryView.layer.shadowRadius = 12.0;
    self.secretaryView.layer.shadowOpacity = 0.7;
    // code to check if screen height is less than iphone SE
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    if(screenHeight<= 568.0)
    {
        UIFont* boldFont = [UIFont fontWithName:@"Helvetica-Bold" size:12];

        [self.hospitalLabel setFont:boldFont];
        [self.Department setFont:boldFont];
        [self.practitionerLabel setFont:boldFont];
        [self.secretaryLabel setFont:boldFont];
        NSLog(@"Device height is less than 568");
    }
    
    hospitalViewTapRecogniser = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showHospitalList:)];
    departmentViewTapRecogniser = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showDepartmentList:)];
    practitionerViewTapRecogniser = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showPractitionerList:)];
    secretaryViewTapRecogniser = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showSecretaryList:)];
    
    [self.hospitalView addGestureRecognizer:hospitalViewTapRecogniser];
    [self.departmentView addGestureRecognizer:departmentViewTapRecogniser];
    [self.practitionerView addGestureRecognizer:practitionerViewTapRecogniser];
    [self.secretaryView addGestureRecognizer:secretaryViewTapRecogniser];
    
    _scrollView.alwaysBounceVertical = NO;
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self selector:@selector(orientationChanged:)
//     name:UIDeviceOrientationDidChangeNotification
//     object:[UIDevice currentDevice]];
//    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
//    self.navigationController.navigationBar.tintColor = [UIColor clearColor];

    

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
 
//    [self setScrollViewHeight];
}

- (void) orientationChanged:(NSNotification *)note
{
    
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            [self.scrollView setContentOffset:
             CGPointMake(0, -self.scrollView.contentInset.top) animated:YES];
//             [self setScrollViewHeight];
            self.scrollView.scrollEnabled = false;
            /* start special animation */
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            /* start special animation */
            break;
        
            case UIDeviceOrientationLandscapeLeft:
            self.scrollView.scrollEnabled = true;
             [self setScrollViewHeight];
            break;
            
            
        case UIDeviceOrientationLandscapeRight:
            self.scrollView.scrollEnabled = true;
             [self setScrollViewHeight];
            break;
        default:
            break;
    };
}

-(void)setScrollViewHeight
{
    CGRect contentRect = CGRectZero;
    
    for (UIView *view in self.contentView.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    
    double height = contentRect.size.height/2;
    self.contentViewHeightConstraint.constant = height;
    
//    self.scrollView.alwaysBounceVertical = NO;
//    self.scrollView.contentSize = contentRect.size;
}

-(void)showHospitalList:(UITapGestureRecognizer*)sender
{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"HospitalListViewController"];
    vc.navigationItem.title = @"Hospitals";
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)showDepartmentList:(UITapGestureRecognizer*)sender
{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    //    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)showPractitionerList:(UITapGestureRecognizer*)sender
{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    //    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"HospitalListViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)showSecretaryList:(UITapGestureRecognizer*)sender
{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    //    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"HospitalListViewController"];
    [self.navigationController pushViewController:vc animated:YES];
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
