//
//  InCompleteRecordViewController.h
//  Cube
//
//  Created by mac on 24/08/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopUpCustomView.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioSessionManager.h"
#import "MBProgressHUD.h"
#import "Database.h"
#import "APIManager.h"
#import "Constants.h"
#import "MKDropdownMenu.h"

@class InCompleteRecordViewController;
@protocol UpdateModifiedData <NSObject>

-(void) updateData:(NSDictionary*) delegateDict; // we can also pass incompleterecordviewcontrollers object

@end


@interface InCompleteRecordViewController : UIViewController<UIGestureRecognizerDelegate,AVAudioPlayerDelegate,MKDropdownMenuDelegate,MKDropdownMenuDataSource,UITextViewDelegate>

{
    int i;
    UITapGestureRecognizer* tap;
    UIView* popupView;
    PopUpCustomView* obj;
    UIView* editPopUp;
    UITableViewCell *cell;
    NSMutableArray* departmentObjectArray;
    NSArray* departmentNamesArray;
    NSMutableArray *duplicateDepartmentNamesArray;
    
    UISlider* audioRecordSlider;
    Database* db;
    APIManager* app;
    bool recordingPauseAndExit;
    UILabel* audioDurationLAbel;
    NSTimer* stopTimer;
    int timerSeconds;
    int timerMinutes;
    int timerHour;

    int circleViewTimerMinutes;
    int circleViewTimerSeconds;
    int circleViewTimerHour;

    UILabel* currentDuration;
    UILabel* totalDuration;
    bool recordingPausedOrStoped;
    bool recordingStopped;
    bool isRecordingStarted;
    //for dictation wauting by setting
    NSString* maxRecordingTimeString;
    int dictationTimerSeconds;
    int minutesValue;//for dictation time in minutes

    //for alert view
    NSDictionary* result;
    UIAlertController *alertController;
    UIAlertAction *actionDelete;
    UIAlertAction *actionCancel;
    BOOL deleted;
    NSDictionary* audiorecordDict;
    
    //for audio compression
    
    NSString *destinationFileExtension;
    CFURLRef sourceURL;
    CFURLRef destinationURL;
    OSType   outputFormat;
    Float64  sampleRate;
    UIBackgroundTaskIdentifier task;
    bool composed;
    bool isRecording;
    UIView* circleView;
    
    BOOL edited;
    NSString* editType;
    NSTimer* sliderTimer;
    
    BOOL recordingRestrictionLimitCrossed;
    
    long totalSecondsOfAudio;
    
    bool isViewSetUpWhenFirstAppear;
    
    float_t updatedInsertionTime;
    
    float playerDurationWithMilliSeconds;
    
    MKDropdownMenu *templateNamesDropdownMenu;
    
    NSMutableArray* templateNamesArray;
    
    NSString* selectedTemplateName;
    
    UIImageView* urgentImageView;
    
    BOOL checkBoxSelected;
    
    BOOL isDepartmentRadioButtonSelcted;
    
    BOOL isDeptRowSelcted;
    
    NSString* recentlySelectedTemplateName;
    
     UILabel* commentLabel;
//    UIButton* uploadLaterButton;
//    UIButton* recordNewButton;
//    UIView* animatedView;
}
@property (nonatomic)     AVAudioPlayer       *player;
@property (nonatomic)     AVAudioRecorder     *recorder;
@property (nonatomic,strong)     NSString            *recordedAudioFileName;
@property (nonatomic,strong)     NSString            *existingAudioFileName;//for use of prev controller
@property (nonatomic)     DepartMent            *existingAudioDepartment;//for use of prev controller
@property (nonatomic)     NSString            *existingAudioTemplateName;//for use of prev controller
@property (nonatomic)     NSString            *existingAudioDate;//for use of prev controller
@property (nonatomic)     NSString            *existingAudioPriorityId;//for use of prev controller
@property (nonatomic)     NSString            *existingAudioComment;//for use of prev controller

@property (nonatomic)     int            audioDurationInSeconds;
@property (nonatomic,strong)     NSURL               *recordedAudioURL;
@property (nonatomic,strong)     NSURL               *playerAudioURL;
//@property (nonatomic,strong)         UIButton* uploadAudioButton;
//@property (nonatomic,strong)         UIButton* recordNewButton;
//@property (nonatomic,strong)         UIView* animatedView;
//@property (nonatomic,strong)         UIButton* uploadLaterButton;



@property (nonatomic)     NSString            *recordCreatedDateString;
@property(nonatomic) NSString* audioDuration;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) MBProgressHUD *hud1;
@property (nonatomic, weak) id <UpdateModifiedData> delegate;

- (IBAction)deleteButtonPressed:(id)sender;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)moreButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
- (IBAction)stopRecordingButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *stopNewButton;
@property (weak, nonatomic) IBOutlet UIImageView *stopNewImageView;
@property (weak, nonatomic) IBOutlet UILabel *stopLabel;
@property (weak, nonatomic) IBOutlet UIImageView *animatedImageView;
@property(nonatomic) BOOL isOpenedFromAudioDetails;
@property(nonatomic) long selectedRowOfAwaitingList;

- (IBAction)editAudioButtonClicked:(id)sender;
@end
