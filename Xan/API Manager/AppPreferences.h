//
//  AppPreferences.h
//  Communicator
//
//  Created by mac on 05/04/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "User.h"

@protocol AppPreferencesDelegate;

@interface AppPreferences : NSObject 
{
    id<AppPreferencesDelegate> alertDelegate;
}

@property (nonatomic,strong)    id<AppPreferencesDelegate> alertDelegate;

@property (nonatomic)           int     currentSelectedItem;

@property (nonatomic,assign)    BOOL                        isReachable;

@property(nonatomic,strong) NSString* bsackUpAudioFileName;
@property(nonatomic,strong) NSString* iniVector;
@property(nonatomic) BOOL isUpdateAvailable;
@property(nonatomic) __block NSInteger kAppITunesItemIdentifier;
@property (nonatomic,assign)    BOOL                        recordNew;
@property (nonatomic,assign)    BOOL                        recordingNew;  // may not used anywhere
@property (nonatomic,assign)    BOOL                        recordNewOffline;

@property (nonatomic)    int                                selectedTabBarIndex;
@property (nonatomic,assign)    BOOL                        isRecordView;
@property (nonatomic,assign)    BOOL                        fileUploading;
@property (nonatomic,assign)    BOOL                        dismissAudioDetails;
@property (nonatomic,assign)    BOOL                        isImporting;


@property (nonatomic,strong) NSMutableArray*                importedFilesAudioDetailsArray;
@property (nonatomic,strong) NSMutableDictionary*           fileNameSessionIdentifierDict;

@property (nonatomic,strong) NSMutableArray*           filesInUploadingQueueArray;
@property (nonatomic,strong) NSMutableArray*           filesInAwaitingQueueArray;
@property (nonatomic,strong) NSMutableArray*           inActiveDepartmentIdsArray;
@property (nonatomic,strong) NSMutableDictionary*      tempalateListDict;



@property (nonatomic, strong) User *userObj;
//@property(nonatomic,strong)NSURLSessionUploadTask *uploadTask;
+(AppPreferences *) sharedAppPreferences;

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;


-(void) showAlertViewWithTitle:(NSString *) title withMessage:(NSString *) message withCancelText:(NSString *) cancelText withOkText:(NSString *) okText withAlertTag:(int) tag;
-(void) showNoInternetMessage;
-(void) showHudWithTitle:(NSString*)title detailText:(NSString*)detailText;
-(void) startReachabilityNotifier;
-(void)createDatabaseReplica;
@end


@protocol AppPreferencesDelegate

@optional
-(void) appPreferencesAlertButtonWithIndex:(int) buttonIndex withAlertTag:(int) alertTag;
@end
