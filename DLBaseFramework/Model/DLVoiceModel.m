//
//  DLVoiceModel.m
//  Auction
//
//  Created by 卢迎志 on 15-1-6.
//
//

#import "DLVoiceModel.h"
#import "VoiceConverterPlayHelper.h"
#import "DLCache.h"
#import "NSString+DLExtension.h"

@implementation DLVoiceModel

DEF_FACTORY(DLVoiceModel);

DEF_MODEL(voiceLenght);
DEF_MODEL(voiceAmrPath);
DEF_MODEL(voiceWavPath);

-(void)setWavPath:(NSString*)path withLenght:(NSString*)lenght
{
    self.voiceWavPath = path;
    self.voiceLenght = lenght;
    
}

-(void)setAmrPath:(NSString*)path withLenght:(NSString*)lenght
{
    self.voiceAmrPath = path;
    self.voiceLenght = lenght;
}

-(void)stop
{
    [[VoiceConverterPlayHelper sharedInstance] stopModel:self];
    [VoiceConverterPlayHelper sharedInstance].block = nil;
}

-(void)play:(TDLVoiceModelBlock)block
{
    if ([self.voiceWavPath notEmpty]) {
        
        if (self.voicePlay&&[DLCache isFileExists:self.voiceWavPath]) {
            
            self.isRead = YES;
            
            [VoiceConverterPlayHelper sharedInstance].block = block;
            
            [[VoiceConverterPlayHelper sharedInstance] playModel:self];
        }
    }
}

@end
