//
//  DLLog.m
//  TickTock
//
//  Created by 卢迎志 on 14-12-6.
//  Copyright (c) 2014年 卢迎志. All rights reserved.
//

#import "DLLog.h"
#import "DLSystemInfo.h"

void PRPDebug(const char *fileName, int lineNumber,const char *functionName, NSString *fmt, ...)
{
    va_list args;
    
    va_start(args, fmt);
    
    static NSDateFormatter *debugFormatter = nil;
    
    if (debugFormatter == nil) {
        debugFormatter = [[NSDateFormatter alloc] init];
        [debugFormatter setDateFormat:@"yyyyMMdd.HH:mm:ss"];
    }
    
    NSString *msg = [[NSString alloc] initWithFormat:fmt arguments:args];
    
    NSString        *fName = [NSString stringWithUTF8String:functionName];
    NSString        *filePath = [[NSString alloc] initWithUTF8String:fileName];
    NSString        *timestamp = [debugFormatter stringFromDate:[NSDate date]];
    NSDictionary    *info = [[NSBundle mainBundle] infoDictionary];
    NSString        *appName = [info objectForKey:(NSString *)kCFBundleNameKey];
    
    NSString* printf = [NSString stringWithFormat:@"%s %s[%s:%d:%s] %s\n",[timestamp UTF8String], [appName UTF8String], [[filePath lastPathComponent] UTF8String], lineNumber,[fName UTF8String], [msg UTF8String]];
    
    fprintf(stdout, "%s", [printf UTF8String]);
    
    va_end(args);
}

@implementation DLLog

DEF_SINGLETON(DLLog);

-(id)init
{
    self = [super init];
    if (self) {
        [self printLogo];
    }
    return self;
}

- (void)printLogo
{
#if TARGET_OS_IPHONE
	NSString * homePath;
	homePath = [NSBundle mainBundle].bundlePath;
	homePath = [homePath stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
    
	fprintf( stderr, "    	|	|  |        							\n" );
	fprintf( stderr, "    	|	|  |    	   							\n" );
	fprintf( stderr, "    	|__	|__|	 	  							\n" );
	fprintf( stderr, "    												\n" );
	fprintf( stderr, "    												\n" );
	fprintf( stderr, "os: %s	       \n", [DLSystemInfo OSVersion].UTF8String );
	fprintf( stderr, "deviceModel: %s \n", [DLSystemInfo deviceModel].UTF8String );
	fprintf( stderr, "appSchema :%s \n",[DLSystemInfo appSchema].UTF8String);
	fprintf( stderr, "UUID: %s	  \n", [DLSystemInfo deviceUUID].UTF8String );
    fprintf( stderr, "appName: %s	  \n", [DLSystemInfo appName].UTF8String );
    fprintf( stderr, "projectName: %s	  \n", [DLSystemInfo projectName].UTF8String );
    fprintf( stderr, "mainScreenSize: %s	  \n", NSStringFromCGSize([DLSystemInfo mainScreenSize]).UTF8String);
    fprintf( stderr, "mainScaleSize: %s	  \n", NSStringFromCGSize([DLSystemInfo mainScaleSize]).UTF8String );
    fprintf( stderr, "appIdentifier: %s	  \n", [DLSystemInfo appIdentifier].UTF8String );
    fprintf( stderr, "appVersion: %s	  \n", [DLSystemInfo appVersion].UTF8String );
    fprintf( stderr, "appShortVersion: %s	  \n", [DLSystemInfo appShortVersion].UTF8String );
    fprintf( stderr, "getPreferredLanguage: %s	  \n", [DLSystemInfo getPreferredLanguage].UTF8String );
    fprintf( stderr, "Home: %s	                   \n", homePath.UTF8String );
    fprintf( stderr, "    												\n" );
    
#endif	// #if TARGET_OS_IPHONE
}

#if __DL_DEVELOPMENT__
- (void)file:(NSString *)file line:(NSUInteger)line function:(NSString *)function level:(NSString*)level format:(NSString *)format, ...
#else	// #if __DL_DEVELOPMENT__
- (void)level:(NSString*)level format:(NSString *)format, ...
#endif	// #if __DL_DEVELOPMENT__
{
#if (__ON__ == __DL_LOG__)
	
	if ( nil == format || NO == [format isKindOfClass:[NSString class]] )
		return;
    
	va_list args;
	va_start( args, format );
    
#if __DL_DEVELOPMENT__
	[self file:file line:line function:function level:level format:format args:args];
#else	// #if __DL_DEVELOPMENT__
	[self level:level format:format args:args];
#endif	// #if __DL_DEVELOPMENT__
    
	va_end( args );
    
#endif	// #if (__ON__ == __DL_LOG__)
}

#if __DL_DEVELOPMENT__
- (void)file:(NSString *)file line:(NSUInteger)line function:(NSString *)function level:(NSString*)level format:(NSString *)format args:(va_list)args
#else	// #if __DL_DEVELOPMENT__
- (void)level:(NSString*)level format:(NSString *)format args:(va_list)args
#endif	// #if __DL_DEVELOPMENT__
{
#if (__ON__ == __DL_LOG__)
    
    // formatting
	NSMutableString * text = [NSMutableString string];
	
    static NSDateFormatter *debugFormatter = nil;
    
    if (debugFormatter == nil) {
        debugFormatter = [[NSDateFormatter alloc] init];
        [debugFormatter setDateFormat:@"yyyyMMdd.HH:mm:ss"];
    }
    
    NSString        *fName = [NSString stringWithString:function];
    NSString        *filePath = [NSString stringWithString:file];
    
    NSString        *timestamp = [debugFormatter stringFromDate:[NSDate date]];
    NSDictionary    *info = [[NSBundle mainBundle] infoDictionary];
    NSString        *appName = [info objectForKey:(NSString *)kCFBundleNameKey];
    
    NSString* printf = [NSString stringWithFormat:@"%s %s [%s:%lu] \n %s \n",[timestamp UTF8String], [appName UTF8String], [[filePath lastPathComponent] UTF8String], (unsigned long)line,[fName UTF8String]];
    
    [text appendString:printf];
    
    if (level && [level length] > 0) {
        NSMutableString * temp = [NSMutableString string];
        
		[temp appendString:level];
        
		if ( temp.length )
		{
			NSString * temp2 = [temp stringByPaddingToLength:((temp.length / 8) + 1) * 8 withString:@" " startingAtIndex:0];
			[text appendString:temp2];
		}
    }
    
	NSString * content = [[NSString alloc] initWithFormat:(NSString *)format arguments:args] ;
	if ( content && content.length )
	{
		[text appendString:content];
	}
	
	if ( [text rangeOfString:@"\n"].length )
	{
		[text replaceOccurrencesOfString:@"\n"
							  withString:[NSString stringWithFormat:@"\n%@", @"$"]
								 options:NSCaseInsensitiveSearch
								   range:NSMakeRange( 0, text.length )];
	}
    
	if ( [text rangeOfString:@"%"].length )
	{
		[text replaceOccurrencesOfString:@"%"
							  withString:@"%%"
								 options:NSCaseInsensitiveSearch
								   range:NSMakeRange( 0, text.length )];
	}
    
	// print to console
	
	fprintf( stderr, [text UTF8String], NULL );
	fprintf( stderr, "\n", NULL );
    
	// back log
	
#if __DL_DEVELOPMENT__
	//err or waing
    
    
#endif	// #if __DL_DEVELOPMENT__
#endif	// #if (__ON__ == __DL_LOG__)
}

@end

#if __cplusplus
extern "C"
#endif	// #if __cplusplus
void Print_Log( NSString * format, ... )
{
#if (__ON__ == __DL_LOG__)
	
	if ( nil == format || NO == [format isKindOfClass:[NSString class]] )
		return;
	
	va_list args;
	va_start( args, format );
	
#if __DL_DEVELOPMENT__
	[[DLLog sharedInstance] file:nil line:0 function:nil level:@"" format:format args:args];
#else	// #if __DL_DEVELOPMENT__
	[[DLLog sharedInstance] level:@"" format:format args:args];
#endif	// #if __DL_DEVELOPMENT__
    
	va_end( args );
    
#endif	// #if (__ON__ == __DL_LOG__)
}