//
//  AppDelegate.m
//  Cube
//
//  Created by mac on 26/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

// Pro. Profile,code signing in deep  http://stackoverflow.com/questions/24583654/understanding-the-certificate-and-provisioning-profile-let-me-know-if-it-is-rig

//code resource http://escoz.com/blog/demystifying-ios-certificates-and-provisioning-files/

//code signing apple https://developer.apple.com/library/content/documentation/Security/Conceptual/CodeSigningGuide/AboutCS/AboutCS.html#//apple_ref/doc/uid/TP40005929-CH3-SW3

// double code signing http://blog.bitrise.io/2016/09/21/xcode-8-and-automatic-code-signing.html

//siging identities and certificates  https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppDistributionGuide/MaintainingCertificates/MaintainingCertificates.html

// animation https://www.raywenderlich.com/86521/how-to-make-a-view-controller-transition-animation-like-in-the-ping-app
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "RegistrationViewController.h"
#import "PinRegistrationViewController.h"
#import "UIDevice+Identifier.h"
#import "SplashScreenViewController.h"
#import "AudioSessionManager.h"
#import "CAXException.h"
#import <AVFoundation/AVFoundation.h>
#import "SharedSession.h"

extern void ThreadStateInitalize();
extern void ThreadStateBeginInterruption();
extern void ThreadStateEndInterruption();
extern OSStatus DoConvertFile(CFURLRef sourceURL, CFURLRef destinationURL, OSType outputFormat, Float64 outputSampleRate);

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize hud,window,gotResponse,fileName;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    [[AppPreferences sharedAppPreferences] startReachabilityNotifier];
    [APIManager sharedManager].userSettingsOpened=NO;
    [AppPreferences sharedAppPreferences].filesInAwaitingQueueArray = [[NSMutableArray alloc] init];
    [AppPreferences sharedAppPreferences].filesInUploadingQueueArray = [[NSMutableArray alloc] init];
    
    [self checkAndCopyDatabase];
    
//    NSString* currentVersion = [[NSUserDefaults standardUserDefaults] valueForKey:CURRENT_VESRION];
    
   
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:LOW_STORAGE_THRESHOLD]== NULL)
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"512 MB" forKey:LOW_STORAGE_THRESHOLD];
        
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:SAVE_DICTATION_WAITING_SETTING]== NULL)
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"15 min" forKey:SAVE_DICTATION_WAITING_SETTING];
        
    }
    if (![[NSUserDefaults standardUserDefaults] boolForKey:CONFIRM_BEFORE_SAVING_SETTING_ALTERED])// to set confirm before saving setting on by default, if user not aletered the setting then put it on
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CONFIRM_BEFORE_SAVING_SETTING];
    }
    if (![[NSUserDefaults standardUserDefaults] boolForKey:LOGIN_EVERYTIME_SETTING_ALTERED])// to set confirm before saving setting on by default, if user not aletered the setting then put it on
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LOGIN_EVERYTIME];
    }
        if ([[NSUserDefaults standardUserDefaults] valueForKey:PURGE_DELETED_DATA]== NULL)
        {
            [[NSUserDefaults standardUserDefaults] setValue:@"15 days" forKey:PURGE_DELETED_DATA];
//             [[Database shareddatabase] addDictationStatus:@"RecordingFileUploaded"];
//             [[Database shareddatabase] updateUploadingStuckedStatus];// to resolve the previous build bug
//             [[Database shareddatabase] createFileNameidentifierRelationshipTable];
    
        }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoadedFirstTime"];
    
    ThreadStateInitalize();
    
    try {
        NSError *error = nil;
        
        // Configure the audio session
        AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
        
        // our default category -- we change this for conversion and playback appropriately
        [sessionInstance setCategory:AVAudioSessionCategoryAudioProcessing error:&error];
        XThrowIfError(error.code, "couldn't set audio category");
        //
        // add interruption handler
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleInterruption:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:sessionInstance];
        
        // we don't do anything special in the route change notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRouteChange:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:sessionInstance];
        
        // the session must be active for offline conversion
        [sessionInstance setActive:YES error:&error];
        XThrowIfError(error.code, "couldn't set audio session active\n");
        
    } catch (CAXException e) {
        char buf[256];
        fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
        printf("You probably want to fix this before continuing!");
    }
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (![AppPreferences sharedAppPreferences].isImporting)
        {
            [self getImportedFiles];
            
        }
        
    });
    
    [self cancelTasks];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadNextFile) name:NOTIFICATION_UPLOAD_NEXT_FILE object:nil];
    
    [self setStatusBarBackgroundColor:[UIColor colorWithRed:0/255.0 green:16/255.0 blue:133/255.0 alpha:1.0]];
    
    
    
    return YES;
}


- (void)setStatusBarBackgroundColor:(UIColor *)color
{
    
//    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//
//    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
//        statusBar.backgroundColor = color;
//    }
    
    if (@available(iOS 13.0, *)) {
        UIView *statusBar = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame] ;
        statusBar.backgroundColor = color;
        [[UIApplication sharedApplication].keyWindow addSubview:statusBar];
    } else {
            UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        
            if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
                statusBar.backgroundColor = color;
            }
    }
    
    
}

-(void)uploadNextFile
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        if ([AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count>0)
        {


                NSString* nextFileToBeUpload1 = [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray objectAtIndex:0];

                [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray removeObjectAtIndex:0];

                [[APIManager sharedManager] uploadFileToServer:nextFileToBeUpload1 jobName:FILE_UPLOAD_API];

        }

    });
}

//-(void)uploadNextFile
//{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//        if ([AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count>0)
//        {
//
//            if ([AppPreferences sharedAppPreferences].filesInUploadingQueueArray.count<1 && [AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count>1)
//            {
//
//                NSString* nextFileToBeUpload = [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray objectAtIndex:0];
//
//                [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray removeObjectAtIndex:0];
//
//                [[APIManager sharedManager] uploadFileToServer:nextFileToBeUpload jobName:FILE_UPLOAD_API];
//
//                NSString* nextFileToBeUpload1 = [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray objectAtIndex:0];
//
//                [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray removeObjectAtIndex:0];
//
//                [[APIManager sharedManager] uploadFileToServer:nextFileToBeUpload1 jobName:FILE_UPLOAD_API];
//
//
//            }
//            else
//            {
//                NSString* nextFileToBeUpload = [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray objectAtIndex:0];
//
//                [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray removeObjectAtIndex:0];
//
//                [[APIManager sharedManager] uploadFileToServer:nextFileToBeUpload jobName:FILE_UPLOAD_API];
//            }
//
//
//        }
//        else
//        {
//        }
//
//    });
//}

- (void) checkAndCopyDatabase
{
    NSString *destpath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Cube_DB.sqlite"];
    
    NSString *sourcepath=[[NSBundle mainBundle]pathForResource:@"Cube_DB" ofType:@"sqlite"];
    NSLog(@"%@",NSHomeDirectory());
    if(![[NSFileManager defaultManager] fileExistsAtPath:destpath])
    {
        //  NSLog(@"%@",NSHomeDirectory());
        [[NSFileManager defaultManager] copyItemAtPath:sourcepath toPath:destpath error:nil];
        
        
    }
    
    [[Database shareddatabase] updateUploadingFileDictationStatus];
    
    [self updateDatabaseIfAny];
//     [[Database shareddatabase] updateUploadingStuckedStatus];
    
    // to resolve the previous build bug
    //    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isVRSDeptColumnAdded"]) {
    //
    //        //call the query like ALTER TABLE tableName ADD COLUMN columnName TEXT;
    //        [[Database shareddatabase] AlterVRSTextFilesTableForDepartmentName];
    //        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"isVRSDeptColumnAdded"];
    //        [[NSUserDefaults standardUserDefaults] synchronize];
    //    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PAUSE_AUDIO_PALYER object:nil];//to pause and remove audio player
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PAUSE_AUDIO_PALYER object:nil];//to pause and remove audio player
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PAUSE_RECORDING object:nil];//to pause audio player and save the recording from bg.we have change the setting for this in app capabilities setting to stop from the bg.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STOP_VRS object:nil];//to pause audio player and save the recording from bg.we have change the setting for this in app capabilities setting to stop from the bg.
    
    if([AppPreferences sharedAppPreferences].userObj!=nil)
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLoadedFirstTime"];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:APPLICATION_TERMINATE_CALLED];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoadedFirstTime"];
    
    
    [AppPreferences sharedAppPreferences].userObj.userPin=nil;
    
    [self cancelTasks];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SAVE_RECORDING object:nil];
    
}

- (void)cancelTasks {
    
    [[SharedSession getSharedSession:[APIManager sharedManager]] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        
        if (!uploadTasks || !uploadTasks.count) {
            return;
        }
        for (NSURLSessionUploadTask *task in uploadTasks) {
            [task cancel];
        }
    }];
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
    if (![AppPreferences sharedAppPreferences].isImporting)
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
            
            
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isLoadedFirstTime"] && [AppPreferences sharedAppPreferences].userObj.userPin!=NULL)
            {
                LoginViewController* loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                
                UIViewController *topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                while (topRootViewController.presentedViewController)
                {
                    topRootViewController = topRootViewController.presentedViewController;
                }
                
                //to avoid double pin login screen show: if kept in background by just openig login view
                if (![topRootViewController isKindOfClass: [LoginViewController class]])
                {
                    if([[NSUserDefaults standardUserDefaults] boolForKey:LOGIN_EVERYTIME])// if settings on then only show login screen
                    {
                        loginViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                        [topRootViewController presentViewController:loginViewController animated:YES completion:nil];
                    }
                    
                    
                }
            }
            
            
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
                       {
                           
                           [self getImportedFiles];
                           
                       });
        
    }
    
    else
    {
        //dispatch_async(dispatch_get_main_queue(), ^{
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isLoadedFirstTime"] && [AppPreferences sharedAppPreferences].userObj.userPin!=NULL)
        {
            LoginViewController* loginViewController=[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            
            UIViewController *topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            while (topRootViewController.presentedViewController)
            {
                topRootViewController = topRootViewController.presentedViewController;
            }
            
            //to avoid double pin login screen show: if kept in background by just openig login view
            if (![topRootViewController isKindOfClass: [LoginViewController class]])
            {
                if([[NSUserDefaults standardUserDefaults] boolForKey:LOGIN_EVERYTIME])// if settings on then only show login screen
                {
                    loginViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                                   [topRootViewController presentViewController:loginViewController animated:YES completion:nil];
                }
               
                
            }
        }
        // });
    }
    
}


- (void)handleInterruption:(NSNotification *)notification
{
    UInt8 theInterruptionType = [[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] intValue];
    
    printf("Session interrupted! --- %s ---\n", theInterruptionType == AVAudioSessionInterruptionTypeBegan ? "Begin Interruption" : "End Interruption");
    
    [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryPlayAndRecord];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PAUSE_RECORDING object:nil];//to pause audio player and save the recording from bg.we have change the setting for this in app capabilities setting to stop from the bg.
    
    //    if (theInterruptionType == AVAudioSessionInterruptionTypeBegan) {
    //        ThreadStateBeginInterruption();
    //    }
    
    //    if (theInterruptionType == AVAudioSessionInterruptionTypeEnded) {
    //        // make sure we are again the active session
    //        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    //        ThreadStateEndInterruption();
    //    }
}


#pragma mark -Audio Session Route Change Notification

- (void)handleRouteChange:(NSNotification *)notification
{
    UInt8 reasonValue = [[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] intValue];
    AVAudioSessionRouteDescription *routeDescription = [notification.userInfo valueForKey:AVAudioSessionRouteChangePreviousRouteKey];
    
    printf("Route change:\n");
    switch (reasonValue) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"     NewDeviceAvailable");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"     OldDeviceUnavailable");
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            NSLog(@"     CategoryChange");
            break;
        case AVAudioSessionRouteChangeReasonOverride:
            NSLog(@"     Override");
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            NSLog(@"     WakeFromSleep");
            break;
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            NSLog(@"     NoSuitableRouteForCategory");
            break;
        default:
            NSLog(@"     ReasonUnknown");
    }
    
    printf("\nPrevious route:\n");
    NSLog(@"%@", routeDescription);
}

//store the information
-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    //[SharedSession sharedSession] comp
    self.backgroundSessionCompletionHandler  = completionHandler;
    [SharedSession getSharedSession:[APIManager sharedManager]];
    NSLog(@"IDENTOFIER:   %@",identifier);
}



- (id)initWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    self = [super init];
    
    if(self)
    {
        // keep the block by copying it; release later if
        // you're not using ARC
        _completionHandler = completionHandler;
    }
    
    return self;
}

- (void)somethingThatHappensMuchLater
{
    _completionHandler(UIBackgroundFetchResultNewData);
}




-(void)getImportedFiles
{
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //
    
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_IDENTIFIER];
    
    //NSString* isfile=[sharedDefaults objectForKey:@"out"];
    //NSLog(@"%@",isfile);
    // NSString* sharedAudioFolderPathString=[sharedDefaults objectForKey:@"audioFolderPath"];
    
    NSDictionary* copy1Dict=[sharedDefaults objectForKey:@"isFileInsertedDict"];
    
    NSLog(@"check = %@",[sharedDefaults objectForKey:@"check"]);
    NSLog(@"%@",[sharedDefaults objectForKey:@"waveFileName"]);
    NSMutableDictionary* isFileInsertedDict=[copy1Dict mutableCopy];
    
    NSMutableDictionary* proxyIsFileInsertedDict=[copy1Dict mutableCopy];
    
    [AppPreferences sharedAppPreferences].isImporting = YES;
    
    for (NSString* wavFileName in [isFileInsertedDict allKeys])
    {
        NSString* fileExistFlag= [isFileInsertedDict valueForKey:wavFileName];
        
        if ([fileExistFlag isEqualToString:@"NO"])
        {
            [self convertToWavFileName:wavFileName];
            
            [self saveAudioRecordToDatabaseFileName:wavFileName];
            
            [proxyIsFileInsertedDict setObject:@"YES" forKey:wavFileName];
        }
        else
        {}
        
    }
    
    
    [AppPreferences sharedAppPreferences].isImporting = NO;
    
    // [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_IMPORTED object:nil];
    
    
    // got database error
    [[Database shareddatabase] getlistOfimportedFilesAudioDetailsArray:5];//get count of imported non transferred files
    
    
    [sharedDefaults setObject:proxyIsFileInsertedDict forKey:@"isFileInsertedDict"];
    
    [sharedDefaults synchronize];
    //
    // [[Database shareddatabase] getlistOfimportedFilesAudioDetailsArray:5];
    
    
    //                                [self dismissViewControllerAnimated:YES completion:nil];
    
    //  });
    
    
}

//
//-(void) convertToWav:(int)insertedFileCount
//{
//    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_IDENTIFIER];
//
//    NSString* sharedAudioFolderPathString=[sharedDefaults objectForKey:@"audioFolderPath"];
//
//    NSMutableArray* sharedAudioNamesArray=[NSMutableArray new];
//
//    sharedAudioNamesArray=[sharedDefaults objectForKey:@"audioNamesArray"];
//
//
//    for (long i=0+insertedFileCount; i<sharedAudioNamesArray.count; i++)
//    {
//
//        NSString* sharedAudioFileNameString=[NSString stringWithFormat:@"%@",[sharedAudioNamesArray objectAtIndex:i]];
//
//        NSURL* sharedAudioFolderPathUrl=[NSURL URLWithString:sharedAudioFolderPathString];
//
//
//        NSString* sharedAudioFilePathString=[sharedAudioFolderPathUrl.path stringByAppendingPathComponent:sharedAudioFileNameString];
//
//
//        NSURL* newAssetUrl = [NSURL fileURLWithPath:sharedAudioFilePathString];
//
//        audioFilePath=[NSString stringWithFormat:@"%@",newAssetUrl.path] ;
//
//        NSString* audioFilePathForDestination= [newAssetUrl.path stringByDeletingPathExtension];
//
//        audioFilePathForDestination=[NSString stringWithFormat:@"%@copied.caf",audioFilePathForDestination];
//
//        destinationFilePath= [NSString stringWithFormat:@"%@",audioFilePathForDestination];
//
//        destinationURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)destinationFilePath, kCFURLPOSIXPathStyle, false);
//
//        sourceURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)audioFilePath, kCFURLPOSIXPathStyle, false);
//
//        outputFormat = kAudioFormatMPEG4AAC;
//
//        sampleRate = 16000.0;
//
//        NSLog(@"%@",[sharedDefaults objectForKey:@"output1"]);
//
//        OSStatus error = DoConvertFile(sourceURL, destinationURL, outputFormat, sampleRate);
//
//        NSError* error1;
//
//        if (error)
//        {
//
//            NSLog(@"%d", (int)error);
//            //return false;
//        }
//
//        else
//        {
//            NSLog(@"Converted");
//
//            NSError* error;
//
//            NSString* folderPath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:AUDIO_FILES_FOLDER_NAME]];
//
//            if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
//
//                [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
//
//            NSString* originalFileNameString=[sharedAudioFilePathString lastPathComponent];//store on same name as shared file name
//
//
//            NSString* homeDirectoryFileName=[sharedAudioFilePathString lastPathComponent];//store on same name as shared file name
//
//            homeDirectoryFileName=[homeDirectoryFileName stringByDeletingPathExtension];
//
//            if ([[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.caf",AUDIO_FILES_FOLDER_NAME,homeDirectoryFileName]]])
//            {
//                [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.caf",AUDIO_FILES_FOLDER_NAME,homeDirectoryFileName]] error:nil];
//            }
//
//            [[NSFileManager defaultManager] copyItemAtPath:destinationFilePath toPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.caf",AUDIO_FILES_FOLDER_NAME,homeDirectoryFileName]] error:&error1];
//
//            NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_IDENTIFIER];
//
//            NSDictionary* copyDict=[sharedDefaults objectForKey:@"updatedFileDict"];
//
//            NSMutableDictionary* updatedFileDict=[copyDict mutableCopy];
//
//            [updatedFileDict setObject:@"NO" forKey:originalFileNameString];
//
//            [sharedDefaults setObject:updatedFileDict forKey:@"updatedFileDict"];
//
//            [sharedDefaults synchronize];
//
//            //return true;
//        }
//
//    }
//
//}


//
//-(void)setCompressAudioFileName:(NSString*)audioFileNameString
//{
//    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_IDENTIFIER];
//
//    NSString* sharedAudioFolderPathString=[sharedDefaults objectForKey:@"audioFolderPath"];
//
//    NSMutableArray* sharedAudioNamesArray=[NSMutableArray new];
//
//    sharedAudioNamesArray=[sharedDefaults objectForKey:@"audioNamesArray"];
//
//    NSString* sharedAudioFileNameString=[NSString stringWithFormat:@"%@",audioFileNameString];
//
//    NSURL* sharedAudioFolderPathUrl=[NSURL URLWithString:sharedAudioFolderPathString];
//
//
//    NSString* sharedAudioFilePathString=[sharedAudioFolderPathUrl.path stringByAppendingPathComponent:sharedAudioFileNameString];
//
//
//    NSURL* newAssetUrl = [NSURL fileURLWithPath:sharedAudioFilePathString];
//
//    audioFilePath=[NSString stringWithFormat:@"%@",newAssetUrl.path] ;
//
//    NSString* audioFilePathForDestination= [newAssetUrl.path stringByDeletingPathExtension];
//
//    audioFilePathForDestination=[NSString stringWithFormat:@"%@copied.caf",audioFilePathForDestination];
//
//    destinationFilePath= [NSString stringWithFormat:@"%@",audioFilePathForDestination];
//
//    destinationURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)destinationFilePath, kCFURLPOSIXPathStyle, false);
//
//    sourceURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)audioFilePath, kCFURLPOSIXPathStyle, false);
//
//    outputFormat = kAudioFormatMPEG4AAC;
//
//    sampleRate = 16000.0;
//
//    NSLog(@"%@",[sharedDefaults objectForKey:@"output1"]);
//
//    OSStatus error = DoConvertFile(sourceURL, destinationURL, outputFormat, sampleRate);
//
//    NSError* error1;
//
//    if (error)
//    {
//
//        NSLog(@"%d", (int)error);
//        //return false;
//    }
//
//    else
//    {
//        NSLog(@"Converted");
//
//        NSError* error;
//
//        NSString* folderPath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:AUDIO_FILES_FOLDER_NAME]];
//
//        if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
//
//            [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
//
//        NSString* originalFileNameString=[sharedAudioFilePathString lastPathComponent];//store on same name as shared file name
//
//
//        NSString* homeDirectoryFileName=[sharedAudioFilePathString lastPathComponent];//store on same name as shared file name
//
//        homeDirectoryFileName=[homeDirectoryFileName stringByDeletingPathExtension];
//
//        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.caf",AUDIO_FILES_FOLDER_NAME,homeDirectoryFileName]]])
//        {
//            [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.caf",AUDIO_FILES_FOLDER_NAME,homeDirectoryFileName]] error:nil];
//        }
//
//        [[NSFileManager defaultManager] copyItemAtPath:destinationFilePath toPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.caf",AUDIO_FILES_FOLDER_NAME,homeDirectoryFileName]] error:&error1];
//
//        if ([[NSFileManager defaultManager] fileExistsAtPath:destinationFilePath])
//        {
//            [[NSFileManager defaultManager] removeItemAtPath:destinationFilePath error:&error];//remove temporary file which was used to store compression result
//        }
//        if ([[NSFileManager defaultManager] fileExistsAtPath:audioFilePath])
//        {
//            [[NSFileManager defaultManager] removeItemAtPath:audioFilePath error:&error];//remove file stored at shared storage(i.e. in path extension)
//        }
//
//        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_IDENTIFIER];
//
//        NSDictionary* copyDict=[sharedDefaults objectForKey:@"updatedFileDict"];
//
//        NSMutableDictionary* updatedFileDict=[copyDict mutableCopy];
//
//        [updatedFileDict setObject:@"NO" forKey:originalFileNameString];
//
//        [sharedDefaults setObject:updatedFileDict forKey:@"updatedFileDict"];
//
//        [sharedDefaults synchronize];
//
//        //return true;
//    }
//
//
//
//}


-(void)prepareAudioPlayer:(NSString*)filePath
{
    
    [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryAudioProcessing];
    
    NSData* audioData=[NSData dataWithContentsOfFile:filePath];
    
    NSError* error;
    
    [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryPlayback];
    
    player = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
    
    [player prepareToPlay];
    
}







-(void) convertToWavFileName:(NSString*)fileNAme
{
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_IDENTIFIER];
    
    NSString* sharedAudioFolderPathString=[sharedDefaults objectForKey:@"audioFolderPath"];
    
    NSMutableArray* sharedAudioNamesArray=[NSMutableArray new];
    
    sharedAudioNamesArray=[sharedDefaults objectForKey:@"audioNamesArray"];
    
    
    
    
    NSString* sharedAudioFileNameString=fileNAme;
    
    NSURL* sharedAudioFolderPathUrl=[NSURL URLWithString:sharedAudioFolderPathString];
    
    
    NSString* sharedAudioFilePathString=[sharedAudioFolderPathUrl.path stringByAppendingPathComponent:sharedAudioFileNameString];
    
    
    NSURL* newAssetUrl = [NSURL fileURLWithPath:sharedAudioFilePathString];
    
    audioFilePath=[NSString stringWithFormat:@"%@",newAssetUrl.path] ;
    
    NSString* audioFilePathForDestination= [newAssetUrl.path stringByDeletingPathExtension];
    
    audioFilePathForDestination=[NSString stringWithFormat:@"%@copied.caf",audioFilePathForDestination];
    
    destinationFilePath= [NSString stringWithFormat:@"%@",audioFilePathForDestination];
    
    destinationURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)destinationFilePath, kCFURLPOSIXPathStyle, false);
    
    sourceURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)audioFilePath, kCFURLPOSIXPathStyle, false);
    
    outputFormat = kAudioFormatMPEG4AAC;
    
    sampleRate = 16000.0;
    
    NSLog(@"%@",[sharedDefaults objectForKey:@"output1"]);
    
    OSStatus error = DoConvertFile(sourceURL, destinationURL, outputFormat, sampleRate);
    
    NSError* error1;
    
    if (error)
    {
        
        NSLog(@"%d", (int)error);
        //return false;
    }
    
    else
    {
        NSLog(@"Converted");
        
        NSError* error;
        
        NSString* folderPath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:AUDIO_FILES_FOLDER_NAME]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
            
            [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        
        NSString* originalFileNameString=[sharedAudioFilePathString lastPathComponent];//store on same name as shared file name
        
        
        NSString* homeDirectoryFileName=[sharedAudioFilePathString lastPathComponent];//store on same name as shared file name
        
        homeDirectoryFileName=[homeDirectoryFileName stringByDeletingPathExtension];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.caf",AUDIO_FILES_FOLDER_NAME,homeDirectoryFileName]]])
        {
            [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.caf",AUDIO_FILES_FOLDER_NAME,homeDirectoryFileName]] error:nil];
        }
        
        [[NSFileManager defaultManager] copyItemAtPath:destinationFilePath toPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.caf",AUDIO_FILES_FOLDER_NAME,homeDirectoryFileName]] error:&error1];
        
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_IDENTIFIER];
        
        NSDictionary* copyDict=[sharedDefaults objectForKey:@"updatedFileDict"];
        
        NSMutableDictionary* updatedFileDict=[copyDict mutableCopy];
        
        [updatedFileDict setObject:@"NO" forKey:originalFileNameString];
        
        [sharedDefaults setObject:updatedFileDict forKey:@"updatedFileDict"];
        
        [sharedDefaults synchronize];
        
        //return true;
    }
    
    
    
}




-(void)saveAudioRecordToDatabaseFileName:(NSString*) fileNAme
{
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_IDENTIFIER];
//
//    NSMutableArray* sharedAudioNamesArray=[NSMutableArray new];
//
//    NSMutableDictionary* sharedAudioNamesAndDateDict=[NSMutableDictionary new];
//
//    sharedAudioNamesArray=[sharedDefaults objectForKey:@"audioNamesArray"];
//
//    sharedAudioNamesAndDateDict=[sharedDefaults objectForKey:@"audioNamesAndDateDict"];
//
//    NSLog(@"%ld",sharedAudioNamesAndDateDict.count);
    
    
    NSString* originalFileName=fileNAme;
    
    
    fileName=[originalFileName stringByDeletingPathExtension];
    
    NSString* sharedAudioFilePathString= [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.caf",AUDIO_FILES_FOLDER_NAME,fileName]];
    
    NSString* filePath=sharedAudioFilePathString;
    
    uint64_t freeSpaceUnsignLong= [[APIManager sharedManager] getFileSize:filePath];
    long fileSizeinKB=freeSpaceUnsignLong;
    
    [self prepareAudioPlayer:sharedAudioFilePathString];//initiate audio player with current recording to get currentAudioDuration
    
    
    NSMutableDictionary* dateAndFileNAmeDict=[sharedDefaults objectForKey:@"audioNamesAndDateDict"];
    
    NSString* updatedDate = [dateAndFileNAmeDict objectForKey:originalFileName];
    
    NSString* recordCreatedDateString = updatedDate;//recording createdDate
    
    NSString* recordingDate=@"";//recording updated date
    
    int dictationStatus=5;
    
    int transferStatus=0;
    
    int deleteStatus=0;
    
    NSString* deleteDate=@"";
    
    NSString* transferDate=@"";
    
    NSString *currentDuration1=[NSString stringWithFormat:@"%f",player.duration];
    
    NSURL* fileURL=[NSURL URLWithString:[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL
                                                options:[NSDictionary dictionaryWithObjectsAndKeys:
                                                         [NSNumber numberWithBool:YES],
                                                         AVURLAssetPreferPreciseDurationAndTimingKey,
                                                         nil]];

    NSTimeInterval durationInSeconds = player.duration;

    if (asset)
        durationInSeconds = CMTimeGetSeconds(asset.duration) ;
    
    NSString* fileSize=[NSString stringWithFormat:@"%ld",fileSizeinKB];
    
    int newDataUpdate=5; // for imported files status = 5
    
    int newDataSend=0;
    
    int mobileDictationIdVal;
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
    
    DepartMent *deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSString* departmentName=[[Database shareddatabase] getDepartMentIdFromDepartmentName:deptObj.departmentName];
    
    if (departmentName == NULL)
    {
        departmentName=@"0";
    }
    NSDictionary* audioRecordDetailsDict=[[NSDictionary alloc]initWithObjectsAndKeys:fileName,@"recordItemName",recordCreatedDateString,@"recordCreatedDate",recordingDate,@"recordingDate",transferDate,@"transferDate",[NSString stringWithFormat:@"%d",dictationStatus],@"dictationStatus",[NSString stringWithFormat:@"%d",transferStatus],@"transferStatus",[NSString stringWithFormat:@"%d",deleteStatus],@"deleteStatus",deleteDate,@"deleteDate",fileSize,@"fileSize",currentDuration1,@"currentDuration",[NSString stringWithFormat:@"%d",newDataUpdate],@"newDataUpdate",[NSString stringWithFormat:@"%d",newDataSend],@"newDataSend",[NSString stringWithFormat:@"%d",mobileDictationIdVal],@"mobileDictationIdVal",departmentName,@"departmentName",@"-1",@"templateId",@"0",@"priority",@"",@"comment",nil];
    
    [[Database shareddatabase] insertRecordingData:audioRecordDetailsDict];
    
    
    
    
}


- (void) updateDatabaseIfAny{
    int fromVersion = [[Database shareddatabase] getUserDatabaseSchemaVersion]; // get current version
     
    // allow migrations to fall thru switch cases to do a complete run
    // start with current version + 1
    //[self beginTransaction];
    switch (fromVersion + 1) {
        case 2:
            [[Database shareddatabase] addCommentColumnInCubeData];
            
//        case 3:
//
//
//        case 4:
//            {
//
//            }
    }

     [[Database shareddatabase] setUserDatabaseSchemaVersion:2];
//    [self setSchemaVersion];
    //[self endTransaction];
}
//-(void) application:(UIApplication *)application
//handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
//{
//    // You must re-establish a reference to the background session,
//    // or NSURLSessionDownloadDelegate and NSURLSessionDelegate methods will not be called
//    // as no delegate is attached to the session. See backgroundURLSession above.
//    NSURLSession *backgroundSession = [self backgroundURLSession];
//    
//    NSLog(@"Rejoining session with identifier %@ %@", identifier, backgroundSession);
//    
//    // Store the completion handler to update your UI after processing session events
//    [self addCompletionHandler:completionHandler forSession:identifier];
//}



//- (void)addCompletionHandler:(CompletionHandlerType)handler forSession:(NSString *)identifier
//{
//    if ([self.completionHandlerDictionary objectForKey:identifier]) {
//        NSLog(@"Error: Got multiple handlers for a single session identifier. This should not happen.\n");
//    }
//    
//    [self.completionHandlerDictionary setObject:handler forKey:identifier];
//}
//
//- (void)callCompletionHandlerForSession: (NSString *)identifier
//{
//    CompletionHandlerType handler = [self.completionHandlerDictionary objectForKey: identifier];
//    
//    if (handler) {
//        [self.completionHandlerDictionary removeObjectForKey: identifier];
//        NSLog(@"Calling completion handler for session %@", identifier);
//        handler();
//    }
//}


@end
