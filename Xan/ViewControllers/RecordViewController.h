//
//  RecordViewController.h
//  Cube
//
//  Created by mac on 27/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopUpCustomView.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioSessionManager.h"
#import "MBProgressHUD.h"
#import <AudioToolbox/AudioToolbox.h>

#import "Database.h"
#import "APIManager.h"
#import "AppPreferences.h"
#import "Constants.h"
#import "MKDropdownMenu.h"

// helpers
//#include "CAXException.h"
//#include "CAStreamBasicDescription.h"
//#include "ExtAudioFileConvert.mm"

@interface RecordViewController : UIViewController<UIGestureRecognizerDelegate,AVAudioPlayerDelegate,MKDropdownMenuDelegate,MKDropdownMenuDataSource,UITextViewDelegate>
{
    Database* db;
    APIManager* app;
    PopUpCustomView* forTableViewObj;
    
    UITapGestureRecognizer* tap;
    
    UIView* popupView;
    UIView* editPopUp;
    
    
    UITableViewCell *cell;
    NSArray* departmentObjectArray;
    NSArray* departmentNamesArray;
    NSMutableArray* duplicateDepartmentNamesArray;
    NSString* selectedDepartment;

    UISlider* audioRecordSlider;
    
    bool recordingPauseAndExit;
    bool recordingPausedOrStoped;
    bool isRecordingStarted;

    UILabel* cirecleTimerLAbel;
    NSTimer*  stopTimer;
    UILabel* currentDuration;
    UILabel* totalDuration;
    int circleViewTimerMinutes;
    int circleViewTimerSeconds;
    int circleViewTimerHours;
    
    //for dictation wauting by setting
    NSString* maxRecordingTimeString;
    int dictationTimerSeconds;

    //for alertview
    NSDictionary* result;
    UIAlertController *alertController;
    UIAlertAction *actionDelete;
    UIAlertAction *actionCancel;
    NSDictionary* audiorecordDict;
    
    //for audio compression
    
    NSString *destinationFilePath;
    CFURLRef sourceURL;
    CFURLRef destinationURL;
    OSType   outputFormat;
    Float64  sampleRate;
    
    int minutesValue;
    BOOL deleted;
    BOOL paused;
    BOOL stopped;
    BOOL recordingNew;
    BOOL edited;
    BOOL isViewSetUpWhenFirstAppear;
    
    UIBackgroundTaskIdentifier task;
    
    NSString* recordedAudioFileName;
    
    UIView* circleView;

    long todaysSerialNumberCount;

    NSTimer* sliderTimer;
    
    NSString* editType;
    
    BOOL recordingRestrictionLimitCrossed;
    
//    long totalSecondsOfAudio;
    
    float updatedInsertionTime;
    
    float playerDurationWithMilliSeconds;
    
    DepartMent* existingDepartment;
    
    MKDropdownMenu *templateNamesDropdownMenu;
    
    NSMutableArray* templateNamesArray;
    
    NSString* selectedTemplateName;
    
    NSString* recentlySelectedTemplateName;
//    bool recordingSavedToDatabaseFromBG;
    UIImageView* urgentImageView;
    
    UILabel* commentLabel;
    
    BOOL checkBoxSelected;
    
}
@property (nonatomic,strong)     AVAudioPlayer       *player;
@property (nonatomic,strong)     AVAudioRecorder     *recorder;
@property (nonatomic,strong)     NSString            *recordedAudioFileName;
@property (nonatomic,strong)     NSURL               *recordedAudioURL;
@property (nonatomic,strong)     NSString              *recordCreatedDateString;
@property (weak, nonatomic) MBProgressHUD *hud;
@property (weak, nonatomic) IBOutlet UIButton *stopNewButton;
@property (weak, nonatomic) IBOutlet UIImageView *stopNewImageView;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)moreButtonPressed:(id)sender;
- (IBAction)deleteRecording:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
- (IBAction)stopRecordingButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *stopLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordLAbel;
- (IBAction)editAudioButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *SpeechToTextView;
- (IBAction)speechToTextButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *speechToTextCircleView;

@end
