//
//  DLLocationModel.h
//  DLBase
//
//  Created by lucaslu on 16/1/18.
//  Copyright © 2016年 lucaslu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLFactory.h"
#import "DLModel.h"
#import <UIKit/UIKit.h>

@interface DLLocationModel : NSObject

AS_FACTORY(DLLocationModel);

AS_MODEL_STRONG(NSString, myLat);
AS_MODEL_STRONG(NSString, myLng);

AS_MODEL_STRONG(NSString, myImageUrl);
AS_MODEL_STRONG(NSString, myImagePath);

AS_MODEL_STRONG(UIImage, myImage);

-(void)setLocation:(NSString*)lat
           withLng:(NSString*)lng
           withUrl:(NSString*)url
          withPath:(NSString*)path
         withImage:(UIImage*)image;

@end
