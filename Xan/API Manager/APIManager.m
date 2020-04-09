//
//  APIManager.m
//  Communicator
//
//  Created by mac on 05/04/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "APIManager.h"
#import "AppDelegate.h"
#import "Constants.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "DepartMent.h"
#import "UIDevice+Identifier.h"
#import "TransferListViewController.h"
#import "NSData+AES256.h"
#import "SharedSession.h"


@implementation APIManager
@synthesize incompleteFileTransferCount,inCompleteFileTransferNamesArray,transferFailedCount,todaysFileTransferCount,awaitingFileTransferCount,awaitingFileTransferNamesArray,deletedListArray,transferredListArray,responsesData,session;
static APIManager *singleton = nil;

// Shared method
+(APIManager *) sharedManager
{
    if (singleton == nil)
    {
        singleton = [[APIManager alloc] init];
        
        return singleton;
        //[[AppPreferences sharedAppPreferences] startReachabilityNotifier];
    }
    else
    
    
    return singleton;
}

// Init method
-(id) init
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
}

#pragma mark
#pragma mark ValidateUser API
#pragma mark

//-(void) validateUser:(NSString *) usernameString andPassword:(NSString *) passwordString
//{
//    if ([[AppPreferences sharedAppPreferences] isReachable])
//    {
//        NSArray *params = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"username=%@",usernameString], [NSString stringWithFormat:@"password=%@",passwordString] ,nil];
//
//        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:params,REQUEST_PARAMETER, nil];
//
//        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:USER_LOGIN_API withRequestParameter:dictionary withResourcePath:USER_LOGIN_API withHttpMethd:POST];
//        [downloadmetadatajob startMetaDataDownLoad];
//    }
//    else
//    {
//        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
//    }
//}


-(NSString*)getDateAndTimeString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    formatter.dateFormat = DATE_TIME_FORMAT;
    
    NSString* recordCreatedDateString = [formatter stringFromDate:[NSDate date]];
    
    return recordCreatedDateString;
}

-(uint64_t)getFileSize:(NSString*)filePath
{
    uint64_t totalSpace = 0;
//    uint64_t totalFreeSpace = 0;
    NSError *error = nil;

    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath  error:&error];

    if (dictionary)
    {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSize];
        
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];

    }
    else
    {
       // NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalSpace;
}

-(double)getFileDuration:(NSString*)fileNameString
{
    NSString* filePath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@",AUDIO_FILES_FOLDER_NAME,fileNameString]];
    
    NSURL* fileURL  = [NSURL fileURLWithPath:filePath];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL
                                                options:[NSDictionary dictionaryWithObjectsAndKeys:
                                                         [NSNumber numberWithBool:YES],
                                                         AVURLAssetPreferPreciseDurationAndTimingKey,
                                                         nil]];
    
  
    double durationInSeconds = CMTimeGetSeconds(asset.duration) ;
    
    return durationInSeconds;
    
}

-(NSString*)getFileDurationInHMSFormat:(int)duration
{
    int audioHour= duration / (60*60);
    int audioHourByMod= duration % (60*60);
    
    int audioMinutes = audioHourByMod / 60;
    int audioSeconds = audioHourByMod % 60;
    
    return [NSString stringWithFormat:@"(%02d:%02d:%02d)",audioHour,audioMinutes,audioSeconds];
    
}
-(NSString*)getMacId
{
   return [[UIDevice currentDevice] identifierForVendor1];

}

-(uint64_t)getFreeDiskspace
{
    uint64_t totalSpace = 0;
    
    uint64_t totalFreeSpace = 0;
    
    NSError *error = nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary)
    {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        
        totalFreeSpace=((totalFreeSpace/(1024ll))/1024ll);
        //        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    }
    else
    {
        // NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalFreeSpace;
}


-(BOOL)deleteFile:(NSString*)fileName
{
    NSError* error;
    NSString* filePath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,fileName]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return  false;
    }
    else
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        return true;
    }
}

-(BOOL)deleteDocxFile:(NSString*)fileName
{
    NSError* error;
//    NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.docx",DOCX_FILES_FOLDER_NAME,fileName]];
    NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.doc",DOCX_FILES_FOLDER_NAME,fileName]];

    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return  false;
    }
    else
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        return true;
    }
}
///// For ACE

-(void) testFileName:(NSString*)fileName
{
    self.responsesData = [NSMutableDictionary new];
    
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        [[[[UIApplication sharedApplication] keyWindow] viewWithTag:222] removeFromSuperview];//to remove no internet message
        
       
        
        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:fileName,@"fileName", nil];
        
        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
        
        NSString* downloadMethodType = @"urlConnection";
        
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:TEST_API withRequestParameter:array withResourcePath:TEST_API withHttpMethd:POST downloadMethodType:downloadMethodType];
        
        downloadmetadatajob.contentType   = CONTENT_TYPE_JSON;
        
        [downloadmetadatajob startMetaDataDownLoad];
        
    }
    
    //
    
    else
    {
        //UIView* internetMessageView=   [[PopUpCustomView alloc]initWithFrame:CGRectMake(12, 100, 200, 200) senderForInternetMessage:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERNET_MESSAGE object:nil];
        
        
    }
}
-(void) checkDeviceRegistrationMacID:(NSString*)macID
{
    
    self.responsesData = [NSMutableDictionary new];
    
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        [[[[UIApplication sharedApplication] keyWindow] viewWithTag:222] removeFromSuperview];//to remove no internet message
      
        NSData* macIdData = [macID dataUsingEncoding:NSUTF8StringEncoding];
        
        NSData *macIdEncData = [macIdData AES256EncryptWithKey:SECRET_KEY];
      
        NSString* macIdEncString = [macIdEncData base64EncodedStringWithOptions:0];
       
        NSString* initVector = [AppPreferences sharedAppPreferences].iniVector;
        
        macIdEncString = [[macIdEncString stringByAppendingString:@"__babacd_dcabab__"] stringByAppendingString:initVector];
        
        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:macIdEncString,@"macId", nil];
        
        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
        
        NSString* downloadMethodType = @"urlConnection";
        
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:CHECK_DEVICE_REGISTRATION_API withRequestParameter:array withResourcePath:CHECK_DEVICE_REGISTRATION_API withHttpMethd:POST downloadMethodType:downloadMethodType];
        
        downloadmetadatajob.contentType   = CONTENT_TYPE_JSON;

        [downloadmetadatajob startMetaDataDownLoad];
        
    }
    
    //
    
    else
    {
        //UIView* internetMessageView=   [[PopUpCustomView alloc]initWithFrame:CGRectMake(12, 100, 200, 200) senderForInternetMessage:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERNET_MESSAGE object:nil];
        
        
    }
    
}


//-(void) authenticateUserMacID:(NSString*) macID password:(NSString*) password username:(NSString* )username
//{
//    if ([[AppPreferences sharedAppPreferences] isReachable])
//    {
//        NSData* macIdData = [macID dataUsingEncoding:NSUTF8StringEncoding];
//        NSData* usernameData = [username dataUsingEncoding:NSUTF8StringEncoding];
//        NSData* passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
//
//        NSData *macIdEncData = [macIdData AES256EncryptWithKey:SECRET_KEY];
//
//        NSData *usernameEncData = [usernameData AES256EncryptWithKey:SECRET_KEY];
//
//        NSData *passwordEncData = [passwordData AES256EncryptWithKey:SECRET_KEY];
//
//        NSString* macIdEncString = [macIdEncData base64EncodedStringWithOptions:0];
//        NSString* usernameEncString = [usernameEncData base64EncodedStringWithOptions:0];
//        NSString* passwordEncString = [passwordEncData base64EncodedStringWithOptions:0];
//
//        macIdEncString =
//        [macIdEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
//
//        usernameEncString =
//        [usernameEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
//
//        passwordEncString =
//        [passwordEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
//
//        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:macIdEncString,@"macId",usernameEncString,@"userName",passwordEncString,@"password", nil];
//
//        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
//
//        NSString* downloadMethodType = @"urlConnection";
//
//        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:CHECK_USER_REGISTRATION_API withRequestParameter:array withResourcePath:CHECK_USER_REGISTRATION_API withHttpMethd:POST downloadMethodType:downloadMethodType];
//
//        downloadmetadatajob.contentType  =  = CONTENT_TYPE_JSON;
//
//        [downloadmetadatajob startMetaDataDownLoad];
//    }
//    else
//    {
//        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
//    }
//
//}

-(void) authenticateUserMacID:(NSString*) macID password:(NSString*) password username:(NSString* )username
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        NSData* macIdData = [macID dataUsingEncoding:NSUTF8StringEncoding];
        NSData* usernameData = [username dataUsingEncoding:NSUTF8StringEncoding];
        NSData* passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
        NSData* deviceTypeData = [@"iOS" dataUsingEncoding:NSUTF8StringEncoding];

        NSData *macIdEncData = [macIdData AES256EncryptWithKey:SECRET_KEY];
        NSString* macIdEncString = [macIdEncData base64EncodedStringWithOptions:0];
//        macIdEncString = [macIdEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        NSString* macIdIV = [AppPreferences sharedAppPreferences].iniVector;
        macIdEncString = [[macIdEncString stringByAppendingString:@"__babacd_dcabab__"] stringByAppendingString:macIdIV];

        NSData *usernameEncData = [usernameData AES256EncryptWithKey:SECRET_KEY];
        NSString* usernameEncString = [usernameEncData base64EncodedStringWithOptions:0];
//        usernameEncString = [usernameEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        NSString* usernameIV = [AppPreferences sharedAppPreferences].iniVector;
        usernameEncString = [[usernameEncString stringByAppendingString:@"__babacd_dcabab__"] stringByAppendingString:usernameIV];

        NSData *passwordEncData = [passwordData AES256EncryptWithKey:SECRET_KEY];
        NSString* passwordEncString = [passwordEncData base64EncodedStringWithOptions:0];
//        passwordEncString = [passwordEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        NSString* passwordIV = [AppPreferences sharedAppPreferences].iniVector;
        passwordEncString = [[passwordEncString stringByAppendingString:@"__babacd_dcabab__"] stringByAppendingString:passwordIV];
        
         NSData *deviceTypeEncData = [deviceTypeData AES256EncryptWithKey:SECRET_KEY];
                NSString* deviceTypeEncString = [deviceTypeEncData base64EncodedStringWithOptions:0];
        //        passwordEncString = [passwordEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                NSString* deviceTypeIV = [AppPreferences sharedAppPreferences].iniVector;
                deviceTypeEncString = [[deviceTypeEncString stringByAppendingString:@"__babacd_dcabab__"] stringByAppendingString:deviceTypeIV];

        //__babacd_dcabab__
        //        NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
        
        
        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:macIdEncString,@"macId",usernameEncString,@"userName",passwordEncString,@"password",deviceTypeEncString,@"deviceType", nil];
        
        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
        
        NSString* downloadMethodType = @"urlConnection";
        
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:CHECK_USER_REGISTRATION_API withRequestParameter:array withResourcePath:CHECK_USER_REGISTRATION_API withHttpMethd:POST downloadMethodType:downloadMethodType];
        
        downloadmetadatajob.contentType = CONTENT_TYPE_JSON;
        
        [downloadmetadatajob startMetaDataDownLoad];
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
}

-(void) generateDeviceToken:(NSString*)macId
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        NSData* macIdData = [macId dataUsingEncoding:NSUTF8StringEncoding];
        NSData *macIdEncData = [macIdData AES256EncryptWithKey:SECRET_KEY];
        NSString* macIdIV = [AppPreferences sharedAppPreferences].iniVector;
        NSString* macIdEncString = [macIdEncData base64EncodedStringWithOptions:0];
//        macIdEncString = [macIdEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        macIdEncString = [[macIdEncString stringByAppendingString:@"__babacd_dcabab__"] stringByAppendingString:macIdIV];

//
//        NSData* passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
//        NSData *passwordEncData = [passwordData AES256EncryptWithKey:SECRET_KEY];
//        NSString* passwordIV = [AppPreferences sharedAppPreferences].iniVector;
//        NSString* passwordEncString = [passwordEncData base64EncodedStringWithOptions:0];
//        passwordEncString = [passwordEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
//        passwordEncString = [[passwordEncString stringByAppendingString:@"__babacd_dcabab__"] stringByAppendingString:passwordIV];

        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:macIdEncString,@"macId", nil];
        
        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
        
        NSString* downloadMethodType = @"urlConnection";
        
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:GENERATE_DEVICE_TOKEN withRequestParameter:array withResourcePath:GENERATE_DEVICE_TOKEN withHttpMethd:POST downloadMethodType:downloadMethodType];
        
        downloadmetadatajob.contentType = CONTENT_TYPE_JSON;

        [downloadmetadatajob startMetaDataDownLoad];
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
}

-(void) acceptPinMacID:(NSString*) macID Pin:(NSString*)pin
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        NSData* macIdData = [macID dataUsingEncoding:NSUTF8StringEncoding];
        NSData *macIdEncData = [macIdData AES256EncryptWithKey:SECRET_KEY];
        NSString* macIdIV = [AppPreferences sharedAppPreferences].iniVector;
        NSString* macIdEncString = [macIdEncData base64EncodedStringWithOptions:0];
//        macIdEncString = [macIdEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        macIdEncString = [[macIdEncString stringByAppendingString:@"__babacd_dcabab__"] stringByAppendingString:macIdIV];

        NSData* pinData = [pin dataUsingEncoding:NSUTF8StringEncoding];
        NSData *pinEncData = [pinData AES256EncryptWithKey:SECRET_KEY];
        NSString* pinIV = [AppPreferences sharedAppPreferences].iniVector;
        NSString* pinEncString = [pinEncData base64EncodedStringWithOptions:0];
//        pinEncString = [pinEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        pinEncString = [[pinEncString stringByAppendingString:@"__babacd_dcabab__"] stringByAppendingString:pinIV];

        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:macIdEncString,@"macId",pinEncString,@"devicePin", nil];
        
        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
        
//        NSString* downloadMethodType = @"Bearer";
        
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:ACCEPT_PIN_API withRequestParameter:array withResourcePath:ACCEPT_PIN_API withHttpMethd:POST downloadMethodType:@""];
        
        downloadmetadatajob.contentType = CONTENT_TYPE_JSON;

        [downloadmetadatajob startMetaDataDownLoad];
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
}

-(void) acceptTandC:(NSString*) macID dateAndTIme:(NSString*)dateAndTime acceptFlag:(NSString*)acceptFlag
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        NSData* macIdData = [macID dataUsingEncoding:NSUTF8StringEncoding];
        NSData *macIdEncData = [macIdData AES256EncryptWithKey:SECRET_KEY];
        NSString* macIdIV = [AppPreferences sharedAppPreferences].iniVector;
        NSString* macIdEncString = [macIdEncData base64EncodedStringWithOptions:0];
//        macIdEncString = [macIdEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        macIdEncString = [[macIdEncString stringByAppendingString:@"__babacd_dcabab__"] stringByAppendingString:macIdIV];
        
        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:macIdEncString,@"macId",dateAndTime,@"dateAndTime",acceptFlag,@"acceptanceFl", nil];
        
        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
        
//        NSString* downloadMethodType = @"Bearer";
        
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:ACCEPY_TandC_API withRequestParameter:array withResourcePath:ACCEPY_TandC_API withHttpMethd:POST downloadMethodType:@""] ;
        
        downloadmetadatajob.contentType = CONTENT_TYPE_JSON;
        
        [downloadmetadatajob startMetaDataDownLoad];
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
}

-(void) validatePinMacID:(NSString*) macID Pin:(NSString*)pin
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        NSData* macIdData = [macID dataUsingEncoding:NSUTF8StringEncoding];
        NSData *macIdEncData = [macIdData AES256EncryptWithKey:SECRET_KEY];
        NSString* macIdIV = [AppPreferences sharedAppPreferences].iniVector;
        NSString* macIdEncString = [macIdEncData base64EncodedStringWithOptions:0];
//        macIdEncString = [macIdEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        macIdEncString = [[macIdEncString stringByAppendingString:@"__babacd_dcabab__"] stringByAppendingString:macIdIV];
        
        NSData* pinData = [pin dataUsingEncoding:NSUTF8StringEncoding];
        NSData *pinEncData = [pinData AES256EncryptWithKey:SECRET_KEY];
        NSString* pinIV = [AppPreferences sharedAppPreferences].iniVector;
        NSString* pinEncString = [pinEncData base64EncodedStringWithOptions:0];
//        pinEncString = [pinEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        pinEncString = [[pinEncString stringByAppendingString:@"__babacd_dcabab__"] stringByAppendingString:pinIV];
        
        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:macIdEncString,@"macId",pinEncString,@"devicePin", nil];
        
        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
        
//        NSString* downloadMethodType = @"Bearer";
        
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:VALIDATE_PIN_API withRequestParameter:array withResourcePath:VALIDATE_PIN_API withHttpMethd:POST downloadMethodType:@""] ;
        
        downloadmetadatajob.contentType = CONTENT_TYPE_JSON;

        [downloadmetadatajob startMetaDataDownLoad];
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
}

-(void)changePinOldPin:(NSString*)oldPin NewPin:(NSString*)newPin macID:(NSString*)macID
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {

        NSData* macIdData = [macID dataUsingEncoding:NSUTF8StringEncoding];
        NSData* oldPinData = [oldPin dataUsingEncoding:NSUTF8StringEncoding];
        NSData* newPinData = [newPin dataUsingEncoding:NSUTF8StringEncoding];
        
        NSData *macIdEncData = [macIdData AES256EncryptWithKey:SECRET_KEY];
        NSString* macIdEncString = [macIdEncData base64EncodedStringWithOptions:0];
        //        macIdEncString = [macIdEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        NSString* macIdIV = [AppPreferences sharedAppPreferences].iniVector;
        macIdEncString = [[macIdEncString stringByAppendingString:@"__babacd_dcabab__"] stringByAppendingString:macIdIV];
        
        NSData *oldPinEncData = [oldPinData AES256EncryptWithKey:SECRET_KEY];
        NSString* oldPinEncString = [oldPinEncData base64EncodedStringWithOptions:0];
        //        usernameEncString = [usernameEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        NSString* oldPinIV = [AppPreferences sharedAppPreferences].iniVector;
        oldPinEncString = [[oldPinEncString stringByAppendingString:@"__babacd_dcabab__"] stringByAppendingString:oldPinIV];
        
        NSData *newPinEncData = [newPinData AES256EncryptWithKey:SECRET_KEY];
        NSString* newPinEncString = [newPinEncData base64EncodedStringWithOptions:0];
        //        passwordEncString = [passwordEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        NSString* newPinIV = [AppPreferences sharedAppPreferences].iniVector;
        newPinEncString = [[newPinEncString stringByAppendingString:@"__babacd_dcabab__"] stringByAppendingString:newPinIV];
        
        //__babacd_dcabab__
        //        NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
        
        
        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:macIdEncString,@"macId",oldPinEncString,@"devicePin", newPinEncString,@"newDevicePin", nil];
        
        NSString* downloadMethodType = @"Bearer";


        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];

        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:PIN_CANGE_API withRequestParameter:array withResourcePath:PIN_CANGE_API withHttpMethd:POST downloadMethodType:downloadMethodType];
        
        downloadmetadatajob.contentType = CONTENT_TYPE_JSON;

        [downloadmetadatajob startMetaDataDownLoad];
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }



}

-(void)getTemplateByUserCode:(NSString*)macID
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        NSString* oldPin = @"ds";
        NSString* newPin = @"newPin";
        
        NSData* macIdData = [macID dataUsingEncoding:NSUTF8StringEncoding];
        NSData* oldPinData = [oldPin dataUsingEncoding:NSUTF8StringEncoding];
        NSData* newPinData = [newPin dataUsingEncoding:NSUTF8StringEncoding];
        
        NSData *macIdEncData = [macIdData AES256EncryptWithKey:SECRET_KEY];
        NSString* macIdEncString = [macIdEncData base64EncodedStringWithOptions:0];
        //        macIdEncString = [macIdEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        NSString* macIdIV = [AppPreferences sharedAppPreferences].iniVector;
        macIdEncString = [[macIdEncString stringByAppendingString:@"__babacd_dcabab__"] stringByAppendingString:macIdIV];
        
        NSData *oldPinEncData = [oldPinData AES256EncryptWithKey:SECRET_KEY];
        NSString* oldPinEncString = [oldPinEncData base64EncodedStringWithOptions:0];
        //        usernameEncString = [usernameEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        NSString* oldPinIV = [AppPreferences sharedAppPreferences].iniVector;
        oldPinEncString = [[oldPinEncString stringByAppendingString:@"__babacd_dcabab__"] stringByAppendingString:oldPinIV];
        
        NSData *newPinEncData = [newPinData AES256EncryptWithKey:SECRET_KEY];
        NSString* newPinEncString = [newPinEncData base64EncodedStringWithOptions:0];
        //        passwordEncString = [passwordEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        NSString* newPinIV = [AppPreferences sharedAppPreferences].iniVector;
        newPinEncString = [[newPinEncString stringByAppendingString:@"__babacd_dcabab__"] stringByAppendingString:newPinIV];
        
        //__babacd_dcabab__
        //        NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
        
        
        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:macIdEncString,@"macId",oldPinEncString,@"userName", newPinEncString,@"password", nil];
        
        NSString* downloadMethodType = @"Bearer";
        
        
        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
        
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:TEMPLATE_LIST_API withRequestParameter:array withResourcePath:TEMPLATE_LIST_API withHttpMethd:POST downloadMethodType:downloadMethodType];
        
        downloadmetadatajob.contentType = CONTENT_TYPE_JSON;
        
        [downloadmetadatajob startMetaDataDownLoad];
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
    
    
}

-(void)sendDictationIds:(NSString*)dictationIdArray
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        //[[AppPreferences sharedAppPreferences] showHudWithTitle:@"Loading Files" detailText:@"Please wait.."];
        
        NSString* macId = [[NSUserDefaults standardUserDefaults] valueForKey:@"MacId"];
        
        NSError* error;
        
        NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:macId,@"macid",dictationIdArray,@"DictationID", nil];
        
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                           options:0 // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        
        NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
        
        
        
        NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
        
        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
        
        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:SEND_DICTATION_IDS_API withRequestParameter:array withResourcePath:SEND_DICTATION_IDS_API withHttpMethd:POST downloadMethodType:@""];
        [downloadmetadatajob startMetaDataDownLoad];
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
    
}

-(void) downloadAudioFile
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
       
        NSString* macIdEncString = @"fileName";
      
        
       
        
        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:macIdEncString,@"fileName", nil];
        
        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
        
        //        NSString* downloadMethodType = @"Bearer";
        
        
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:AUDIO_DOWNLOAD_API withRequestParameter:array withResourcePath:AUDIO_DOWNLOAD_API withHttpMethd:POST downloadMethodType:@""] ;
        
        downloadmetadatajob.contentType = @"download";
        
        [downloadmetadatajob startMetaDataDownLoad];
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
}



-(void)downloadFileUsingConnection:(NSString*)mobielDictationIdVal
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        NSString* macId = [[NSUserDefaults standardUserDefaults] valueForKey:@"MacId"];
        
        NSError* error;
        
        NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:macId,@"macid",mobielDictationIdVal,@"DictationID", nil];
        
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                           options:0 // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        
        NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
        
        
        
        NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
        
        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
        
        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:FILE_DOWNLOAD_API withRequestParameter:array withResourcePath:FILE_DOWNLOAD_API withHttpMethd:POST downloadMethodType:@""];
        [downloadmetadatajob startMetaDataDownLoad];
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
    
}

-(void)sendComment:(NSString*)comment dictationId:(NSString*)mobielDictationIdVal
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        NSString* macId = [[NSUserDefaults standardUserDefaults] valueForKey:@"MacId"];
        
        NSError* error;
        
        NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:macId,@"macid",mobielDictationIdVal,@"DictationID",comment,@"strComment", nil];
        
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                           options:0 // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        
        NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
        
        
        
        NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
        
        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
        
        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
        
        [[AppPreferences sharedAppPreferences] showHudWithTitle:@"Submitting..." detailText:@"Please wait"];
        
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:SEND_COMMENT_API withRequestParameter:array withResourcePath:SEND_COMMENT_API withHttpMethd:POST downloadMethodType:@""];
        
        [downloadmetadatajob startMetaDataDownLoad];
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
    
}


//-(void)downloafFileUsingSession:(NSString*)mobielDictationIdVal
//{
//    if ([[AppPreferences sharedAppPreferences] isReachable])
//    {
//
//        NSError* error;
//
//        NSString* macId = [[NSUserDefaults standardUserDefaults] valueForKey:@"MacId"];
//
//        NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:macId,@"macid",mobielDictationIdVal,@"DictationID", nil];
//
//
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
//                                                           options:0 // Pass 0 if you don't care about the readability of the generated string
//                                                             error:&error];
//
//
//        NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
//
//
//
//        NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
//
//        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
//
//        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
//        NSString* downloadMethodType = @"urlSession";
//
//        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:FILE_DOWNLOAD_API withRequestParameter:array withResourcePath:FILE_DOWNLOAD_API withHttpMethd:POST downloadMethodType:downloadMethodType];
//       // [downloadmetadatajob startMetaDataDownLoad];
////        [downloadmetadatajob downloadFileUsingNSURLSession:@""];
//    }
//    else
//    {
//        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
//    }
//
//
//
//}







- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    
    
    if (!(data == nil))
    {
        NSString* taskIdentifier = [[NSString stringWithFormat:@"%@",session.configuration.identifier] stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)dataTask.taskIdentifier]];
        
        
        
        NSError* error1;
        result = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:&error1];
        
        NSString* returnCode= [result valueForKey:@"code"];
        
        if ([returnCode longLongValue]==200)
        {
//            NSString* idvalString= [result valueForKey:@"mobiledictationidval"];
            
            
            NSString* idvalString = @"0";

            NSString* date= [[APIManager sharedManager] getDateAndTimeString];
            Database* db=[Database shareddatabase];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               //NSLog(@"Reachable");
                               NSString* fileName = [[Database shareddatabase] getfileNameFromTaskIdentifier:taskIdentifier];
                               
//                                NSLog(@"Received Data filename = %@", fileName);
                
                               [db updateAudioFileUploadedStatus:@"Transferred" fileName:fileName dateAndTime:date mobiledictationidval:[idvalString longLongValue]];
                               
                               [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUploaded" fileName:fileName];
                               
                               
                               [[Database shareddatabase] deleteIdentifierFromDatabase:taskIdentifier];
                               
                               
                               if ([AppPreferences sharedAppPreferences].filesInUploadingQueueArray.count>0)
                               {
//                                   NSLog(@"End Receiving Data filename 1 = %@", fileName);
                                   
                                   [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
                                   
//                                   NSLog(@"End Receiving Data filename 2 = %@", fileName);
//                                   NSLog(@"Filename Removed from uploading queue = %@",fileName);
                               }
//                               else
//                               {
//                                   [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
//                               }
                               
                               if (fileName != nil)
                               {
                                 
                                   [[AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict removeObjectForKey:fileName];
                                 
                                   // NSLog(@"%@",[NSString stringWithFormat:@"%@ uploaded successfully",str]);
                                   
                                   [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:[NSString stringWithFormat:@"%@ uploaded successfully",fileName] withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
                               }
                               
                
                
                               [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:fileName];
                               
                               [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPLOAD_NEXT_FILE object:fileName];
                          
                           });
            
            
            
            
        }
        else
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               //NSLog(@"Reachable");
                               
                              
                               NSString* errorString = [result valueForKey:@"error"];
                                
                                NSString* messageString = [result valueForKey:@"message"];

                                NSString* failedMessage = @"File uploading failed";
                                if (errorString != nil) {
                                    failedMessage = [NSString stringWithFormat:@"%@, file uploading failed",errorString];
                                }
                                
                                if (errorString != nil && messageString != nil) {
                                    failedMessage = [NSString stringWithFormat:@"%@, %@, file uploading failed",errorString,messageString];
                                }
                                else if (messageString != nil){
                                    failedMessage = [NSString stringWithFormat:@"%@, file uploading failed",messageString];
                                    
                                }
                                              
               NSString* date= [[APIManager sharedManager] getDateAndTimeString];
               
               NSString* fileName = [[Database shareddatabase] getfileNameFromTaskIdentifier:taskIdentifier];
               
               [[Database shareddatabase] updateAudioFileUploadedStatus:@"NotTransferred" fileName:fileName dateAndTime:date mobiledictationidval:0];
               
               [[Database shareddatabase] updateAudioFileStatus:@"RecordingComplete" fileName:fileName];
               
               [[Database shareddatabase] deleteIdentifierFromDatabase:taskIdentifier];
               
               [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:fileName];
               
               [[AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict removeObjectForKey:fileName];
                               
                if(errorString==nil)
                {
                    errorString = @"";
                }
                if (messageString==nil)
                {
                    messageString = @"";
                }
                if ([errorString isEqualToString:@"Unauthorized"] || [messageString isEqualToString:@"Unauthorized"]) {
                    
                    
                      // if failed due to unauthorization then dont show it as failed
                    [[Database shareddatabase] updateAudioFileUploadedStatus:@"NotTransferred" fileName:fileName dateAndTime:date mobiledictationidval:0];
                    
                    [[Database shareddatabase] updateAudioFileStatus:@"RecordingComplete" fileName:fileName];
                    
                    [[Database shareddatabase] deleteIdentifierFromDatabase:taskIdentifier];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:fileName];
                    
                    [[AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict removeObjectForKey:fileName];
                    
                    failedMessage = @"Your session has timed out. Please login using your PIN and try again.";
                    
                     [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:failedMessage withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
                    
                       [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PAUSE_RECORDING object:nil];//to pause ongoing recording if any
                    
                       [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_FILE_UPLOAD_FAILED object:failedMessage];
                    
                 

                   
                }
                else
                {
                    [[Database shareddatabase] updateAudioFileUploadedStatus:@"TransferFailed" fileName:fileName dateAndTime:date mobiledictationidval:0];
                    
                    [[Database shareddatabase] updateAudioFileStatus:@"RecordingComplete" fileName:fileName];
                    
                    [[Database shareddatabase] deleteIdentifierFromDatabase:taskIdentifier];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:fileName];
                    
                    [[AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict removeObjectForKey:fileName];
                                      
                    
 [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:failedMessage withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        if ([AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count>0)
                        {
                            [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
                            
                            NSString* nextFileToBeUpload = [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray objectAtIndex:0];
                            
                            [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray removeObjectAtIndex:0];
                            
                            [self uploadFileToServer:nextFileToBeUpload jobName:FILE_UPLOAD_API];
                            
                        }
                        else
                        {
                            [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
                        }
                        
                    });
                                                   
                }
                            
                
                           });

        }

    }
    
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)dataTask didCompleteWithError:(NSError *)error
{
    //[dataTask resume];
    NSLog(@"error code:%ld",(long)error.code);
    
     NSString* taskIdentifier = [[NSString stringWithFormat:@"%@",session.configuration.identifier] stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)dataTask.taskIdentifier]];
    
    if (error)
    {
        if (error.code == -999)
        {
            NSLog(@"cancelled from app delegate");

            NSLog(@"%@",error.localizedDescription);

        }
        else
        {

            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString* fileName = [[Database shareddatabase] getfileNameFromTaskIdentifier:taskIdentifier];
                
                [[Database shareddatabase] updateAudioFileUploadedStatus:@"TransferFailed" fileName:fileName dateAndTime:@"" mobiledictationidval:0];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:fileName];
                
                //                    NSLog(@"%@",fileName);
                NSString* failedMessage = @"File uploading failed";
                if (error.localizedDescription != nil || ![error.localizedDescription isEqualToString:@""]) {
                    failedMessage = [NSString stringWithFormat:@"%@ file uploading failed",error.localizedDescription];
                }
                
                
                [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:failedMessage withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
                
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    if ([AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count>0)
                    {
                        
                        [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
                        
                        NSString* nextFileToBeUpload = [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray objectAtIndex:0];
                        
                        [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray removeObjectAtIndex:0];
                        
                        [self uploadFileToServer:nextFileToBeUpload jobName:FILE_UPLOAD_API];
                        
                    }
                    else
                    {
                        [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
                    }
                    
                });
                
                
                
            });

        }
        
    }
    else
    {
       
    }
    
}
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{

    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        float progress = (double)totalBytesSent / (double)totalBytesExpectedToSend;
        //NSLog(@"progress %f",progress);
        
        NSString* progressPercent= [NSString stringWithFormat:@"%f",progress*100];
        
        int progressPercentInInt=[progressPercent intValue];
        
        progressPercent=[NSString stringWithFormat:@"%d",progressPercentInInt];
        
        NSString* progressShow= [NSString stringWithFormat:@"%@%%",progressPercent];
        
        NSString* taskIdentifier = [[NSString stringWithFormat:@"%@",session.configuration.identifier] stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)task.taskIdentifier]];
    
        NSString* fileName = [[Database shareddatabase] getfileNameFromTaskIdentifier:taskIdentifier];

//        NSLog(@"%@: %@",fileName,progressPercent);
        
        
        if (([AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict.count==0))
        {
            [AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict = [NSMutableDictionary new];
            
            if (!(fileName== nil))
            {
                if ([progressShow isEqual:@"100%"])
                {
                    progressShow = @"99%";
                }
                [[AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict setValue:progressShow forKey:fileName];
            }
            
        }
        else
        {
            if (!(fileName== nil))
            {
                if ([progressShow isEqual:@"100%"])
                {
                    progressShow = @"99%";
                }
                [[AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict setValue:progressShow forKey:fileName];
            }
            
        }

    
    });
    
 

}

//update the UI
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"Background URL session %@ finished events.\n", session);
    
    if (session.configuration.identifier)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            
            
            appDelegate.backgroundSessionCompletionHandler();
        });
       
        // Call the handler we stored in -application:handleEventsForBackgroundURLSession:
        // [self callCompletionHandlerForSession:session.configuration.identifier];
    }
}

//-(void)uploadNextFile
//{
//    if ([AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count>0)
//    {
//        // [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
//        
//        NSString* nextFileToBeUpload = [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray objectAtIndex:0];
//        
//        [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray removeObjectAtIndex:0];
//        
//        [self uploadFileToServer:nextFileToBeUpload jobName:FILE_UPLOAD_API];
//        
//        NSLog(@"%ld",[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count);
//        
//    }
//    else
//    {
//        // [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
//    }
//    
//}

-(void)uploadFileToServerUsingNSURLSession:(NSString*)str
{
   
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           departmentId= [[Database shareddatabase] getDepartMentIdForFileName:str];
                           transferStatus=[[Database shareddatabase] getTransferStatus:str];
                           mobileDictationIdVal=[[Database shareddatabase] getMobileDictationIdFromFileName:str];
                           
                           dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                               
                               [self uploadFileAfterGettingdatabaseValues:str departmentID:departmentId transferStatus:transferStatus mobileDictationIdVal:mobileDictationIdVal isFileTypeAudio:YES];
//                               [self uploadFileAfterGettingdatabaseValues:str departmentID:-1 transferStatus:transferStatus mobileDictationIdVal:mobileDictationIdVal isFileTypeAudio:YES];
                               
                           });
                           
                       });
        

    
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
    
}

-(void)uploadFileAfterGettingdatabaseValues:(NSString*)filename departmentID:(NSString*)departmentID transferStatus:(int)transferStatus mobileDictationIdVal:(int)mobileDictationIdVal isFileTypeAudio:(BOOL)isFileTypeAudio
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
//    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    });
    
    NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,filename] ];
    
//    NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASE_URL_PATH, FILE_UPLOAD_API]];
    
    NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASE_URL_PATH, FILE_UPLOAD_API]];

    if (isFileTypeAudio == NO)
    {
        filePath = [NSHomeDirectory() stringByAppendingPathComponent:
                    [NSString stringWithFormat:@"Documents/%@/%@.Docx",DOCX_FILES_FOLDER_NAME,filename] ];
        
        url=[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASE_URL_PATH, DOCX_FILE_UPLOAD_API]];
        
    }
   
    
    NSString *boundary = [self generateBoundaryString];
    
    NSString* filenameForTaskIdentifier = filename;
    
    filename = [filename stringByAppendingPathExtension:@"wav"];
    
   
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    
    long filesizelong=[[APIManager sharedManager] getFileSize:filePath];
        
    int filesizeint=(int)filesizelong;
    
    NSString* macId = [[NSUserDefaults standardUserDefaults] valueForKey:@"MacId"];
    
//    switch (transferStatus)
//    {
//        case 0://if not transferred
//            transferStatus=1;
//            break;
//
//        case 1: //if transferred
//            transferStatus=5;
//            break;
//
//        case 2: // if failed
//            transferStatus=1;
//            break;
//            
//        case 3: //if resend
//            transferStatus=5;
//            break;
//
//        case 4: // if resendfailed
//            transferStatus=5;
//            break;
//
//        default:
//            transferStatus=5;
//            break;
//    }

    
    switch (transferStatus)
    {
        case 0://if not transferred
            transferStatus=1;
            break;
        
        case 1: //if transferred
            transferStatus=2;
            break;
            
        case 2: // if failed
            transferStatus=4;
            break;
            
        case 3: //if resend
            transferStatus=5;
            break;
            
        case 4: // if resendfailed
            transferStatus=4;
            break;
            
        default:
            transferStatus=1;
            break;
    }

    
    if ([departmentId  isEqual: @"0"])
    {
        departmentId= [[Database shareddatabase] getDepartMentIdForFileName:filenameForTaskIdentifier];
        
    }
    
    double duration = [self getFileDuration:filename];
    
    NSString* fileDuraion = [self getFileDurationInHMSFormat:duration];
    
    NSString* templateCode = [[Database shareddatabase] getTemplateIdFromFilename:filenameForTaskIdentifier];

//    NSString* deptName = [[Database shareddatabase] getDepartMentNameFromDepartmentId:departmentId];
    
//    if ([deptName isEqualToString:@"Unassigned"]) {
//        templateCode = @"-1";
//    }
    NSString* priorityId = [[Database shareddatabase] getPriorityIdFromFilename:filenameForTaskIdentifier];

    NSString* comment = [[Database shareddatabase] getCommentFromFilename:filenameForTaskIdentifier];
    
    NSDictionary *params = @{@"macId"     : macId,
                             @"fileSize" :[NSString stringWithFormat:@"%d", filesizeint],
                             @"fileDuration" :fileDuraion,
                             @"departmentID" : [NSString stringWithFormat:@"%@", departmentID],
                             @"transferStatus" : [NSString stringWithFormat:@"%d", transferStatus],
                             @"mobileDictationIdVal" : [NSString stringWithFormat:@"%d", mobileDictationIdVal],
                             @"templateCode" : templateCode,
                             @"urgentFl" : priorityId,
                             @"comment" : comment
                             };
    // NSString* authorisation=[NSString stringWithFormat:@"%@*%d*%ld*%d*%d",macId,filesizeint,deptObj.Id,1,0];
   
    

    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];

    //    NSError* error;
    
//     NSString* authorisationString = [NSString stringWithFormat:@"%@*%d*%d*%d*%d",macId,filesizeint,departmentID,transferStatus,mobileDictationIdVal];
//    NSData* authorisationData = [authorisationString dataUsingEncoding:NSUTF8StringEncoding];
//
//
//    NSData *authorisationEncData = [authorisationData AES256EncryptWithKey:SECRET_KEY];
//
//    NSString* authorisationEncString = [authorisationEncData base64EncodedStringWithOptions:0];
    
//    [request setValue:authorisationEncString forHTTPHeaderField:@"Authorization"];

    NSString* jwtToken = [[NSUserDefaults standardUserDefaults] objectForKey:JWT_TOKEN];


    [request setValue:[NSString stringWithFormat:@"Bearer %@", jwtToken] forHTTPHeaderField:@"Authorization"];
    
    
    // create body
    
    NSData *httpBody = [self createBodyWithBoundary:boundary parameters:params paths:@[filePath] fieldName:@"file"];
    
    request.HTTPBody = httpBody;
    
    
    session = [SharedSession getSharedSession:[APIManager sharedManager]];
    
    [request setHTTPMethod:@"POST"];
    
    NSLog(@"URL = %@", url);
    
    NSURLSessionUploadTask* uploadTask = [session uploadTaskWithRequest:request fromData:nil];

    NSString* taskIdentifier = [[NSString stringWithFormat:@"%@",session.configuration.identifier] stringByAppendingString:[NSString stringWithFormat:@"%lu", (unsigned long)uploadTask.taskIdentifier]];
    
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                      
                       [[Database shareddatabase] insertTaskIdentifier:[NSString stringWithFormat:@"%@",taskIdentifier] fileName:filenameForTaskIdentifier];
                   });
  
    [uploadTask resume];

}


- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{

    
}

-(void)uploadFileToServer:(NSString*)str jobName:(NSString*)jobName
{
//    NSLog(@"uploadFileToServer function API Manager");
    if ([AppPreferences sharedAppPreferences].filesInUploadingQueueArray.count<1)
    {
//        NSLog(@"loop1");
        [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray addObject:str];
        [self uploadFileToServerUsingNSURLSession:str];
        
    }
    else
    {
//        NSLog(@"loop2");
        [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray addObject:str];
    }
   

}

// for two files at a time
//-(void)uploadFileToServer:(NSString*)str jobName:(NSString*)jobName
//{
//    NSLog(@"uploadFileToServer function API Manager");
//    if ([AppPreferences sharedAppPreferences].filesInUploadingQueueArray.count<2)
//    {
//        NSLog(@"loop1");
//        if ([AppPreferences sharedAppPreferences].filesInUploadingQueueArray.count == 1)
//        {
//            NSLog(@"loop11");
//            NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:
//                                  [NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,[[AppPreferences sharedAppPreferences].filesInUploadingQueueArray objectAtIndex:0]] ];
//
//            long firstFileSize = [self getFileSize:filePath];
//
//            if (firstFileSize>30000000)
//            {
//                [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray addObject:str];
//            }
//
//            else
//            {
//                filePath = [NSHomeDirectory() stringByAppendingPathComponent:
//                            [NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,str]];
//                long secondFileSize = [self getFileSize:filePath];
//
//                if (secondFileSize>30000000)
//                {
//                    [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray addObject:str];
//                }
//
//                else
//                {
//                    [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray addObject:str];
//                    [self uploadFileToServerUsingNSURLSession:str];
//                }
//            }
//        }
//
//        else
//        {
//            NSLog(@"loop12");
//            [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray addObject:str];
//            [self uploadFileToServerUsingNSURLSession:str];
//        }
//
//    }
//    else
//    {
//        NSLog(@"loop2");
//        [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray addObject:str];
//    }
//    //[self uploadFileToServerUsingNSURLConnection:str];
//
//}



- (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                             paths:(NSArray *)paths
                         fieldName:(NSString *)fieldName
{
    NSMutableData *httpBody = [NSMutableData data];
    
    // add params (all params are strings)
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSData* encParamData = [parameterValue dataUsingEncoding:NSUTF8StringEncoding];
        
        encParamData = [encParamData AES256EncryptWithKey:SECRET_KEY];
        
        NSString* paramIV = [AppPreferences sharedAppPreferences].iniVector;
        NSString* paramEncString = [encParamData base64EncodedStringWithOptions:0];
        //        pinEncString = [pinEncString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        paramEncString = [[paramEncString stringByAppendingString:@"__babacd_dcabab__"] stringByAppendingString:paramIV];
        
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", paramEncString] dataUsingEncoding:NSUTF8StringEncoding]];
        
//        NSLog(@"paramEncString = %@", paramEncString);
    }];
    
    // add image data
    
    for (NSString *path in paths)
    {
        NSString *filename  = [path lastPathComponent];
        NSData   *data1      = [NSData dataWithContentsOfFile:path];
        
        NSData *data = [data1 AES256EncryptWithKey:SECRET_KEY];
        
        NSString* fileIV = [AppPreferences sharedAppPreferences].iniVector;

        filename = [[filename stringByAppendingString:@"__babacd_dcabab__"] stringByAppendingString:fileIV]; // append used IV to filename for server side dercyption

        NSString *mimetype  = [self mimeTypeForPath:path];
        
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:data];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return httpBody;
}


- (NSString *)mimeTypeForPath:(NSString *)path
{
    // get a mime type for an extension using MobileCoreServices.framework
    
    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);
    
    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    
    assert(mimetype != NULL);
    
    CFRelease(UTI);
    
    return mimetype;
}


- (NSString *)generateBoundaryString
{
    return [NSString stringWithFormat:@"*%@", [[NSUUID UUID] UUIDString]];
    //return [NSString stringWithFormat:@"*"];
    
}





-(void)uploadDocxFileToServer:(NSString*)docxFileName
{
    if ([AppPreferences sharedAppPreferences].filesInUploadingQueueArray.count<2)
    {
        if ([AppPreferences sharedAppPreferences].filesInUploadingQueueArray.count == 1)
        {
            NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:
                                  [NSString stringWithFormat:@"Documents/%@/%@",DOCX_FILES_FOLDER_NAME,[[AppPreferences sharedAppPreferences].filesInUploadingQueueArray objectAtIndex:0]] ];
            
            long firstFileSize = [[APIManager sharedManager] getFileSize:filePath];
            
            if (firstFileSize>30000000)
            {
                [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray addObject:docxFileName];
            }
            
            else
            {
                filePath = [NSHomeDirectory() stringByAppendingPathComponent:
                            [NSString stringWithFormat:@"Documents/%@/%@",DOCX_FILES_FOLDER_NAME,docxFileName]];
                
                long secondFileSize = [[APIManager sharedManager] getFileSize:filePath];
                
                if (secondFileSize>30000000)
                {
                    [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray addObject:docxFileName];
                }
                
                else
                {
                    [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray addObject:docxFileName];
                    
                    [self uploadDocxFileToServerUsingNSURLSession:docxFileName];
                }
            }
        }
        
        else
        {
            [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray addObject:docxFileName];
            
            [self uploadDocxFileToServerUsingNSURLSession:docxFileName];
        }
        
    }
    else
    {
        [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray addObject:docxFileName];
    }
    //[self uploadFileToServerUsingNSURLConnection:str];
    
}


-(void)uploadDocxFileToServerUsingNSURLSession:(NSString*)docxFileName
{
    
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                          NSString* departmentId= [[Database shareddatabase] getDepartMentIdForFileName:docxFileName];
                           
                          int mobileDictationIdVal=[[Database shareddatabase] getMobileDictationIdFromFileName:docxFileName];

                           NSString* downloadMethodType = @"urlConnection";
                           
                           NSArray * requestParamArray = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%@",departmentId], [NSString stringWithFormat:@"%d",mobileDictationIdVal], nil];
                           
                           dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                               
                                DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:DOCX_FILE_UPLOAD_API withRequestParameter:requestParamArray withResourcePath:DOCX_FILE_UPLOAD_API withHttpMethd:POST downloadMethodType:downloadMethodType];
                               
                               NSDictionary *params = @{@"filename"     : docxFileName,
                                                                                     };
                               
                               downloadmetadatajob.requestParameter = params;
                               
//                               [downloadmetadatajob uploadDocxFileAfterGettingdatabaseValues:docxFileName];
                               
                           });
                           
                       });
        
        
        
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
    
}

/*
-(void)uploadFileToServerUsingNSURLConnection:(NSString*)str

{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        
        NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,str] ];
        
        NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASE_URL_PATH, FILE_UPLOAD_API]];
        
        NSString *boundary = [self generateBoundaryString];
        
        NSDictionary *params = @{@"filename"     : str,
                                 };
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        
        [request setHTTPMethod:@"POST"];
        
        long filesizelong = [[APIManager sharedManager] getFileSize:filePath];
        
        int filesizeint=(int)filesizelong;
        
        int departmentId= [[Database shareddatabase] getDepartMentIdForFileName:str];
        
        NSString* macId = [[NSUserDefaults standardUserDefaults] valueForKey:@"MacId"];

        //NSString* macId=[Keychain getStringForKey:@"udid"];
        transferStatus=[[Database shareddatabase] getTransferStatus:str];
        if (transferStatus==0)
            transferStatus=1;
        else if(transferStatus==1)
        {
            transferStatus=5;
        }
        else if(transferStatus==3)
        {
            transferStatus=5;
        }
        else if(transferStatus==2)
        {
            transferStatus=1;
        }
        int mobileDictationIdVal=[[Database shareddatabase] getMobileDictationIdFromFileName:str];
        
        
        
        // NSString* authorisation=[NSString stringWithFormat:@"%@*%d*%ld*%d*%d",macId,filesizeint,deptObj.Id,1,0];
        NSString* authorisation=[NSString stringWithFormat:@"%@*%d*%d*%d*%d",macId,filesizeint,departmentId,transferStatus,mobileDictationIdVal];
        
        
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        //    NSError* error;
        
        
        NSData* jsonData=[authorisation dataUsingEncoding:NSUTF8StringEncoding];
        
        
        NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
        
        
        
        NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
        
        [request setValue:str2 forHTTPHeaderField:@"Authorization"];
        
        // create body
        
        NSData *httpBody = [self createBodyWithBoundary:boundary parameters:params paths:@[filePath] fieldName:str];
        
        request.HTTPBody = httpBody;
        
        

        
        
        
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (connectionError)
                {
        
        
        //            [[Database shareddatabase] updateAudioFileUploadedStatus:@"TransferFailed" fileName:str dateAndTime:@"" mobiledictationidval:0];
                    //-1001 for request time out and -1005 network connection lost
                    if (connectionError.code==-1001 || connectionError.code==-1005)
                    {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
                             [UIApplication sharedApplication].idleTimerDisabled = YES;
                            [self uploadFileToServer:str jobName:FILE_UPLOAD_API];
                        });
                    }
                    else
                    {
                       // [UIApplication sharedApplication].idleTimerDisabled = NO;
        
                        NSString* date= [[APIManager sharedManager] getDateAndTimeString];
        
                        [[Database shareddatabase] updateAudioFileUploadedStatus:@"TransferFailed" fileName:str dateAndTime:date mobiledictationidval:0];
        
                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:response];
        
                    [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:[NSString stringWithFormat:@"File uploading failed, %@",connectionError.localizedDescription] withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
                    }
                    NSLog(@"error = %@", connectionError);
        
                    return;
                }
        
                NSError* error;
                NSString* encryptedString = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingAllowFragments
                                                           error:&error];
              
        
        
                NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encryptedString options:0];
                NSData* data1=[decodedData AES256DecryptWithKey:SECRET_KEY];
                NSString* responseString=[[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
                responseString=[responseString stringByReplacingOccurrencesOfString:@"True" withString:@"1"];
                responseString=[responseString stringByReplacingOccurrencesOfString:@"False" withString:@"0"];
        
                NSData *responsedData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        
                result = [NSJSONSerialization JSONObjectWithData:responsedData
                                                           options:NSJSONReadingAllowFragments
                                                             error:&error];
        
                NSString* returnCode= [result valueForKey:@"code"];
        
                if ([returnCode longLongValue]==200)
                {
                    NSString* idvalString= [result valueForKey:@"mobiledictationidval"];
                    NSString* date= [[APIManager sharedManager] getDateAndTimeString];
                    Database* db=[Database shareddatabase];
                    [db updateAudioFileUploadedStatus:@"Transferred" fileName:str dateAndTime:date mobiledictationidval:[idvalString longLongValue]];
                    [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUploaded" fileName:str];
        
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:response];
                   // NSLog(@"%@",[NSString stringWithFormat:@"%@ uploaded successfully",str]);
        
                    [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:[NSString stringWithFormat:@"%@ uploaded successfully",str] withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
                  
                    
                }
                else
                {
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
                     [[Database shareddatabase] updateAudioFileUploadedStatus:@"TransferFailed" fileName:str dateAndTime:@"" mobiledictationidval:0];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:response];
        
                    NSLog(@"%@",str);
        
                    NSLog(@"%@",result);
                  [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:@"File uploading failed" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
                }
                
            }];
        
        
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
    
}

*/




//***********************
//        NSURLSessionConfiguration * backgroundConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"task1"];
//        NSURLSession *session = [NSURLSession sharedSession];
//        //
//        //
//        [request setHTTPMethod:@"POST"];
//
//        [AppPreferences sharedAppPreferences].uploadTask = [session uploadTaskWithRequest:request fromData:nil];
//
//        [ [AppPreferences sharedAppPreferences].uploadTask resume];

//        [AppPreferences sharedAppPreferences].uploadTask = [session         uploadTaskWithRequest:request fromData:nil completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
//        {
//            //Perform operations on your response here
//
//            if (error)
//            {
//
//
//
//                if (error.code==-1001 || error.code==-1005)
//                {
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//                        [UIApplication sharedApplication].idleTimerDisabled = YES;
//                        //[self uploadFileToServer:str];
//                        [[AppPreferences sharedAppPreferences].uploadTask resume];
//
//                       //// [[AppPreferences sharedAppPreferences].uploadTask resume];
//                    });
//                }
//                else
//                {
//                    // [UIApplication sharedApplication].idleTimerDisabled = NO;
//                    dispatch_async(dispatch_get_main_queue(), ^
//                                   {
//                                       //NSLog(@"Reachable");
//                                       NSString* date= [[APIManager sharedManager] getDateAndTimeString];
//
//                                       [[Database shareddatabase] updateAudioFileUploadedStatus:@"TransferFailed" fileName:str dateAndTime:date mobiledictationidval:0];
//
//                                       [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//
//                                       [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:response];
//
//                                       [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:[NSString stringWithFormat:@"File uploading failed, %@",error.localizedDescription] withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
//                                   });
//
//
//                }
//                NSLog(@"error = %@", error);
//
//                return;
//            }
//
//            NSError* error1;
//            NSString* encryptedString = [NSJSONSerialization JSONObjectWithData:data
//                                                                        options:NSJSONReadingAllowFragments
//                                                                          error:&error1];
//
//            dispatch_async(dispatch_get_main_queue(), ^
//                           {
//                               NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encryptedString options:0];
//                               NSData* data1=[decodedData AES256DecryptWithKey:SECRET_KEY];
//                               NSString* responseString=[[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
//                               responseString=[responseString stringByReplacingOccurrencesOfString:@"True" withString:@"1"];
//                               responseString=[responseString stringByReplacingOccurrencesOfString:@"False" withString:@"0"];
//
//                               NSData *responsedData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
//
//                               result = [NSJSONSerialization JSONObjectWithData:responsedData
//                                                                        options:NSJSONReadingAllowFragments
//                                                                          error:nil];
//
//                               NSString* returnCode= [result valueForKey:@"code"];
//
//                               if ([returnCode longLongValue]==200)
//                               {
//                                   NSString* idvalString= [result valueForKey:@"mobiledictationidval"];
//                                   NSString* date= [[APIManager sharedManager] getDateAndTimeString];
//                                   Database* db=[Database shareddatabase];
//                                   [db updateAudioFileUploadedStatus:@"Transferred" fileName:str dateAndTime:date mobiledictationidval:[idvalString longLongValue]];
//                                   [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUploaded" fileName:str];
//
//                                   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//
//                                   [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:response];
//                                   // NSLog(@"%@",[NSString stringWithFormat:@"%@ uploaded successfully",str]);
//
//                                   [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:[NSString stringWithFormat:@"%@ uploaded successfully",str] withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
//
//
//                               }
//                               else
//                               {
//                                   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//
//                                   [[Database shareddatabase] updateAudioFileUploadedStatus:@"TransferFailed" fileName:str dateAndTime:@"" mobiledictationidval:0];
//                                   [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:response];
//
//                                   NSLog(@"%@",str);
//
//                                   NSLog(@"%@",result);
//                                   [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:@"File uploading failed" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
//                               }
//
//                           });
//
//
//
//        }];
//
//        //Don't forget this line ever
//     [[AppPreferences sharedAppPreferences].uploadTask resume];
//
//*********************



@end
