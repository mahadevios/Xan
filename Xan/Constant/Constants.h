//
//  Header.h
//  Cube
//
//  Created by mac on 13/08/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#ifndef Header_h
#define Header_h


//#define  BASE_URL_PATH                        @"http://192.168.3.81:8089/xan-dictate" // Vrushali Mam
//#define  BASE_URL_PATH                        @"http://192.168.3.79:8089/xan-dictate" // KK
//#define  BASE_URL_PATH                          @"http://192.168.3.76:8089/xan-dictate"  // Shruti
//#define  BASE_URL_PATH                          @"http://192.168.3.80:8089/xan-dictate"  // Mahadev Mac
#define  BASE_URL_PATH                          @"http://192.168.3.82:8089/xan-dictate"  // Mahadev Windows

//#define  BASE_URL_PATH                        @"http://192.168.2.9:8089/xan-dictate"

//#define  BASE_URL_PATH                          @"https://cfscommunicator.com:8443/xan_dictate"

//#define  BASE_URL_PATH                        @"http://192.168.3.80:8080/user"

#define  AUDIO_DOWNLOAD_API                    @"download3"

#define  FILE_UPLOAD_API                        @"mobileUploadAudio"

//#define  BASE_URL_PATH_LOCAL                    @"http://192.168.3.80:8080/payU/fileOps"
//#define  FILE_UPLOAD_API                        @"uploadAudio"


#define  CHECK_DEVICE_REGISTRATION_API        @"verifyDeviceRegistration"
#define  CHECK_USER_REGISTRATION_API          @"validateUser"
#define  GENERATE_DEVICE_TOKEN                @"token/generate-device-token"
#define  ACCEPT_PIN_API                       @"devicePinRegistration"
#define  ACCEPY_TandC_API                     @"acceptTandC"
#define  VALIDATE_PIN_API                     @"devicePinLogin"
#define  FORGOT_PIN_API                       @"forgotPin"
#define  PIN_CANGE_API                        @"resetDevicePin"
#define  TEST_API                             @"check"
#define  TEMPLATE_LIST_API                    @"getTemplateByDevicePractitioner"


//#define  BASE_URL_PATH                        @"http://www.xanadutec.net/cubeagent_webapi/api"
//
//#define  BASE_URL_PATH                        @"http://192.168.3.150:8081/CubeAPI/api"
//#define  CHECK_DEVICE_REGISTRATION            @"MobileCheckDeviceRegistration"
//#define  AUTHENTICATE_API                     @"MobileAuthenticate"
//#define  ACCEPT_PIN_API                       @"MobileAcceptPIN"
//#define  VALIDATE_PIN_API                     @"MobileValidatePIN"
//#define  DICTATIONS_INSERT_API                @"MobileDictationsInsert"
//#define  DATA_SYNCHRONISATION_API             @"MobileDataSynchronisation"
//#define  FILE_UPLOAD_API                      @"MobileFileUpload"
//#define  PIN_CANGE_API                        @"MobilePINChange"

//#define  BASE_URL_PATH                        @"http://www.xanadutec.net/cubeagent_webapi/api"
//#define  BASE_URL_PATH                        @"https://www.cubescribe.com/cubeagent_webapi/api"

//#define  BASE_URL_PATH                        @"http://192.168.3.156:8081/CubeAPI/api"
//#define  CHECK_DEVICE_REGISTRATION            @"encrdecr_MobileCheckDeviceRegistration"
#define  AUTHENTICATE_API                     @"encrdecr_MobileAuthenticate"
//#define  ACCEPT_PIN_API                       @"encrdecr_MobileAcceptPIN"
//#define  VALIDATE_PIN_API                     @"encrdecr_MobileValidatePIN"
//#define  FILE_UPLOAD_API                      @"encrdecr_MobileFileUpload"
//#define  PIN_CANGE_API                        @"encrdecr_MobilePINChange"
#define  FILE_DOWNLOAD_API                    @"encedecr_MobileDownloadDocFile"
#define  SEND_DICTATION_IDS_API               @"encrdecr_MobileRequestForCompleteFiles"
#define  SEND_COMMENT_API                     @"encdecr_MobileDocFileComment"
#define  DOCX_FILE_UPLOAD_API                 @"encedecr_MobileUploadDocFile"




#define  SECRET_KEY                           @"an@%c*(a&ax/e!*6"
#define  IV                                   @"t6*a$d)e&1@c*!ex"
#define  CONTENT_TYPE_JSON                    @"JSON"

//#define  IV                                   @"abcdefghijklmn8p"
//#define  IV                                   @"90Ji0arv0fkpeCwH"


//#define  SECRET_KEY                           @"d00529f30eb8325a64522b87dd372964"

#define  POST                           @"POST"
#define  GET                            @"GET"
#define  PUT                            @"PUT"
#define  REQUEST_PARAMETER              @"requestParameter"
#define  SUCCESS                        @"1000"
#define  FAILURE                        @"1001"
#define  VRS_LOCALE                     @"vrsLocale"


//NSNOTIFICATION
#define NOTIFICATION_CHECK_USER_REGISTRATION            @"notificationCheckUserRegistration"
#define NOTIFICATION_GENERATE_DEVICE_TOKEN              @"notificationGenerateDeviceToken"



#define NOTIFICATION_CHECK_DEVICE_REGISTRATION      @"notificationForMobileCheckDeviceRegistration"
#define NOTIFICATION_AUTHENTICATE_API               @"notificationForMobileAuthenticate"
#define NOTIFICATION_ACCEPT_PIN_API                 @"notificationForMobileAcceptPIN"
#define NOTIFICATION_VALIDATE_PIN_API               @"notificationForMobileValidatePIN"
#define NOTIFICATION_DICTATIONS_INSERT_API          @"notificationForMobileDictationsInsert"
#define NOTIFICATION_DATA_SYNCHRONISATION_API       @"notificationForMobileDataSynchronisation"
#define NOTIFICATION_FILE_UPLOAD_API                @"notificationForMobileFileUpload"
#define NOTIFICATION_FILE_DOWNLOAD_API              @"notificationForMobileFileDownload"
#define NOTIFICATION_SEND_DICTATION_IDS_API         @"notificationSendDictationIds"
#define NOTIFICATION_ACCEPT_TANDC_API               @"notificationAcceptTandC"
#define NOTIFICATION_TEMPLATE_LIST_API              @"notificationTemplateList"

#define NOTIFICATION_PIN_CANGE_API                  @"notificationForMobilePINChange"
#define NOTIFICATION_PAUSE_RECORDING                @"pauseRecording"
#define NOTIFICATION_INTERNET_MESSAGE               @"internetMessage"
#define NOTIFICATION_PAUSE_AUDIO_PALYER             @"pausePlayer"
#define NOTIFICATION_DELETE_RECORDING               @"deleteRecording"
#define NOTIFICATION_SAVE_RECORDING                 @"saveRecording"
#define NOTIFICATION_FILE_IMPORTED                  @"fileImportingCompleted"
#define NOTIFICATION_UPLOAD_NEXT_FILE               @"uploadNextFile"
#define NOTIFICATION_SEND_COMMENT_API               @"commentNotification"
#define NOTIFICATION_FILE_UPLOAD_CLICKED            @"fileUploadClicked"
#define NOTIFICATION_STOP_VRS                       @"stopVRS"
#define NOTIFICATION_RECORD_DISMISSED               @"recordDismissed"

//Settimg Constants

#define SAVE_DICTATION_WAITING_SETTING         @"Save dictation waiting by"
#define CONFIRM_BEFORE_SAVING_SETTING          @"Confirm before saving"
#define CONFIRM_BEFORE_SAVING_SETTING_ALTERED  @"Confirm before saving alter"
#define ALERT_BEFORE_RECORDING                 @"Alert before recording"
#define BACK_TO_HOME_AFTER_DICTATION           @"Back to home after dictation"
#define RECORD_ABBREVIATION                    @"Record abbreviation"
#define LOW_STORAGE_THRESHOLD                  @"Low storage threshold"
#define PURGE_DELETED_DATA                     @"Purge data by"
#define CHANGE_YOUR_PASSWORD                   @"Change your pin"
#define DELETE_MESSAGE_DOCX                    @"Do you want to delete this file?"
#define DELETE_MESSAGE                         @"Do you want to delete this recording?"
#define DELETE_MESSAGE_MULTIPLES               @"Do you want to delete these recordings?"
#define TRANSFER_MESSAGE                       @"Are you sure you want to transfer this recording?"
#define TRANSFER_MESSAGE_MULTIPLES             @"Are you sure you want to transfer these recordings?"
#define RESEND_MESSAGE                         @"Are you sure you want to resend this recording?"
#define PAUSE_STOP_MESSAGE                     @"Recording is on.Please pause/stop the recording"
#define MAXIMUM_RECORDING_LIMIT_MESSAGE        @"Recording duration length exceeded,please start new recording for further dictation"
#define RECORDING_SAVED_MESSAGE                @"Recording duration length exceeded,your recording has been saved in awaiting transfer,please start new recording for further dictation"
#define NO_INTERNET_TITLE_MESSAGE              @"No Internet Connection!"
#define NO_INTERNET_DETAIL_MESSAGE             @"Please check your internet connection and try again."


#define CURRENT_VESRION                        @"currentVersion"
#define IS_DATE_FORMAT_UPDATED                 @"dateFormatUpdated"
#define RECORDING_LIMIT                        3600
#define ALERT_TAB_LOCATION                     3
#define PURGE_DATA_DATE                        @"purgeDataDate"
#define INCOMPLETE_TRANSFER_COUNT_BADGE        @"Incomplete Count"
#define SELECTED_DEPARTMENT_NAME               @"Selected Department"
#define SELECTED_DEPARTMENT_NAME_COPY          @"Selected Department Copy"
#define AUDIO_FILES_FOLDER_NAME                @"Audio files"
#define DOCX_FILES_FOLDER_NAME                 @"Downloads"
#define DOC_VRS_FILES_FOLDER_NAME              @"VRSDOC files"
#define DOC_VRS_TEXT_FILES_FOLDER_NAME         @"VRSAudio files"
#define USER_PIN                               @"userPIN"
#define USER_ID                                @"userId"
#define USER_PASS                              @"userPassword"
#define DATE_TIME_FORMAT                       @"yyyy-MM-dd HH:mm:ss"
#define RESPONSE_CODE                          @"code"
#define RESPONSE_PIN_VERIFY                    @"pinVerify"
#define RESPONSE_TC_FLAG                       @"tcFl"
#define RESPONSE_MESSAGE                       @"responseMessage"
#define SHARED_GROUP_IDENTIFIER                @"group.com.xanadutec.ace"


#define JWT_TOKEN                              @"jwtToken"

typedef enum
{
    NODOWNLOAD,
    DOWNLOADING,
    DOWNLOADED,
    DOWNLOADEDANDDELETED
}DownloadingStatus;

typedef enum
{
    NODELETE,
    DELETED
}DeleteStatus;

typedef enum
{
    VRSDOC_NOUPLOAD,
    VRSDOC_UPLOADED
}VrsDoc_UploadStatus;

typedef enum
{
    BLANK,
    COMPLETED,
    PAUSED,
    DELETE,
    FILE_UPLOAD,
    FILE_UPLOADED,
}RecordingStatus;

typedef enum
{
    NOT_TRANSFERRED,
    TRANSFERRED,
    TRANSFERRED_FAILED,
    RESEND,
    RESEND_FAILED,
}Transfer_Status;

typedef enum
{
    NORMAL,
    URGENT
}Priority;

#endif /* Header_h */
