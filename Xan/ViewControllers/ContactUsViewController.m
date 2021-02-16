//
//  ContactUsViewController.m
//  Xan
//
//  Created by mac on 07/04/20.
//  Copyright © 2020 Xanadutec. All rights reserved.
//

#import "ContactUsViewController.h"

@interface ContactUsViewController ()

@end

@implementation ContactUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    
      NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:@"https://xanadutec.com.au/ace-dictate/"];
      
      [str addAttribute: NSLinkAttributeName value: @"https://xanadutec.com.au/ace-dictate/" range: NSMakeRange(0, 37)];
      
      self.productsLinkTextVIew.scrollEnabled = NO;
      self.productsLinkTextVIew.editable = NO;
      self.productsLinkTextVIew.textContainer.lineFragmentPadding = 0;
      self.productsLinkTextVIew.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
      self.productsLinkTextVIew.delegate = self;
      self.productsLinkTextVIew.attributedText = str;
      self.productsLinkTextVIew.font = [UIFont systemFontOfSize:15];
    
  
          if (UIScreen.mainScreen.traitCollection.userInterfaceStyle==UIUserInterfaceStyleDark){
              self.productsLinkTextVIew.backgroundColor = [UIColor whiteColor];
              self.productsLinkTextVIew.linkTextAttributes = @{
                  NSForegroundColorAttributeName: [UIColor blackColor]
              };
          }
    
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)url inRange:(NSRange)characterRange
{
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
@end
