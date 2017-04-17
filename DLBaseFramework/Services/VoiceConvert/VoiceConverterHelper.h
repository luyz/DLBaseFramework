//
//  VoiceConverterHelper.h
//  Catalyzer
//
//  Created by luyz on 2017/3/19.
//  Copyright © 2017年 luyz. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AudioToolbox/AudioToolbox.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "DLModel.h"

//默认最大录音时间
#define kDefaultMaxRecordTime               60
#define kCancelOriginY                      ([[UIScreen mainScreen] bounds].size.height-60)
#define KRecorderViewRect                   CGRectMake(([[UIScreen mainScreen] bounds].size.width-156)/2,160,156,156)

typedef void (^TVoiceConverterHelperBlock)(NSInteger tag,id data);

@interface VoiceConverterHelper : NSObject

AS_BLOCK(TVoiceConverterHelperBlock, block);

//最大录音时间
AS_INT_ASSIGN(maxRecordTime);
//录音文件名
AS_MODEL_STRONG(NSString, recordFileName);
//录音文件路径
AS_MODEL_STRONG(NSString, recordFilePath);

//开始录音
- (void)beginRecordByFileName:(NSString*)_fileName;

//停止录音
-(void)stopRecorder;

/**
 生成当前时间字符串
 @returns 当前时间字符串
 */
+ (NSString*)getCurrentTimeString;

/**
 获取缓存路径
 @returns 缓存路径
 */
+ (NSString*)getCacheDirectory;

/**
 判断文件是否存在
 @param _path 文件路径
 @returns 存在返回yes
 */
+ (BOOL)fileExistsAtPath:(NSString*)_path;

/**
 删除文件
 @param _path 文件路径
 @returns 成功返回yes
 */
+ (BOOL)deleteFileAtPath:(NSString*)_path;

#pragma mark -

/**
 生成文件路径
 @param _fileName 文件名
 @returns 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)_fileName;

+ (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type;

/**
 获取录音设置
 @returns 录音设置
 */
+ (NSDictionary*)getAudioRecorderSettingDict;

@end
