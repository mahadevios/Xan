//
//  EmptyViewController.m
//  Cube
//
//  Created by mac on 22/05/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import "EmptyViewController.h"
#import "AppPreferences.h"
#import "UIColor+ApplicationColors.h"

@interface EmptyViewController ()

@end

@implementation EmptyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    if ([self.usedByVCName isEqualToString:@"VRSVC"])
    {
       
        
        [self setnavigationView];
        
        [self setEmptyVCForDocFileView:0];
    }
}

-(void)setnavigationView
{
    double secondVCWidth = self.view.frame.size.width - self.splitViewController.primaryColumnWidth;
    
    self.navigationView = [[UIView alloc] initWithFrame:CGRectMake(0,0, secondVCWidth, 64)];
    
    self.navigationView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];

//    self.navigationView.backgroundColor = [UIColor redColor];

    self.navigationTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.navigationView.center.x-50, self.navigationView.frame.size.height/2 - 5, 100, 30)];
    
//    [self.navigationTitleLabel sizeToFit];
    
    self.navigationTitleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.navigationTitleLabel.textColor = [UIColor whiteColor];
    
    self.navigationTitleLabel.text = @"Text File";
    
    self.navigationTitleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, self.view.frame.origin.y + 10, secondVCWidth, self.view.frame.size.height)];
    
    self.webView.navigationDelegate = self;
//    self.webView.delegate = self;
    
    self.textFileContentTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, self.navigationView.frame.size.height + 10, secondVCWidth, self.view.frame.size.height)];
    
    self.textFileContentTextView.userInteractionEnabled = NO;
    
    [self.navigationView addSubview:self.navigationTitleLabel];
    
    [self.view addSubview:self.navigationView];
    
    if (UIScreen.mainScreen.traitCollection.userInterfaceStyle==UIUserInterfaceStyleDark){
        self.textFileContentTextView.backgroundColor = [UIColor whiteColor];
        self.webView.backgroundColor = [UIColor whiteColor];

    }
    
    [self.view addSubview:self.textFileContentTextView];
        
}

-(void)setEmptyVCForDocFileView:(int)index
{
    if (self.splitViewController != nil && self.splitViewController.isCollapsed == false) // if not collapsed that is reguler width hnce ipad
    {
        if (self.dataToShowCount > 0)
        {
            
            [self showDocxFile:self.docxFileToShowPath];
        }
    }
}

-(void)showDocxFile:(NSString*)docxFileToShowPath
{
    
    NSURL* url = [NSURL fileURLWithPath:docxFileToShowPath isDirectory:NO];
    
    self.textFileContentTextView.text = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    if (UIScreen.mainScreen.traitCollection.userInterfaceStyle==UIUserInterfaceStyleDark){
        self.textFileContentTextView.backgroundColor = [UIColor whiteColor];
        self.webView.backgroundColor = [UIColor whiteColor];

    }
}

//-(void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
//
//}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
}

-(UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    
    return self;
}

-(void)documentInteractionControllerWillBeginPreview:(UIDocumentInteractionController *)controller
{
  
    
    [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
