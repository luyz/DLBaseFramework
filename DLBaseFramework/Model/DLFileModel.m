//
//  DLFileModel.m
//  DLBase
//
//  Created by lucaslu on 16/1/18.
//  Copyright © 2016年 lucaslu. All rights reserved.
//

#import "DLFileModel.h"

@implementation DLFileModel

DEF_FACTORY(DLFileModel);

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

-(void)setMyFileName:(NSString *)name
{
    _myFileName = name;
    
    NSArray* tempArray = [name componentsSeparatedByString:@"."];
    
    if (tempArray!=nil && [tempArray count]>0) {
        
        //大写
        self.myFileSuffix = [[tempArray lastObject] uppercaseString];
        
        if ([self.myFileSuffix isEqualToString:@"JPG"] ||
            [self.myFileSuffix isEqualToString:@"PNG"] ||
            [self.myFileSuffix isEqualToString:@"GIF"] ||
            [self.myFileSuffix isEqualToString:@"JPEG"]) {
            self.myFileType = EFile_Image;
        }else if ([self.myFileSuffix isEqualToString:@"DOC"] ||
                  [self.myFileSuffix isEqualToString:@"DOCX"]){
            self.myFileType = EFile_Word;
        }else if ([self.myFileSuffix isEqualToString:@"XLS"] ||
                  [self.myFileSuffix isEqualToString:@"XLSX"]){
            self.myFileType = EFile_Excel;
        }else if ([self.myFileSuffix isEqualToString:@"PPT"] ||
                  [self.myFileSuffix isEqualToString:@"PPTX"]){
            self.myFileType = EFile_Ppt;
        }else if ([self.myFileSuffix isEqualToString:@"PDF"]){
            self.myFileType = EFile_Pdf;
        }else if ([self.myFileSuffix isEqualToString:@"MP4"]){
            self.myFileType = EFile_Video;
        }else if ([self.myFileSuffix isEqualToString:@"AMR"] ||
                  [self.myFileSuffix isEqualToString:@"AAC"]){
            self.myFileType = EFile_Voice;
        }else if ([self.myFileSuffix isEqualToString:@"ZIP"] ||
                  [self.myFileSuffix isEqualToString:@"RAR"]){
            self.myFileType = EFile_Zip;
        }else{
            self.myFileType = EFile_Other;
        }
    }
}

-(void)setFile:(NSString*)url withPath:(NSString*)path withSize:(NSString*)size withName:(NSString*)name
{
    self.myFileUrl = url;
    self.myFilePath = path;
    self.myFileSize = size;
    
    self.myFileName = name;
}

@end
