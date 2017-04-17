//
//  DLLoadLib.m
//  TickTock
//
//  Created by 卢迎志 on 14-11-27.
//  Copyright (c) 2014年 卢迎志. All rights reserved.
//

#import "DLLoadLib.h"

@implementation DLLoadLib

+(UIView*)loadLib:(NSString*)name owner:(id)owner
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:name owner:owner options:nil];
    UIView *tmpCustomView = [nib objectAtIndex:0];

    return tmpCustomView;
}

@end
