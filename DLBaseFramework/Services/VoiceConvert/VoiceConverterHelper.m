//
//  VoiceConverterHelper.m
//  Catalyzer
//
//  Created by luyz on 2017/3/19.
//  Copyright © 2017年 luyz. All rights reserved.
//

#import "VoiceConverterHelper.h"
#import "DLModel.h"
#import "DLLoadLib.h"
#import "DLSandbox.h"
#import "DLCache.h"
#import "UIView+Animation.h"
#import "NSDictionary+DLExtension.h"

@interface ChatRecorderView : UIView

AS_MODEL_STRONG(UIImageView, peakMeterIV);
AS_MODEL_STRONG(UILabel, countDownLabel);

AS_MODEL_STRONG(NSArray, peakImageAry);
AS_BOOL(isPrepareDelete);
AS_BOOL(isTrashCanRocking);

//还原界面
- (void)restoreDisplay;

//更新音频峰值
- (void)updateMetersByAvgPower:(float)_avgPower;

@end

@implementation ChatRecorderView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
    
        [self setBackgroundColor:[UIColor lightGrayColor]];
        
        [self setClipsToBounds:YES];
        
        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:10];
        
        UIImage* tempImage = [UIImage imageNamed:@"ic_recording1.png"];
        
        self.peakMeterIV = [[UIImageView alloc]initWithFrame:CGRectMake((frame.size.width-tempImage.size.width)/2, (frame.size.height-tempImage.size.height)/2, tempImage.size.width, tempImage.size.height)];
        self.peakMeterIV.image = tempImage;
        [self addSubview:self.peakMeterIV];
        
        self.countDownLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width-40, 10, 40, 20)];
        self.countDownLabel.textColor = [UIColor redColor];
        self.countDownLabel.text  =@"0“";
        self.countDownLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.countDownLabel];
        
        [self initilization];
    }
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    UIImage* tempImage = [UIImage imageNamed:@"ic_recording1.png"];
    RECT_CHANGE_size(self.peakMeterIV, tempImage.size.width, tempImage.size.height);
    RECT_CHANGE_point(self.peakMeterIV, (WIDTH(self)-tempImage.size.width)/2, (HEIGHT(self)-tempImage.size.height)/2);
    
    RECT_CHANGE_x(self.countDownLabel, WIDTH(self)-WIDTH(self.countDownLabel));
}

- (void)initilization
{
    //初始化音量peak峰值图片数组
    self.peakImageAry = [[NSArray alloc]initWithObjects:
                    [UIImage imageNamed:@"ic_recording1.png"],
                    [UIImage imageNamed:@"ic_recording2.png"],
                    [UIImage imageNamed:@"ic_recording3.png"],
                    [UIImage imageNamed:@"ic_recording4.png"],
                    [UIImage imageNamed:@"ic_recording5.png"],nil];
    
    self.countDownLabel.font = [UIFont systemFontOfSize:10];
}

#pragma mark -还原显示界面
- (void)restoreDisplay
{
    //还原录音图
    if ([self.peakImageAry count]>0)
    {
        self.peakMeterIV.image = [self.peakImageAry objectAtIndex:0];
    }
    //还原倒计时文本
    self.countDownLabel.text = @"0“";
}

#pragma mark - 更新音频峰值
- (void)updateMetersByAvgPower:(float)_avgPower{
    //-160表示完全安静，0表示最大输入值
    //
    NSInteger imageIndex = 0;
    if (_avgPower >= -40 && _avgPower < -30)
        imageIndex = 1;
    else if (_avgPower >= -30 && _avgPower < -25)
        imageIndex = 2;
    else if (_avgPower >= -25)
        imageIndex = 3;
    
    self.peakMeterIV.image = [self.peakImageAry objectAtIndex:imageIndex];

}

@end


@interface VoiceConverterHelper ()<AVAudioRecorderDelegate>

AS_FLOAT(curCount);//当前计数,初始为0
AS_POINT(curTouchPoint);//触摸点
AS_MODEL_STRONG(NSTimer, timer);
AS_BOOL(canNotSend);//不能发送
AS_MODEL_STRONG(ChatRecorderView, recorderView);//录音界面

AS_MODEL_STRONG(AVAudioRecorder, recorder);

@end

@implementation VoiceConverterHelper

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        self.maxRecordTime = kDefaultMaxRecordTime;
    }
    
    return self;
}

/**
	生成当前时间字符串
	@returns 当前时间字符串
 */
+ (NSString*)getCurrentTimeString
{
    NSDateFormatter *dateformat=[[NSDateFormatter  alloc]init];
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    return [dateformat stringFromDate:[NSDate date]];
}

/**
	获取缓存路径
	@returns 缓存路径
 */
+ (NSString*)getCacheDirectory
{
    NSString* tempDir = [NSString stringWithFormat:@"%@/",[DLSandbox tmpPath]];
    
    [DLCache createNewDir:tempDir];
    
    return tempDir;
}

/**
	判断文件是否存在
	@param _path 文件路径
	@returns 存在返回yes
 */
+ (BOOL)fileExistsAtPath:(NSString*)_path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:_path];
}

/**
	删除文件
	@param _path 文件路径
	@returns 成功返回yes
 */
+ (BOOL)deleteFileAtPath:(NSString*)_path
{
    return [[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
}

/**
	生成文件路径
	@param _fileName 文件名
	@param _type 文件类型
	@returns 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type
{
    return [[[self getCacheDirectory] stringByAppendingPathComponent:_fileName]stringByAppendingPathExtension:_type];
}

/**
 生成文件路径
 @param _fileName 文件名
 @returns 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)_fileName{
    
    return [[self getCacheDirectory] stringByAppendingPathComponent:_fileName];;
}

/**
	获取录音设置
	@returns 录音设置
 */
+ (NSDictionary*)getAudioRecorderSettingDict
{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                                   [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
                                   [NSNumber numberWithInt: AVAudioQualityMedium],AVEncoderAudioQualityKey,//音频编码质量
                                   nil];
    return recordSetting ;
}

#pragma mark - 开始录音
- (void)beginRecordByFileName:(NSString*)_fileName;{
    
    //设置文件名和录音路径
    self.recordFileName = _fileName;
    self.recordFilePath = [VoiceConverterHelper getPathByFileName:self.recordFileName ofType:@"wav"];
    
    //初始化录音
    self.recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL URLWithString:self.recordFilePath]
                                               settings:[VoiceConverterHelper getAudioRecorderSettingDict]
                                                  error:nil];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    
    [self.recorder prepareToRecord];
    
    //还原计数
    self.curCount = 0;
    //还原发送
    self.canNotSend = NO;
    
    //开始录音
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [self.recorder record];
    
    //启动计时器
    [self startTimer];
    
    //显示录音界面
    [self initRecordView];
    
    [UIView showView:self.recorderView
         animateType:AnimateTypeOfPopping
           finalRect:KRecorderViewRect
          completion:^(BOOL finish){
              if (finish){
                  //注册nScreenTouch事件
                  //[self addScreenTouchObserver];
              }
          }];
    //设置遮罩背景不可触摸
    [UIView setTopMaskViewCanTouch:NO];

    
}
#pragma mark - 初始化录音界面
- (void)initRecordView{
    
    if (self.recorderView == nil)
        self.recorderView = [[ChatRecorderView alloc]initWithFrame:CGRectZero];
    //还原界面显示
    [self.recorderView restoreDisplay];
}
#pragma mark - 启动定时器
- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
}

#pragma mark - 停止定时器
- (void)stopTimer
{
    if (self.timer && self.timer.isValid){
        [self.timer invalidate];
        self.timer = nil;
    }
}
#pragma mark - 更新音频峰值
- (void)updateMeters
{
    if (self.recorder.isRecording){
        
        //更新峰值
        [self.recorder updateMeters];
        
        [self.recorderView updateMetersByAvgPower:[self.recorder averagePowerForChannel:0]];
        
        self.recorderView.countDownLabel.text = [NSString stringWithFormat:@"%d“",(int)(self.curCount)];
        //倒计时
        if (self.curCount >= self.maxRecordTime - 10 && self.curCount < self.maxRecordTime) {
            //剩下10秒
        }else if (self.curCount >= self.maxRecordTime){
            //时间到
            [self touchEnded:self.curTouchPoint];
        }
        self.curCount += 0.1f;
    }
}

#pragma mark - 移除触摸观察者
- (void)removeScreenTouchObserver{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"nScreenTouch" object:nil];//移除nScreenTouch事件
}
#pragma mark - 添加触摸观察者
- (void)addScreenTouchObserver{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onScreenTouch:) name:@"nScreenTouch" object:nil];
}
-(void)onScreenTouch:(NSNotification *)notification {
    UIEvent *event=[notification.userInfo objectForKey:@"data"];
    NSSet *allTouches = event.allTouches;
    
    //如果未触摸或只有单点触摸
    if ((self.curTouchPoint.x == CGPointZero.x && self.curTouchPoint.y == CGPointZero.y) || allTouches.count == 1)
        [self transferTouch:[allTouches anyObject]];
    else{
        //遍历touch,找到最先触摸的那个touch
        for (UITouch *touch in allTouches){
            CGPoint prePoint = [touch previousLocationInView:nil];
            
            if (prePoint.x == self.curTouchPoint.x && prePoint.y == self.curTouchPoint.y)
                [self transferTouch:touch];
        }
    }
}
//传递触点
- (void)transferTouch:(UITouch*)_touch{
    CGPoint point = [_touch locationInView:nil];
    switch (_touch.phase) {
        case UITouchPhaseBegan:
            [self touchBegan:point];
            break;
        case UITouchPhaseMoved:
            [self touchMoved:point];
            break;
        case UITouchPhaseCancelled:
        case UITouchPhaseEnded:
            [self touchEnded:point];
            break;
        default:
            break;
    }
}
#pragma mark - 触摸开始
- (void)touchBegan:(CGPoint)_point{
    self.curTouchPoint = _point;
}
#pragma mark - 触摸移动
- (void)touchMoved:(CGPoint)_point{
    self.curTouchPoint = _point;
    //判断是否移动到取消区域
    self.canNotSend = _point.y < kCancelOriginY ? YES : NO;
    
    //设置取消动画
//    [self.recorderView prepareToDelete:self.canNotSend];
}
#pragma mark - 触摸结束
- (void)touchEnded:(CGPoint)_point{
    //停止计时器
    [self stopTimer];
    
    self.curTouchPoint = CGPointZero;
    [self removeScreenTouchObserver];
    
    [UIView hideViewByCompletion:^(BOOL finish){
        
        //停止录音
        if (self.recorder.isRecording)
            [self.recorder stop];
        
        if (self.canNotSend) {
            //取消发送，删除文件
            [VoiceConverterHelper deleteFileAtPath:self.recordFilePath];
        }else{
            //回调录音文件路径
            [self handleRecordFinish:self.recordFilePath withFileName:self.recordFileName];
        }
    }];
}

-(void)stopRecorder
{
    [self stopTimer];
    
    [UIView hideViewByCompletion:^(BOOL finish){
        
        //停止录音
        if (self.recorder.isRecording){
            [self.recorder stop];
        }
        //回调录音文件路径
        [self handleRecordFinish:self.recordFilePath withFileName:self.recordFileName];
    }];
}

-(void)handleRecordFinish:(NSString*)filepath withFileName:(NSString*)filename
{
    NSMutableDictionary* tempDic = [[NSMutableDictionary alloc]init];
    [tempDic sObject:filename forKey:@"filename"];
    [tempDic sObject:filepath forKey:@"filepath"];
    if (self.block!=nil) {
        self.block(0,tempDic);
    }
}

#pragma mark - AVAudioRecorder Delegate Methods
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"录音停止");
    [self stopTimer];
    self.curCount = 0;
}
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder{
    NSLog(@"录音开始");
    [self stopTimer];
    self.curCount = 0;
}
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags{
    NSLog(@"录音中断");
    [self stopTimer];
    self.curCount = 0;
}


@end
