//
//  DLAsynThead.m
//  DLBaseFramework
//
//  Created by luyz on 2017/2/12.
//  Copyright © 2017年 luyz. All rights reserved.
//

#import "DLAsynThead.h"

@implementation DLAsynThead

+(void)toAsyn:(void (^)())block
{
    [DLAsynThead toAsynWait:0 withBlock:block];
}

+(void)toAsynWait:(NSTimeInterval)ti withBlock:(void (^)())block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:ti];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block!=nil) {
                block();
            }
        });
    });
}

@end
