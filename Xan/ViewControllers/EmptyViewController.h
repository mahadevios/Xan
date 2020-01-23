//
//  EmptyViewController.h
//  Cube
//
//  Created by mac on 22/05/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@interface EmptyViewController : UIViewController<UIDocumentInteractionControllerDelegate,WKNavigationDelegate>


@property(nonatomic, strong) NSString* usedByVCName;
@property(nonatomic, strong) NSString* docxFileToShowPath;
@property(nonatomic) long dataToShowCount;
@property(nonatomic, strong) WKWebView* webView;
@property(nonatomic, strong) UITextView* textFileContentTextView;
@property(nonatomic, strong) UIView* navigationView;
@property(nonatomic, strong) UILabel* navigationTitleLabel;
-(void)showDocxFile:(NSString*)docxFileToShowPath;

@end
