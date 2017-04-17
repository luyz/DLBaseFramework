//
//  DLPickerDataSource.m
//  Traderoute
//
//  Created by 卢迎志 on 15-1-27.
//  Copyright (c) 2015年 卢迎志. All rights reserved.
//

#import "DLPickerDataSource.h"
#import "NSArray+DLExtension.h"

@implementation DLPickerDataSource

DEF_FACTORY(DLPickerDataSource);

DEF_MODEL(pfirstWidth);
DEF_MODEL(pickComponentsCount);
DEF_MODEL(psecondWidth);
DEF_MODEL(pthreeWidth);
DEF_MODEL(seleteThreeIndex);
DEF_MODEL(seleteSecondIndex);
DEF_MODEL(seleteFirstIndex);
DEF_MODEL(secondArray);
DEF_MODEL(firstArray);
DEF_MODEL(threeArray);

-(id)init
{
    self = [super init];
    if(self){
        self.firstArray = [NSMutableArray allocInstance];
        self.secondArray = [NSMutableArray allocInstance];
        self.threeArray = [NSMutableArray allocInstance];
    }
    return self;
}

@end
