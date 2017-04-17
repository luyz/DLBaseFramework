//
//  VoiceConverterPlayHelper.m
//  Catalyzer
//
//  Created by luyz on 2017/3/23.
//  Copyright © 2017年 luyz. All rights reserved.
//

#import "VoiceConverterPlayHelper.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+DLExtension.h"

@interface VoiceConverterPlayHelper ()<AVAudioPlayerDelegate>

AS_MODEL_STRONG(AVAudioPlayer, voicePlayer);
AS_MODEL_STRONG(DLVoiceModel, currPlayModel);


@end

@implementation VoiceConverterPlayHelper

DEF_SINGLETON(VoiceConverterPlayHelper);

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

-(void)playModel:(DLVoiceModel*)data
{
    if (data!=nil) {
        
        self.currPlayModel = data;
        
        if ([data.voiceWavPath notEmpty]) {
            [self play:data.voiceWavPath];
        }
    }
}

-(void)stopModel:(DLVoiceModel*)data
{
    [self stop];
    
    if (self.currPlayModel!=nil && self.currPlayModel!= data) {
        self.currPlayModel.voicePlay = NO;
    }
    self.currPlayModel = nil;
}

-(void)play:(NSString*)path
{
    self.voicePlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
    
    self.voicePlayer.volume = 1.0;
    // 4.设置循环播放
    self.voicePlayer.numberOfLoops = 0;
    [self.voicePlayer prepareToPlay];
    self.voicePlayer.delegate = self;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    // 5.开始播放
    [self.voicePlayer play];
    
    if (self.block!=nil) {
        self.block(1,nil);
    }
}

-(void)stop
{
    if (self.voicePlayer!=nil) {
        if ([self.voicePlayer isPlaying]) {
            [self.voicePlayer stop];
            self.voicePlayer = nil;
        }
    }
}

-(BOOL)isPlaying
{
    return self.voicePlayer!=nil?self.voicePlayer.isPlaying:NO;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopModel:nil];
    
    if (self.block!=nil) {
        self.block(0,nil);
    }
}

@end
