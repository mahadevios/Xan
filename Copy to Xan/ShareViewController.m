//
//  ShareViewController.m
//  MondExtension
//
//  Created by mac on 20/12/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//
//http://catthoughts.ghost.io/extensions-in-ios8-custom-views/        custom view
#import "ShareViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"

@interface ShareViewController ()

@end

@implementation ShareViewController
@synthesize audioFilePathString,fileName,isFileAvailable,navigationView,cpyAudioFileButton,titleLabel,fileNamePathExtension;
- (BOOL)isContentValid
{
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}
SLComposeSheetConfigurationItem *item;

- (void)loadView
{
    //check commit
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor=[UIColor whiteColor];
    
    
    NSExtensionItem *item = self.extensionContext.inputItems.firstObject;
    
    NSItemProvider *itemProvider = item.attachments.firstObject;

    fileNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x-(self.view.frame.size.width*0.3), self.view.center.y-100, self.view.frame.size.width*0.6, 40)];
    
    fileNameLabel.textColor=[UIColor grayColor];
    
    fileNameLabel.text=itemProvider.accessibilityLabel.lastPathComponent;
    
    cpyAudioFileButton=[[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x-(self.view.frame.size.width*0.4), self.view.center.y-30, self.view.frame.size.width*0.8, 40)];
    cpyAudioFileButton.tag=101;
    
    [cpyAudioFileButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [cpyAudioFileButton setTitle:@"Import audio file to ACE" forState:UIControlStateNormal];
    
    [cpyAudioFileButton setBackgroundColor:[UIColor colorWithRed:0/255.0 green:44/255.0 blue:184/255.0 alpha:1.0]];
    
    cpyAudioFileButton.layer.cornerRadius=4.0f;
    
    
    navigationView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
    navigationView.tag=100;
    
    titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(navigationView.center.x-100, navigationView.center.y-20, 200, 40)];
    
    titleLabel.font=[UIFont boldSystemFontOfSize:18];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.text=@"Copy to ACE";
    
    titleLabel.textColor=[UIColor whiteColor];
    
    [navigationView addSubview:titleLabel];
    
    navigationView.backgroundColor=[UIColor colorWithRed:0/255.0 green:44/255.0 blue:184/255.0 alpha:1.0];
    
     UIButton* cancelExtensionButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    
    [cancelExtensionButton addTarget:self action:@selector(cancelExtensionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    [cancelExtensionButton setTitle:@"Cancel" forState:UIControlStateNormal];

    [cancelExtensionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    cancelExtensionButton.titleLabel.font=[UIFont boldSystemFontOfSize:16.0];
    
    [navigationView addSubview:cancelExtensionButton];
    
    [self.view addSubview:navigationView];
    
    [self.view addSubview:cpyAudioFileButton];
    
    [self.view addSubview:fileNameLabel];
    
    [cpyAudioFileButton addTarget:self action:@selector(copyAudioFileButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    cpyAudioFileButton.titleLabel.font=[UIFont systemFontOfSize:16];

    self.view.transform = CGAffineTransformMakeRotation(0);
    
    screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    
//[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopRotation:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

//- (UIStatusBarStyle) preferredStatusBarStyle
//{
//    return UIStatusBarStyleBlackTranslucent;
//}
- (InterfaceOrientationType)orientation{
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize nativeSize = [UIScreen mainScreen].currentMode.size;
    CGSize sizeInPoints = [UIScreen mainScreen].bounds.size;
    
    InterfaceOrientationType result;
    
    if(scale * sizeInPoints.width == nativeSize.width){
        result = InterfaceOrientationTypePortrait;
    }else{
        result = InterfaceOrientationTypeLandscape;
    }
    
    return result;
}


-(void)viewWillLayoutSubviews
{
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.xanadutec.ace"];

    if([self orientation] == InterfaceOrientationTypePortrait)
    {
        
       // [sharedDefaults setObject:[NSString stringWithFormat:@"%@",@"portrait"] forKey:@"out"];
        // portrait
        self.view .frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, screenWidth, screenHeight);

        navigationView.frame= CGRectMake(navigationView.frame.origin.x, navigationView.frame.origin.y, screenHeight, navigationView.frame.size.height);
        
        cpyAudioFileButton.frame=CGRectMake(self.view.center.x-(self.view.frame.size.width*0.4), self.view.center.y-30,self.view.frame.size.width*0.8, 40);
        
        titleLabel.frame=CGRectMake(self.view.center.x-(self.view.frame.size.width*0.2), navigationView.center.y-20, self.view.frame.size.width*0.4, 40);
    }
    else
    {
        
        
        self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, screenHeight, screenWidth);
        
//        navigationView=[self.view viewWithTag:100];
//        
        navigationView.frame= CGRectMake(navigationView.frame.origin.x, navigationView.frame.origin.y, screenHeight, navigationView.frame.size.height);
        
        cpyAudioFileButton.frame=CGRectMake(self.view.center.x-(self.view.frame.size.width*0.4), self.view.center.y-30, self.view.frame.size.width*0.8, 40);
        
        titleLabel.frame=CGRectMake(navigationView.center.x-100, navigationView.center.y-20, 200, 40);

        [sharedDefaults setObject:[NSString stringWithFormat:@"%@",@"landscape"] forKey:@"out"];

        // landscape
    }
}
-(BOOL)shouldAutorotate
{
    return NO;
}
-(void)stopRotation:(NSNotification *)note
{
   

        UIDevice *dev = (UIDevice *)note.object;
        if ([dev orientation] == UIInterfaceOrientationLandscapeRight)
        {
            self.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
        else if ([dev orientation] == UIInterfaceOrientationPortrait)
        {
            self.view.transform = CGAffineTransformIdentity;
        }
        else if ([dev orientation] == UIInterfaceOrientationPortraitUpsideDown)
        {
            self.view.transform = CGAffineTransformIdentity;
        }
        else if ([dev orientation] == UIInterfaceOrientationLandscapeLeft)
        {
            self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
        }
   
}
- (NSArray *)configurationItems
{
    
    item = [[SLComposeSheetConfigurationItem alloc] init];

    [item setTapHandler:^(void){
    }];
    
    return @[item];
    
}

- (void)didSelectPost
{
    NSString *typeIdentifier = (NSString *)kUTTypeAudio;
    NSExtensionItem *item = self.extensionContext.inputItems.firstObject;
    NSItemProvider *itemProvider = item.attachments.firstObject;
    
    if ([itemProvider hasItemConformingToTypeIdentifier:typeIdentifier]) {
        [itemProvider loadItemForTypeIdentifier:typeIdentifier
                                        options:nil
                              completionHandler:^(NSURL *url, NSError *error)
         {
            
             
         }];
    }
    
}

- (void)cancelExtensionButtonClicked:(id)sender
{
    [self.extensionContext completeRequestReturningItems:@[]
                                       completionHandler:nil];
}


- (void)copyAudioFileButtonClicked:(id)sender
{
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.xanadutec.ace"];
    
//    [sharedDefaults setObject:@"inside" forKey:@"check"];
    
    NSString *typeIdentifier = (NSString *)kUTTypeAudio;
    NSExtensionItem *item = self.extensionContext.inputItems.firstObject;
    NSItemProvider *itemProvider = item.attachments.firstObject;
    
    [sharedDefaults synchronize];
//     [sharedDefaults setObject:@"inside" forKey:@"check"];
    //[sharedDefaults setObject:arr forKey:@"array"];
    if ([itemProvider hasItemConformingToTypeIdentifier:typeIdentifier]) {
        [itemProvider loadItemForTypeIdentifier:typeIdentifier
                                        options:nil
                              completionHandler:^(NSURL *url, NSError *error)
         {
             
             NSURL *imageURL = (NSURL *)url;
             
             NSError *audioError;

             AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithContentsOfURL:imageURL error:&audioError];

             if (player.duration>3600)
             {
                 alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:@"File size is too big to import" preferredStyle:UIAlertControllerStyleAlert];
                 
                 actionCancel = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                     [alertController dismissViewControllerAnimated:YES completion:nil];
                     NSLog(@"Canelled");
                 }];
                 
                 [alertController addAction:actionCancel];
                 

                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self presentViewController:alertController animated:YES completion:nil];
                 });

             }
          else
          {

             NSString* audioFileName=[imageURL lastPathComponent];
             
             NSString* fileNameKeyString = audioFileName;
             
             NSDictionary* dict1=[NSDictionary new];
             
             dict1=[sharedDefaults objectForKey:@"isFileInsertedDict"];
             
             isFileAvailable=NO;
             
             if (dict1==NULL)
             {
               //isFileAvailable=NO;
             }
             else
             {
                 NSString* isContainKeyString = [dict1 objectForKey:fileNameKeyString];
                 
                 if (!(isContainKeyString==NULL)) //file already available
                 {
                     isFileAvailable=YES;

                 }
                 
             }
             NSString* fileNameWithoutExtension;
            // [sharedDefaults setObject:[NSString stringWithFormat:@"%d",isFileAvailable] forKey:@"file"];
             if (!isFileAvailable)
             {
                 
                 NSDictionary* copyDict=[sharedDefaults objectForKey:@"updatedFileDict"];
                

                 NSMutableDictionary* updatedFileDict=[copyDict mutableCopy];
                 //for very first file set update to NO
                 if (updatedFileDict == NULL)
                 {
                     updatedFileDict=[NSMutableDictionary new];
                     
                     [updatedFileDict setObject:@"NO" forKey:fileNameKeyString];
                     
                     [sharedDefaults setObject:updatedFileDict forKey:@"updatedFileDict"];
                     
                     [sharedDefaults synchronize];
                 }
                 
                 else
                 {
                     NSString* containsKeyString = [updatedFileDict objectForKey:fileNameKeyString];
                     
                     if (containsKeyString ==NULL)
                     {
                         [updatedFileDict setObject:@"NO" forKey:fileNameKeyString];
                         
                         [sharedDefaults setObject:updatedFileDict forKey:@"updatedFileDict"];
                         
                         [sharedDefaults synchronize];
                         
                     }
                     
                     else
                     {
                         [updatedFileDict setObject:@"YES" forKey:fileNameKeyString];
                         
                         [sharedDefaults setObject:updatedFileDict forKey:@"updatedFileDict"];
                         
                         [sharedDefaults synchronize];
                     }
                 }
                
                 fileName=[imageURL lastPathComponent];

                 [self saveAudio:imageURL];
                 
             }
             else
             {
                 NSString* originalFileName = [imageURL lastPathComponent];
                 
                 fileNameWithoutExtension = [originalFileName stringByDeletingPathExtension];
                 
                 //fileNameWithoutExtension=[fileNameWithoutExtension stringByReplacingOccurrencesOfString:@" " withString:@""];

                 alertController =[UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"File with name \"%@\" already exist!",fileNameWithoutExtension] message:@"Please save with different name" preferredStyle:UIAlertControllerStyleAlert];
                                                      [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                                                          textField.text = fileNameWithoutExtension;
                                                          textField.keyboardType=UIKeyboardTypeNamePhonePad;
                                                          textField.autocorrectionType=UITextAutocorrectionTypeNo;
                                                          textField.delegate=nil;
                 
                                                      }];
                                                      actionSave = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                                        {
                                                          
                                                            BOOL isContainFileWithName = false;
                                                            
                                                            NSString* editedNameString = [[alertController textFields][0] text];
                                                            

                                                            editedNameString = [editedNameString stringByTrimmingCharactersInSet:
                                                                                [NSCharacterSet whitespaceCharacterSet]];
                                                            
                                                            NSInteger fileNameLength = editedNameString.length;
                                                            
                                                            if (fileNameLength>30)
                                                            {
                                                                alertController =[UIAlertController alertControllerWithTitle:@"Filename too long!" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                                                                
                                                                actionCancel = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                                    [alertController dismissViewControllerAnimated:YES completion:nil];
                                                                    NSLog(@"Canelled");
                                                                }];
                                                                
                                                                [alertController addAction:actionCancel];
                                                                
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    [self presentViewController:alertController animated:YES completion:nil];
                                                                });

                                                            }
                                                            
                                                            else
                                                            {

                                                           NSString* m4aFileName= [editedNameString stringByAppendingPathExtension:@"m4a"];
                                                            
                                                            NSString* mp3FileName= [editedNameString stringByAppendingPathExtension:@"mp3"];
                                                            
                                                            NSString* wavFileName= [editedNameString stringByAppendingPathExtension:@"wav"];
                                                            
                                                            NSString* cafFileName= [editedNameString stringByAppendingPathExtension:@"caf"];
                                                                
                                                                NSString* dssFileName= [editedNameString stringByAppendingPathExtension:@"dss"];
                                                                
                                                                NSString* ds2FileName= [editedNameString stringByAppendingPathExtension:@"ds2"];
                                                                
                                                                NSString* wmaFileName= [editedNameString stringByAppendingPathExtension:@"wma"];
                                                                
                                                                NSString* aacFileName= [editedNameString stringByAppendingPathExtension:@"aac"];
                                                                
                                                                
                                                                NSString* dctFileName= [editedNameString stringByAppendingPathExtension:@"dct"];
                                                                
                                                                NSString* mp4FileName= [editedNameString stringByAppendingPathExtension:@"mp4"];
                                                                
                                                                NSString* iafFileName= [editedNameString stringByAppendingPathExtension:@"iaf"];
                                                            
                                                            if (!([dict1 objectForKey:m4aFileName]==NULL)) //file already available
                                                            {
                                                                isContainFileWithName=YES;
                                                                
                                                            }
                                                                else
                                                            if (!([dict1 objectForKey:mp3FileName]==NULL)) //file already available
                                                            {
                                                                isContainFileWithName=YES;
                                                                
                                                            }
                                                                else
                                                            if (!([dict1 objectForKey:wavFileName]==NULL)) //file already available
                                                            {
                                                                isContainFileWithName=YES;
                                                                
                                                            }
                                                            else
                                                            if (!([dict1 objectForKey:cafFileName]==NULL)) //file already available
                                                            {
                                                                isContainFileWithName=YES;
                                                                
                                                            }
                                                               else
                                                                if (!([dict1 objectForKey:dssFileName]==NULL)) //file already available
                                                                {
                                                                    isContainFileWithName=YES;
                                                                    
                                                                }
                                                                else
                                                                if (!([dict1 objectForKey:ds2FileName]==NULL)) //file already available
                                                                {
                                                                    isContainFileWithName=YES;
                                                                    
                                                                }
                                                                else
                                                                if (!([dict1 objectForKey:mp4FileName]==NULL)) //file already available
                                                                {
                                                                    isContainFileWithName=YES;
                                                                    
                                                                }
                                                                else
                                                                if (!([dict1 objectForKey:iafFileName]==NULL)) //file already available
                                                                {
                                                                    isContainFileWithName=YES;
                                                                    
                                                                }
                                                                else
                                                                if (!([dict1 objectForKey:wmaFileName]==NULL)) //file already available
                                                                {
                                                                    isContainFileWithName=YES;
                                                                    
                                                                }
                                                                else
                                                                if (!([dict1 objectForKey:dctFileName]==NULL)) //file already available
                                                                {
                                                                    isContainFileWithName=YES;
                                                                    
                                                                }
                                                                else
                                                                if (!([dict1 objectForKey:aacFileName]==NULL)) //file already available
                                                                {
                                                                    isContainFileWithName=YES;
                                                                    
                                                                }
                                                                
                                                            if (isContainFileWithName)
                                                            {
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                   
                                                                    alertController.title=[NSString stringWithFormat:@"File with name \"%@\" already exist!", editedNameString];
                                                                    [self presentViewController:alertController animated:YES completion:nil];
                                                                });
                                                            }
                                                            else
                                                            {
                                                                fileName=[[alertController textFields][0] text];
                                                                
                                                                fileNamePathExtension=[imageURL pathExtension];

                                                                fileName=[fileName stringByAppendingPathExtension:fileNamePathExtension];
                                                                
                                                             [self saveAudio:imageURL];
                                                            }
                                                          NSLog(@"Current password %@", [[alertController textFields][0] text]);
                                                            }
                                                          //compare the current password and do action here
                 
                                                      }];
                                                      [alertController addAction:actionSave];
                                                      actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                          [self.extensionContext completeRequestReturningItems:@[]
                                                                                                                                   completionHandler:nil];
                                                          NSLog(@"Canelled");
                                                      }];

                 [alertController addAction:actionCancel];
//                 
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self presentViewController:alertController animated:YES completion:nil];
                 });
             }
             
             
             
             
             
             // [self saveAudio:imageURL];
             
          }
         }];
    }
    else
    {
       
    }
         
}
-(void)saveAudio:(NSURL*)url
{
    NSData* data=[NSData dataWithContentsOfURL:url];
    
    NSFileManager* fileManagaer=[NSFileManager defaultManager];
    
    NSURL* sharedGroupUrl= [fileManagaer containerURLForSecurityApplicationGroupIdentifier:@"group.com.xanadutec.ace"];
    
    NSString* audioFolderString=[sharedGroupUrl.path stringByAppendingPathComponent:@"audio"] ;
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.xanadutec.ace"];
    
    [sharedDefaults setObject:audioFolderString forKey:@"audioFolderPath"];//set the folder path where file will b stored
    
    BOOL isdir;
    NSError *error = nil;
    if (![fileManagaer fileExistsAtPath:audioFolderString isDirectory:&isdir]) { //create a dir only that does not exists
        if (![fileManagaer createDirectoryAtPath:audioFolderString withIntermediateDirectories:YES attributes:nil error:&error])
        {
            NSLog(@"error while creating dir: %@", error.localizedDescription);
        }
        else
        {
            NSLog(@"dir was created....");
        }
    }//create audio folder if not exist
    
    
    
    //fileName=[url lastPathComponent];
    
    audioFilePathString=[audioFolderString stringByAppendingPathComponent:fileName];
    
    NSData* audioData= data;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:audioFilePathString])
    {
        [[NSFileManager defaultManager]removeItemAtPath:audioFilePathString error:&error];
    }
    
    [audioData writeToFile:audioFilePathString atomically:YES];
    
    //[sharedDefaults synchronize];
    //[sharedDefaults setObject:[NSString stringWithFormat:@"%@",audioFilePathString] forKey:@"output1"];

    [self convertToWavCopy];
    
}

-(void) convertToWavCopy
{
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.xanadutec.ace"];
    
    NSString* sharedAudioFolderPathString=[sharedDefaults objectForKey:@"audioFolderPath"];
    
    NSMutableArray* sharedAudioNamesArray=[NSMutableArray new];
    
    sharedAudioNamesArray=[sharedDefaults objectForKey:@"audioNamesArray"];
    
    
    NSString* sharedAudioFileNameString=fileName;
    
    NSURL* sharedAudioFolderPathUrl=[NSURL URLWithString:sharedAudioFolderPathString];
    
    
    NSString* sharedAudioFilePathString=[sharedAudioFolderPathUrl.path stringByAppendingPathComponent:sharedAudioFileNameString];
    
    NSString* audioFilePath = sharedAudioFilePathString;
    // audioFilePath=[audioFilePath stringByAppendingPathExtension:@"wav"];
    
    NSString* waveFileName=[audioFilePath lastPathComponent];
    
    [sharedDefaults setObject:waveFileName forKey:@"waveFileName"];

        NSDictionary* dict1=[NSDictionary new];
        

        dict1=[sharedDefaults objectForKey:@"audioNamesAndDateDict"];
        

        NSMutableDictionary* audioNamesAndDatesDict=[NSMutableDictionary new];
        
        NSString* date=[self getDateAndTimeString];
        
        if (dict1==NULL)
        {
            [audioNamesAndDatesDict setObject:date forKey:waveFileName];
            [sharedDefaults setObject:audioNamesAndDatesDict forKey:@"audioNamesAndDateDict"];
//
        }
        else
        {
            audioNamesAndDatesDict=[dict1 mutableCopy];
            [audioNamesAndDatesDict setObject:date forKey:waveFileName];
            [sharedDefaults setObject:audioNamesAndDatesDict forKey:@"audioNamesAndDateDict"];
//            
//            
        }
        
        
        
        
        NSDictionary* copy1Dict=[sharedDefaults objectForKey:@"isFileInsertedDict"];
        
        
        NSMutableDictionary* isFileInsertedDict=[copy1Dict mutableCopy];
        
        if (isFileInsertedDict == NULL)
        {
            isFileInsertedDict=[NSMutableDictionary new];
            
            [isFileInsertedDict setObject:@"NO" forKey:waveFileName];
            
            [sharedDefaults setObject:isFileInsertedDict forKey:@"isFileInsertedDict"];
            
            [sharedDefaults synchronize];
        }
        
        else
        {
            NSString* containsKeyString = [isFileInsertedDict objectForKey:waveFileName];
            
            if (containsKeyString ==NULL)
            {
                [isFileInsertedDict setObject:@"NO" forKey:waveFileName];
                
                [sharedDefaults setObject:isFileInsertedDict forKey:@"isFileInsertedDict"];

                [sharedDefaults synchronize];
                
            }
            
            else
                if ([containsKeyString isEqualToString:@"NO"])

            {
                [isFileInsertedDict setObject:@"NO" forKey:waveFileName];
                
                [sharedDefaults setObject:isFileInsertedDict forKey:@"isFileInsertedDict"];

                [sharedDefaults setObject:waveFileName forKey:@"waveFileName"];

                [sharedDefaults synchronize];
            }
            else
                if ([containsKeyString isEqualToString:@"YES"])

            {
                [isFileInsertedDict setObject:@"UPDATE" forKey:waveFileName];
                
                [sharedDefaults setObject:isFileInsertedDict forKey:@"isFileInsertedDict"];
                
                [sharedDefaults setObject:waveFileName forKey:@"waveFileName"];

                [sharedDefaults synchronize];
            }

        }
 
    [sharedDefaults synchronize];
    
    [self.extensionContext completeRequestReturningItems:@[]
                                       completionHandler:nil];
    
}

-(NSString*)getDateAndTimeString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = DATE_TIME_FORMAT;
    NSString* recordCreatedDateString = [formatter stringFromDate:[NSDate date]];
    return recordCreatedDateString;
}


@end
