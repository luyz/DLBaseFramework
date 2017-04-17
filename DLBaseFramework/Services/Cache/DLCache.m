//
//  DLCache.m
//  TickTock
//
//  Created by 卢迎志 on 14-12-5.
//  Copyright (c) 2014年 卢迎志. All rights reserved.
//

#import "DLCache.h"
#import "DLSandbox.h"
#import "DLSystemInfo.h"
#import "NSString+DLExtension.h"
#import "DLSystemInfo.h"
#import "DLBaseEngine.h"

@interface DLCache ()

AS_MODEL_STRONG(NSFileManager, fileManager);

@end

@implementation DLCache

DEF_SINGLETON(DLCache);

DEF_MODEL(cachePath);
DEF_MODEL(cacheUser);
DEF_MODEL(fileManager);

- (id)init
{
    self = [super init];
    if ( self )
    {
        self.cacheUser = [DLSystemInfo deviceUUID];

        self.cachePath = [NSString stringWithFormat:@"%@/", [DLSandbox libCachePath]];
        
        self.fileManager = [NSFileManager defaultManager];
    }
    return self;
}
+(NSString*)docToUserDir
{
    return [NSString stringWithFormat:@"%@/%@/",[DLSandbox docPath],[DLCache sharedInstance].cacheUser];
}
+(NSString*)libCachesToTemp
{
    return [DLCache sharedInstance].cachePath;
}

+(NSString*)libCachesToUser
{
    return [NSString stringWithFormat:@"%@%@/",[DLCache sharedInstance].cachePath,[DLCache sharedInstance].cacheUser];
}

+(BOOL)isFileExists:(NSString*)filePath
{
    return [[DLCache sharedInstance] isFileExists:filePath];
}
+(BOOL)isDirExists:(NSString*)dirPath
{
    return [[DLCache sharedInstance] isDirExists:dirPath];
}
+(void)createNewDir:(NSString*)path
{
    [[DLCache sharedInstance] createNewDir:path];
}
+(BOOL)removeItem:(NSString*)path
{
    return [[DLCache sharedInstance] removeItem:path];
}

//document save
+(void)writeString:(NSString*)string toDocumentPath:(NSString*)path
{
    [[DLCache sharedInstance] writeString:string toDocumentPath:path];
}
+(NSString*)getStringFromDocumentPath:(NSString*)path
{
    return [[DLCache sharedInstance] getStringFromDocumentPath:path];
}

+(void)writeData:(NSData*)data toDocumentPath:(NSString*)path
{
    [[DLCache sharedInstance] writeData:data toDocumentPath:path];
}
+(NSData*)getDataFromDocumentPath:(NSString*)path
{
    return [[DLCache sharedInstance] getDataFromDocumentPath:path];
}

+(void)writeImage:(UIImage*)image toDocumentPath:(NSString*)path
{
    [[DLCache sharedInstance] writeImage:image toDocumentPath:path];
}
+(void)writePNGImage:(UIImage*)image toDocumentPath:(NSString*)path
{
    [[DLCache sharedInstance] writePNGImage:image toDocumentPath:path];
}

+(void)writeJPGImage:(UIImage*)image toDocumentPath:(NSString*)path WithCompressionQuality:(float)quality
{
    [[DLCache sharedInstance] writeJPGImage:image toDocumentPath:path WithQuality:quality];
}
+(UIImage*)getImageFromDocumentPath:(NSString*)path
{
    return [[DLCache sharedInstance] getImageFromDocumentPath:path];
}

+(void)writeArray:(NSMutableArray*)array toDocumentPath:(NSString*)path
{
    [[DLCache sharedInstance]writeArray:array toDocumentPath:path];
}
+(NSMutableArray*)getArrayFromDocumentPath:(NSString*)path
{
    return [[DLCache sharedInstance] getArrayFromDocumentPath:path];
}

+(void)writeDictionary:(NSMutableDictionary*)dictionary toDocumentPath:(NSString*)path
{
    [[DLCache sharedInstance] writeDictionary:dictionary toDocumentPath:path];
}
+(NSMutableDictionary*)getDictionaryFromDocumentPath:(NSString*)path
{
    return [[DLCache sharedInstance] getDictionaryFromDocumentPath:path];
}

-(BOOL)isFileExists:(NSString*)filePath
{
    return [self.fileManager fileExistsAtPath:filePath];
}

-(BOOL)isDirExists:(NSString*)dirPath
{
    BOOL isdir = YES;
    BOOL result = [self.fileManager fileExistsAtPath:dirPath isDirectory:&isdir];
    return result && isdir;
}

-(void)createNewDir:(NSString*)path
{
    NSString* tempPath = [path asDirPath];
    
    if (![self isDirExists:tempPath]) {
        [self.fileManager createDirectoryAtPath:tempPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
}

-(BOOL)removeItem:(NSString*)path
{
    return [self.fileManager removeItemAtPath:path error:NULL];
}

//document save
-(void)writeString:(NSString*)string toDocumentPath:(NSString*)path
{
    BOOL find = [self isFileExists:path];
    if (!find)
    {
        [self createNewDir:path];
    }
    [string writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

-(NSString*)getStringFromDocumentPath:(NSString*)path
{
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

-(void)writeData:(NSData*)data toDocumentPath:(NSString*)path
{
    BOOL find = [self isFileExists:path];
	if (!find)
	{
		[self createNewDir:path];
	}
    [data writeToFile:path atomically:NO];
}

-(NSData*)getDataFromDocumentPath:(NSString*)path
{
    return [NSData dataWithContentsOfFile:path];
}

-(void)writeImage:(UIImage*)image toDocumentPath:(NSString*)path
{
    NSData *imageData= UIImagePNGRepresentation(image);
    [self writeData:imageData toDocumentPath:path];
}


-(void)writeJPGImage:(UIImage*)image toDocumentPath:(NSString*)path WithQuality:(float)quality
{
    NSData *imageData= UIImageJPEGRepresentation(image,quality);
    [self writeData:imageData toDocumentPath:path];
}

-(void)writePNGImage:(UIImage*)image toDocumentPath:(NSString*)path
{
    NSData *imageData= UIImagePNGRepresentation(image);
    [self writeData:imageData toDocumentPath:path];
}

-(UIImage*)getImageFromDocumentPath:(NSString*)path
{
    return [UIImage imageWithData:[self getDataFromDocumentPath:path]];
}

-(void)writeArray:(NSMutableArray*)array toDocumentPath:(NSString*)path
{
    BOOL find = [self isFileExists:path];
    if (!find)
    {
        [self createNewDir:path];
    }
    [array writeToFile:path atomically:NO];
}

-(NSMutableArray*)getArrayFromDocumentPath:(NSString*)path
{
    return [NSMutableArray arrayWithContentsOfFile:path];
}

-(void)writeDictionary:(NSMutableDictionary*)dictionary toDocumentPath:(NSString*)path
{
    BOOL find = [self isFileExists:path];
    if (!find)
    {
        [self createNewDir:path];
    }
    [dictionary writeToFile:path atomically:NO];
}

-(NSMutableDictionary*)getDictionaryFromDocumentPath:(NSString*)path
{
    return [NSMutableDictionary dictionaryWithContentsOfFile:path];
}

@end
