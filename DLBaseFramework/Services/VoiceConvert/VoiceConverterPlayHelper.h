//
//  VoiceConverterPlayHelper.h
//  Catalyzer
//
//  Created by luyz on 2017/3/23.
//  Copyright © 2017年 luyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLSingleton.h"
#import "DLModel.h"
#import "DLVoiceModel.h"

//tag
// 0 play finish
// 1 start play
typedef void (^TVoiceConverterPlayHelperBlock)(NSInteger tag,id data);

@interface VoiceConverterPlayHelper : NSObject

AS_SINGLETON(VoiceConverterPlayHelper);

AS_BLOCK(TVoiceConverterPlayHelperBlock, block);

-(void)playModel:(DLVoiceModel*)data;

-(void)stopModel:(DLVoiceModel*)data;

-(void)play:(NSString*)path;

-(void)stop;

-(BOOL)isPlaying;

@end
