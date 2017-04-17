//
//  DLImageModel.m
//  Auction
//
//  Created by 卢迎志 on 15-1-6.
//
//

#import "DLImageModel.h"
#import "DLLog.h"
#import "DLCache.h"

@implementation DLImageModel

DEF_FACTORY(DLImageModel);
DEF_MODEL(image);
DEF_MODEL(imagePath);

-(void)setImage:(UIImage *)img withPath:(NSString*)path  withUrl:(NSString*)url withSize:(CGSize)size
{
    self.image = img;
    self.imagePath = path;
    self.imageUrl = url;
    self.imageSize = size;
    
    INFO(@"path:%@",path);
    
    [DLCache writePNGImage:img toDocumentPath:path];
}

@end
