//
//  ContactUsViewController.h
//  Xan
//
//  Created by mac on 07/04/20.
//  Copyright © 2020 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactUsViewController : UIViewController<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *productsLinkTextVIew;
- (IBAction)backButtonClicked:(id)sender;

@end

NS_ASSUME_NONNULL_END
