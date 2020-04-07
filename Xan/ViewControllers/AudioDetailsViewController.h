//
//  AudioDetailsViewController.h
//  Cube
//
//  Created by mac on 28/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioSessionManager.h"
#import "PopUpCustomView.h"
#import "AudioDetails.h"
#import "InCompleteRecordViewController.h"
#import "MKDropdownMenu.h"

@class AudioDetailsViewController;             //define class, so protocol can see MyClass
@protocol MyClassDelegate <NSObject>   //define delegate protocol

- (void) myClassDelegateMethod: (AudioDetailsViewController *) sender;  //define delegate method to be implemented within another class
@end //end protocol

@interface AudioDetailsViewController : UIViewController<AVAudioPlayerDelegate,UIGestureRecognizerDelegate,UpdateModifiedData,MKDropdownMenuDelegate,MKDropdownMenuDataSource,UITextViewDelegate>
{
    NSDictionary* result;
    UIAlertController *alertController;
    UIAlertAction *actionDelete;
    UIAlertAction *actionCancel;
    BOOL deleted;
    
    UISlider* audioRecordSlider;
    UIView* sliderPopUpView;
    UIView* popupView;
    PopUpCustomView* forTableViewObj;
    bool moreButtonPressed;
    UIView * overlay;
    UIBackgroundTaskIdentifier task;
    UITableViewCell *cell;
    
    NSArray* departmentNamesArray;
    NSMutableArray* departmentObjectArray;
    NSMutableArray *duplicateDepartmentNamesArray;
    
    UITapGestureRecognizer* tap;
    BOOL isDeleteEditTransferButtonsRemovedAfterTransfer;
    
    MKDropdownMenu *templateNamesDropdownMenu;
    
    NSMutableArray* templateNamesArray;
    
    NSString* selectedTemplateName;
    
    BOOL checkBoxSelected;
    
    NSString* recentlySelectedTemplateName;
}
@property (weak, nonatomic) IBOutlet UIImageView *urgentCheckBoxImageView;
- (IBAction)urgentCheckBoxButtonClicked:(id)sender;
@property(nonatomic)long selectedRow;
@property(nonatomic,strong)NSString* selectedView;
@property(nonatomic,strong)AudioDetails* audioDetails;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@property (weak, nonatomic) IBOutlet UIButton *transferDictationButton;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIButton *deleteDictationButton;

@property (nonatomic, weak) id <MyClassDelegate> delegate; //define MyClassDelegate as delegate

- (IBAction)moreButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *dictatedByLabel;

- (IBAction)editRecordingButtonPressed:(id)sender;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)deleteDictation:(id)sender;
- (IBAction)playRecordingButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *transferDateTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transferButtonYConstraint;
@property (weak, nonatomic) IBOutlet UIView *mkDropdwonRefView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *insideView;
- (IBAction)transferDictationButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *urgentCheckboxButton;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
- (IBAction)commentButtonClicked:(id)sender;
@end
