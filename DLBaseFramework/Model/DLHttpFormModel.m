//
//  DLHttpFormModel.m
//  TickTock
//
//  Created by 卢迎志 on 14-12-6.
//  Copyright (c) 2014年 卢迎志. All rights reserved.
//

#import "DLHttpFormModel.h"

@implementation DLHttpFormModel

DEF_FACTORY(DLHttpFormModel);

DEF_MODEL(filekey);
DEF_MODEL(filepath);
DEF_MODEL(fileUrl);

-(void)setFilepath:(NSString *)path
{
    filepath = path;
    self.fileUrl = [NSURL fileURLWithPath:path];
}

@end
