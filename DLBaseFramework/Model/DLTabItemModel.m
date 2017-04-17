//
//  DLTabItemModel.m
//  TickTock
//
//  Created by 卢迎志 on 14-11-26.
//  Copyright (c) 2014年 卢迎志. All rights reserved.
//

#import "DLTabItemModel.h"

@implementation DLTabItemModel

DEF_FACTORY(DLTabItemModel);

DEF_MODEL(tabIcon);
DEF_MODEL(tabIcon_H);
DEF_MODEL(tabItem);
DEF_MODEL(tabItemColor);
DEF_MODEL(tabItemColor_H);

-(id)initWithIcon:(NSString*)icon
       withIcon_H:(NSString*)icon_h
         withItem:(NSString*)item
    withItemColor:(UIColor*)itemColor
  withItemColor_H:(UIColor*)itemColor_h
{
    self = [super init];
    if (self) {
        self.tabItem = item;
        self.tabIcon = icon;
        self.tabIcon_H = icon_h;
        self.tabItemColor = itemColor;
        self.tabItemColor_H = itemColor_h;
    }
    return self;
}


@end
