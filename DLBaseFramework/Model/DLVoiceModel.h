//
//  DLVoiceModel.h
//  Auction
//
//  Created by 卢迎志 on 15-1-6.
//
//

#import <Foundation/Foundation.h>
#import "DLFactory.h"
#import "DLModel.h"

typedef void (^TDLVoiceModelBlock)(NSInteger tag,id data);

@interface DLVoiceModel : NSObject

AS_FACTORY(DLVoiceModel);

AS_MODEL_STRONG(NSString, voiceAmrPath);
AS_MODEL_STRONG(NSString, voiceLenght);
AS_MODEL_STRONG(NSString, voiceWavPath);
AS_MODEL_STRONG(NSString, voiceUrl);

AS_BOOL(hasFile);
AS_BOOL(voicePlay);
AS_BOOL(isRead);

-(void)setWavPath:(NSString*)path
       withLenght:(NSString*)lenght;

-(void)setAmrPath:(NSString*)path
       withLenght:(NSString*)lenght;

-(void)stop;

-(void)play:(TDLVoiceModelBlock)block;

@end
