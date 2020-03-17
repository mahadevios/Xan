//
//  TransferredOrDeletedAudioDetailsViewController.h
//  Cube
//
//  Created by mac on 29/08/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioSessionManager.h"
#import "PopUpCustomView.h"
#import "AudioDetails.h"
#import "MKDropdownMenu.h"
//#import "ListViewController.h"
//#import "MyClass.h"
@class TransferredOrDeletedAudioDetailsViewController;             //define class, so protocol can see MyClass
@protocol MyClassDelegate <NSObject>   //define delegate protocol

- (void) myClassDelegateMethod: (TransferredOrDeletedAudioDetailsViewController *) sender;  //define delegate method to be implemented within another class
@end //end protocol

@interface TransferredOrDeletedAudioDetailsViewController : UIViewController<AVAudioPlayerDelegate,UISplitViewControllerDelegate,MyClassDelegate,MKDropdownMenuDelegate,MKDropdownMenuDataSource, UITextViewDelegate>

{
    NSDictionary* result;
    UIAlertController *alertController;
    UIAlertAction *actionDelete;
    UIAlertAction *actionCancel;
    BOOL deleted;
//    NSDictionary* audiorecordDict;
    
    UISlider* audioRecordSlider;
    UIView* sliderPopUpView;
    UIView* popupView;
    PopUpCustomView* forTableViewObj;
    UITableViewCell *cell;
    NSArray* departmentNamesArray;
    UITapGestureRecognizer* tap;
    
    MKDropdownMenu *templateNamesDropdownMenu;
    
    NSMutableArray* templateNamesArray;
    
    NSString* selectedTemplateName;
    
     BOOL checkBoxSelected;
    
    NSString* recentlySelectedTemplateName;

}
@property (weak, nonatomic) IBOutlet UIView *insideView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic)long listSelected;
@property(nonatomic)long selectedRow;
- (IBAction)backButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteDictationButton;
@property (weak, nonatomic) IBOutlet UILabel *dictatedByLabel;
- (IBAction)playRecordingButtonPressed:(id)sender;
- (IBAction)deleteRecordinfButtonPressed:(id)sender;
- (IBAction)resendButtonClckied:(id)sender;
- (IBAction)moreButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
-(void)setAudioDetails;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property(nonatomic,strong)AudioDetails* audioDetails;
@property (weak, nonatomic) IBOutlet UILabel *transferDateTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *mkDropdwonRefView;

@property (nonatomic, weak) id <MyClassDelegate> delegate; //define MyClassDelegate as delegate@property (weak, nonatomic) IBOutlet NSLayoutConstraint *;
- (IBAction)urgentCheckBoxButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *urgentCheckBoxImageView;
@property (weak, nonatomic) IBOutlet UIButton *urgentCheckboxButton;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
- (IBAction)commentButtonClicked:(id)sender;

@end
