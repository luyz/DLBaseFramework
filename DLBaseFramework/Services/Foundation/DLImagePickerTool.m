//
//  DLImagePickerTool.m
//  TickTock
//
//  Created by 卢迎志 on 14-12-3.
//  Copyright (c) 2014年 卢迎志. All rights reserved.
//

#import "DLImagePickerTool.h"
#import <AVFoundation/AVFoundation.h>
#import "DLSandbox.h"
#import "DLCache.h"
#import "NSDate+DLExtension.h"

@interface DLImagePickerTool ()

AS_MODEL_STRONG(UIViewController, currController);
AS_BLOCK(ImagePickerToolBlock, toolBlock);
AS_BLOCK(ImagePickerVideoToolBlock, videoToolBlock);

AS_MODEL_STRONG(UIAlertView, myAlertView);

AS_MODEL_STRONG(NSString, videoPath);
AS_MODEL_STRONG(NSString, videologo);
AS_MODEL_STRONG(NSString, videoLenght);
AS_MODEL_STRONG(NSURL, videoUrl);

AS_INT(currSourceType);
AS_BOOL(isEdit);
AS_FLOAT(videoMaxTime);


@end

@implementation DLImagePickerTool

DEF_SINGLETON(DLImagePickerTool);

DEF_MODEL(currController);
DEF_MODEL(toolBlock);
DEF_MODEL(videoToolBlock);

DEF_MODEL(videoLenght);
DEF_MODEL(videologo);
DEF_MODEL(videoPath);
DEF_MODEL(videoUrl);

DEF_MODEL(currSourceType);
DEF_MODEL(isEdit);
DEF_MODEL(videoMaxTime);

-(id)init
{
    self = [super init];
    if (self) {
        self.isEdit = NO;
        self.videoMaxTime = 10.0;
    }
    return self;
}

-(void)showImagePickerSheet:(UIViewController*)controller
                  withBlock:(ImagePickerToolBlock)block
                 withIsEdit:(BOOL)edit
{
    self.currController = controller;
    self.toolBlock = [block copy];
    self.isEdit = edit;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"拍照", @"图片库",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = 9001;
    [actionSheet showInView:controller.view];
}

#pragma UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 9001) {
        if (buttonIndex == 0) {
            [self showPhoto:0];
        }else if (buttonIndex == 1){
            [self showPhoto:1];
        }
    }else if(actionSheet.tag == 9009){
        if (buttonIndex == 0) {
            [self showPhoto:3];
        }else if (buttonIndex == 1){
            [self showPhoto:2];
        }
    }
}

-(void)showImagePickerCamera:(UIViewController*)controller
                   withBlock:(ImagePickerToolBlock)block
                  withIsEdit:(BOOL)edit
{
    self.currController = controller;
    self.toolBlock = [block copy];
    self.isEdit = edit;
    
    [self showPhoto:0];
}

-(void)showImagePickerLibs:(UIViewController*)controller
                 withBlock:(ImagePickerToolBlock)block
                withIsEdit:(BOOL)edit
{
    self.currController = controller;
    self.toolBlock = [block copy];
    self.isEdit = edit;
    
    [self showPhoto:1];
}

-(void)showImagePickerVideo:(UIViewController*)controller
                  withBlock:(ImagePickerVideoToolBlock)block
                withMaxTime:(CGFloat)time
{
    self.currController = controller;
    self.videoToolBlock = [block copy];
    self.videoMaxTime = time;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"本地视频", @"录取视频",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = 9009;
    [actionSheet showInView:controller.view];
}

-(void)showPhoto:(int)sourcetype
{
    UIImagePickerController* pickerView = [[UIImagePickerController alloc] init];
    pickerView.view.backgroundColor = [UIColor blackColor];
    pickerView.navigationBarHidden=YES;
    self.currSourceType = sourcetype;
    if (sourcetype == 0) {
        pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
        [pickerView setEditing:self.isEdit animated:YES];
        pickerView.allowsEditing = self.isEdit;
    }else if (sourcetype == 1){
        pickerView.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [pickerView setEditing:self.isEdit animated:YES];
        pickerView.allowsEditing = self.isEdit;
    }else if(sourcetype == 2){
        pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSArray* availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        pickerView.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
        pickerView.videoMaximumDuration = 60;
        pickerView.videoQuality = UIImagePickerControllerQualityTypeMedium;
    }else if(sourcetype == 3){
        pickerView.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        NSArray* availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        pickerView.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
    }
    [self.currController presentViewController:pickerView animated:YES completion:nil];
    
    pickerView.delegate = self;
}

#pragma UINavigationControllerDelegate, UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (self.currSourceType == 0 || self.currSourceType == 1) {
        UIImage* tempimage=[info valueForKey:UIImagePickerControllerOriginalImage];
        UIImage *changeImage = [self fixOrientation:tempimage];
        UIImage *scaleImage = [self imageCompressForWidth:changeImage targetWidth:640];
        if (self.toolBlock!=nil) {
            self.toolBlock(scaleImage);
        }
    }else if(self.currSourceType == 2|| self.currSourceType == 3){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDir = [paths objectAtIndex:0];
        NSString *videoAndFilepath = [NSString stringWithFormat:@"%@/FileAndVideo",cachesDir];
        //NSString *nowTime = [NSDate systemTime];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *nowTime = [dateFormatter stringFromDate:[NSDate date]];
        
        self.videoUrl = info [UIImagePickerControllerMediaURL];
        self.videoLenght = [NSString stringWithFormat:@"%.0f",[self getVideoDuration:self.videoUrl]];
        self.videoPath = [NSString stringWithFormat:@"%@/%@",videoAndFilepath,[NSString stringWithFormat:@"videoout%@.mp4",nowTime]];
        self.videologo = [NSString stringWithFormat:@"%@/%@.png",videoAndFilepath,nowTime];
        [self videoAv:self.videoUrl withPath:self.videologo];
        [self encodeMovToMp4:self.videoUrl withPath:self.videoPath];
    }
}


-(UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth
{
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = (targetWidth / width) * height;
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [sourceImage drawInRect:CGRectMake(0,0,targetWidth, targetHeight)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation ==UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform =CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width,0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width,0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height,0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx =CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                            CGImageGetBitsPerComponent(aImage.CGImage),0,
                                            CGImageGetColorSpace(aImage.CGImage),
                                            CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx,CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx,CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg =CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissImagePicker:picker];
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {

    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        
        //[[UIApplication sharedApplication] setStatusBarHidden:YES];
        //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];

        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            //刷新状态条
            //从拍照返回后强制设置
            //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
            [self.currController setNeedsStatusBarAppearanceUpdate];
        }
    }
}

- (CGFloat) getVideoDuration:(NSURL*) URL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:opts];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    return second;
}

- (void)encodeMovToMp4:(NSURL*)vUrl withPath:(NSString*)filepath
{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:vUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality])
    {
        UIAlertView* alert = [[UIAlertView alloc] init];
        [alert setTitle:@"Waiting.."];
        
        UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activity.frame = CGRectMake(140,
                                    80,
                                    CGRectGetWidth(alert.frame),
                                    CGRectGetHeight(alert.frame));
        [alert addSubview:activity];
        [activity startAnimating];
        self.myAlertView = alert;
        [alert show];
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetMediumQuality];
        
        exportSession.outputURL = [NSURL fileURLWithPath: filepath];
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:[[exportSession error] localizedDescription]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles: nil];
                    [alert show];
                    break;
                }
                    
                case AVAssetExportSessionStatusCancelled:
                    [self.myAlertView dismissWithClickedButtonIndex:0
                                                           animated:YES];
                    break;
                case AVAssetExportSessionStatusCompleted:
                    [self performSelectorOnMainThread:@selector(convertFinish) withObject:nil waitUntilDone:NO];
                    break;
                default:
                    break;
            }
        }];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"AVAsset doesn't support mp4 quality"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

-(void)videoAv:(NSURL*)pathUrl withPath:(NSString*)path
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:pathUrl options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    
    [DLCache writeJPGImage:thumb toDocumentPath:path WithCompressionQuality:0.8];
}

- (void) convertFinish
{
    if (self.videoToolBlock != nil) {
        self.videoToolBlock(self.videoPath,self.videologo,self.videoLenght);
    }
    
    [self.myAlertView dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)dismissImagePicker:(UIImagePickerController*)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
