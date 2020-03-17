//
//  AudioDetails.h
//  Cube
//
//  Created by mac on 28/08/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DepartMent.h"

@interface AudioDetails : NSObject

@property(nonatomic, strong) NSString* fileName;
@property(nonatomic, strong) NSString* uploadStatus;
@property(nonatomic, strong) NSString* dictationStatus;
@property(nonatomic) int downloadStatus;
@property(nonatomic, strong) NSString* transferDate;
@property(nonatomic, strong) DepartMent* department;
@property(nonatomic, strong) DepartMent* departmentCopy;
@property(nonatomic) int mobiledictationidval;
@property(nonatomic, strong) NSString* currentDuration;
@property(nonatomic, strong) NSString* recordingDate;
@property(nonatomic, strong) NSString* fileSize;
@property(nonatomic, strong) NSString* deleteStatus;
@property(nonatomic, strong) NSString* deleteDate;
@property(nonatomic, strong) NSString* templateName;
@property(nonatomic, strong) NSString* priorityId;

@end
