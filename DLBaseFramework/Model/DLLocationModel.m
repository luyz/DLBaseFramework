//
//  DLLocationModel.m
//  DLBase
//
//  Created by lucaslu on 16/1/18.
//  Copyright © 2016年 lucaslu. All rights reserved.
//

#import "DLLocationModel.h"

@implementation DLLocationModel

DEF_FACTORY(DLLocationModel);

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

-(void)setLocation:(NSString*)lat withLng:(NSString*)lng withUrl:(NSString*)url withPath:(NSString*)path withImage:(UIImage*)image
{
    self.myImage = image;
    self.myImagePath = path;
    self.myImageUrl = url;
    self.myLat = lat;
    self.myLng = lng;
}

@end
