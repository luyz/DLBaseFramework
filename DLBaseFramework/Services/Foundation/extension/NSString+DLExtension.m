//
//  NSString+DLExtension.m
//  TickTock
//
//  Created by 卢迎志 on 14-11-28.
//  Copyright (c) 2014年 卢迎志. All rights reserved.
//

#import "NSString+DLExtension.h"
#import "NSObject+DLTypeConversion.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonDigest.h>
#import "NSString+MD5.h"
#import "NSData+DLDes.h"

@implementation NSString(DLExtension)

DEF_DYNAMIC(APPEND);
DEF_DYNAMIC(LINE);
DEF_DYNAMIC(REPLACE);

DEF_DYNAMIC(toDate);
DEF_DYNAMIC(toData);
DEF_DYNAMIC(toMD5);
DEF_DYNAMIC(toSHA1);

- (NSData *)toData
{
	return [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
}

- (NSDate *)toDate
{
	NSTimeZone * local = [NSTimeZone localTimeZone];
	
	NSString * format = @"yyyy-MM-dd HH:mm:ss";
	NSString * text = [(NSString *)self substringToIndex:format.length];
	
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:format];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	return [NSDate dateWithTimeInterval:(3600 + [local secondsFromGMT])
							  sinceDate:[dateFormatter dateFromString:text]];
}

-(NSString*)DESEncrypt:(NSString*)key
{
      return  [JoDes encode:self key:key];
}
-(NSString*)DESDecrypt:(NSString*)key
{
    return  [JoDes decode:self key:key];
}

-(NSDate *)stringToDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSDate *destDate= [dateFormatter dateFromString:self];
    return destDate;
}
-(NSDate *)stringToTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:self];
    return destDate;
}
-(NSDate *)stringToTimeMM
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm"];
    NSDate *destDate= [dateFormatter dateFromString:self];
    return destDate;
}

-(NSDate *)stringToDateFormat:(NSString*)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSDate *destDate= [dateFormatter dateFromString:self];
    return destDate;
}

- (NSString*)isHttpAndAdd
{
    NSString* tempStr = self;
    
    NSRange pos = [tempStr rangeOfString:@"http"];
    
    if (pos.length==0) {
        tempStr = [NSString stringWithFormat:@"http://%@",tempStr];
    }
    
    return tempStr;
}

- (NSString*)asDirPath
{
    NSString* tempStr = self;
    NSString* tempstr2 = @"";
    NSRange tempRange = [tempStr rangeOfString:@"/"];
    
    while (tempRange.length>0) {
        
        NSString* tempFirstStr = [tempStr substringToIndex:tempRange.location+tempRange.length];
        
        tempstr2 = [NSString stringWithFormat:@"%@%@",tempstr2,tempFirstStr];
        
        tempStr = [tempStr substringFromIndex:tempRange.location+tempRange.length];
        
        tempRange = [tempStr rangeOfString:@"/"];
    }
    
    return tempstr2;
}

- (NSStringAppendBlock)APPEND
{
	NSStringAppendBlock block = ^ NSString * ( id first, ... )
	{
		va_list args;
		va_start( args, first );
        
		NSString * append = [[NSString alloc] initWithFormat:first arguments:args];
		
		NSMutableString * copy = [self mutableCopy];
		[copy appendString:append];
        
		va_end( args );
		
		return copy;
	};
    
	return [block copy];
}

- (NSStringAppendBlock)LINE
{
	NSStringAppendBlock block = ^ NSString * ( id first, ... )
	{
		NSMutableString * copy = [self mutableCopy];
        
		if ( first )
		{
			va_list args;
			va_start( args, first );
			
			NSString * append = [[NSString alloc] initWithFormat:first arguments:args];
			[copy appendString:append];
            
			va_end( args );
		}
        
		[copy appendString:@"\n"];
        
		return copy ;
	};
	
	return [block copy];
}

- (NSStringReplaceBlock)REPLACE
{
	NSStringReplaceBlock block = ^ NSString * ( NSString * string1, NSString * string2 )
	{
		return [self stringByReplacingOccurrencesOfString:string1 withString:string2];
	};
	
	return [block copy];
}

- (NSArray *)allURLs
{
	NSMutableArray * array = [NSMutableArray array];
	NSCharacterSet * charSet = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789$-_.+!*'():/"] invertedSet];
    
	NSInteger stringIndex = 0;
	while ( stringIndex < self.length )
	{
		NSRange searchRange = NSMakeRange(stringIndex, self.length - stringIndex);
		NSRange httpRange = [self rangeOfString:@"http://" options:NSCaseInsensitiveSearch range:searchRange];
		NSRange httpsRange = [self rangeOfString:@"https://" options:NSCaseInsensitiveSearch range:searchRange];
		
		NSRange startRange;
		if ( httpRange.location == NSNotFound )
		{
			startRange = httpsRange;
		}
		else if ( httpsRange.location == NSNotFound )
		{
			startRange = httpRange;
		}
		else
		{
			startRange = (httpRange.location < httpsRange.location) ? httpRange : httpsRange;
		}
		
		if (startRange.location == NSNotFound)
		{
			break;
		}
		else
		{
			NSRange beforeRange = NSMakeRange( searchRange.location, startRange.location - searchRange.location );
			if ( beforeRange.length )
			{
				//				NSString * text = [string substringWithRange:beforeRange];
				//				[array addObject:text];
			}
            
			NSRange subSearchRange = NSMakeRange(startRange.location, self.length - startRange.location);
            //			NSRange endRange = [self rangeOfString:@" " options:NSCaseInsensitiveSearch range:subSearchRange];
			NSRange endRange = [self rangeOfCharacterFromSet:charSet options:NSCaseInsensitiveSearch range:subSearchRange];
			if ( endRange.location == NSNotFound)
			{
				NSString * url = [self substringWithRange:subSearchRange];
				[array addObject:url];
				break;
			}
			else
			{
				NSRange URLRange = NSMakeRange(startRange.location, endRange.location - startRange.location);
				NSString * url = [self substringWithRange:URLRange];
				[array addObject:url];
				
				stringIndex = endRange.location;
			}
		}
	}
	
	return array;
}

+ (NSString *)queryStringFromDictionary:(NSDictionary *)dict
{
    return [self queryStringFromDictionary:dict encoding:YES];
}

+ (NSString *)queryStringFromDictionary:(NSDictionary *)dict encoding:(BOOL)encoding
{
    NSMutableArray * pairs = [NSMutableArray array];
	for ( NSString * key in dict.allKeys )
	{
		NSString * value = [((NSObject *)[dict objectForKey:key]) asNSString];
		NSString * urlEncoding = encoding ? [value URLEncoding] : value;
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, urlEncoding]];
	}
	
	return [pairs componentsJoinedByString:@"&"];
}

+ (NSString *)queryStringFromArray:(NSArray *)array
{
    return [self queryStringFromArray:array encoding:YES];
}

+ (NSString *)queryStringFromArray:(NSArray *)array encoding:(BOOL)encoding
{
	NSMutableArray *pairs = [NSMutableArray array];
	
	for ( NSUInteger i = 0; i < [array count]; i += 2 )
	{
		NSObject * obj1 = [array objectAtIndex:i];
		NSObject * obj2 = [array objectAtIndex:i + 1];
		
		NSString * key = nil;
		NSString * value = nil;
		
		if ( [obj1 isKindOfClass:[NSNumber class]] )
		{
			key = [(NSNumber *)obj1 stringValue];
		}
		else if ( [obj1 isKindOfClass:[NSString class]] )
		{
			key = (NSString *)obj1;
		}
		else
		{
			continue;
		}
		
		if ( [obj2 isKindOfClass:[NSNumber class]] )
		{
			value = [(NSNumber *)obj2 stringValue];
		}
		else if ( [obj1 isKindOfClass:[NSString class]] )
		{
			value = (NSString *)obj2;
		}
		else
		{
			continue;
		}
		
		NSString * urlEncoding = encoding ? [value URLEncoding] : value;
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, urlEncoding]];
	}
	
	return [pairs componentsJoinedByString:@"&"];
}

+ (NSString *)queryStringFromKeyValues:(id)first, ...
{
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	
	va_list args;
	va_start( args, first );
	
	for ( ;; )
	{
		NSObject<NSCopying> * key = [dict count] ? va_arg( args, NSObject * ) : first;
		if ( nil == key )
			break;
		
		NSObject * value = va_arg( args, NSObject * );
		if ( nil == value )
			break;
		
		[dict setObject:value forKey:key];
	}
	va_end( args );
	return [NSString queryStringFromDictionary:dict];
}

- (NSString *)urlByAppendingDict:(NSDictionary *)params
{
    return [self urlByAppendingDict:params encoding:YES];
}

- (NSString *)urlByAppendingDict:(NSDictionary *)params encoding:(BOOL)encoding
{
    NSURL * parsedURL = [NSURL URLWithString:self];
	NSString * queryPrefix = parsedURL.query ? @"&" : @"?";
	NSString * query = [NSString queryStringFromDictionary:params encoding:encoding];
	return [NSString stringWithFormat:@"%@%@%@", self, queryPrefix, query];
}

- (NSString *)urlByAppendingArray:(NSArray *)params
{
    return [self urlByAppendingArray:params encoding:YES];
}

- (NSString *)urlByAppendingArray:(NSArray *)params encoding:(BOOL)encoding
{
    NSURL * parsedURL = [NSURL URLWithString:self];
	NSString * queryPrefix = parsedURL.query ? @"&" : @"?";
	NSString * query = [NSString queryStringFromArray:params encoding:encoding];
	return [NSString stringWithFormat:@"%@%@%@", self, queryPrefix, query];
}

- (NSString *)urlByAppendingKeyValues:(id)first, ...
{
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	
	va_list args;
	va_start( args, first );
	
	for ( ;; )
	{
		NSObject<NSCopying> * key = [dict count] ? va_arg( args, NSObject * ) : first;
		if ( nil == key )
			break;
		
		NSObject * value = va_arg( args, NSObject * );
		if ( nil == value )
			break;
        
		[dict setObject:value forKey:key];
	}
    va_end( args );
	return [self urlByAppendingDict:dict];
}

+(NSString*)fromInt:(NSInteger)item
{
    return [NSString stringWithFormat:@"%d",(int)item];
}
+(NSString*)fromFoalt:(CGFloat)item
{
    return [NSString stringWithFormat:@"%f",item];
}
+(NSString*)fromBool:(BOOL)item
{
    return [NSString stringWithFormat:@"%d",item];
}
+(NSString*)fromString:(NSString*)item
{
    if (item == nil) {
        return @"";
    }
    return [NSString stringWithFormat:@"%@",item];
}

- (BOOL)empty
{
    if (self == nil || [self length] == 0) {
        return YES;
    }
	return NO;
}

- (BOOL)notEmpty
{
	return (self !=nil && [self length]) > 0 ? YES : NO;
}

- (BOOL)eq:(NSString *)other
{
	return [self isEqualToString:other];
}

- (BOOL)equal:(NSString *)other
{
	return [self isEqualToString:other];
}

- (BOOL)is:(NSString *)other
{
	return [self isEqualToString:other];
}

- (BOOL)isNot:(NSString *)other
{
	return NO == [self isEqualToString:other];
}

- (BOOL)isValueOf:(NSArray *)array
{
	return [self isValueOf:array caseInsens:NO];
}

- (BOOL)isValueOf:(NSArray *)array caseInsens:(BOOL)caseInsens
{
	NSStringCompareOptions option = caseInsens ? NSCaseInsensitiveSearch : 0;
	
	for ( NSObject * obj in array )
	{
		if ( NO == [obj isKindOfClass:[NSString class]] )
			continue;
		
		if ( [(NSString *)obj compare:self options:option] )
			return YES;
	}
	
	return NO;
}


- (NSString *)URLEncoding
{
	NSString * result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault,
																			(CFStringRef)self,
																			NULL,
																			(CFStringRef)@"!*'();:@&=+$,/?%#[]",
																			kCFStringEncodingUTF8 ));
	return result ;
}

- (NSString *)URLDecoding
{
	NSMutableString * string = [NSMutableString stringWithString:self];
    [string replaceOccurrencesOfString:@"+"
							withString:@" "
							   options:NSLiteralSearch
								 range:NSMakeRange(0, [string length])];
    return [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)toMD5
{
    return [self md5];
}
- (NSString *)toMD5_Small
{
    return [self md5_Small];
}

- (NSString *)toSHA1
{
    const char *	cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *		data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t			digest[CC_SHA1_DIGEST_LENGTH] = { 0 };
	CC_LONG			digestLength = (CC_LONG)data.length;
    
    CC_SHA1( data.bytes, digestLength, digest );
    
    NSMutableString * output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
	
    for ( int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++ )
	{
		[output appendFormat:@"%02x", digest[i]];
	}
    
    return output;
}

- (NSString *)trim
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)unwrap
{
	if ( self.length >= 2 )
	{
		if ( [self hasPrefix:@"\""] && [self hasSuffix:@"\""] )
		{
			return [self substringWithRange:NSMakeRange(1, self.length - 2)];
		}
        
		if ( [self hasPrefix:@"'"] && [self hasSuffix:@"'"] )
		{
			return [self substringWithRange:NSMakeRange(1, self.length - 2)];
		}
	}
    
	return self;
}

- (NSString *)repeat:(NSUInteger)count
{
	if ( 0 == count )
		return @"";
	
	NSMutableString * text = [NSMutableString string];
	
	for ( NSUInteger i = 0; i < count; ++i )
	{
		[text appendString:self];
	}
	
	return text;
}

- (NSString *)normalize
{
	return [self stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
}

- (BOOL)isUserName
{
	NSString *		regex = @"(^[A-Za-z0-9]{3,20}$)";
	NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	
	return [pred evaluateWithObject:self];
}

- (BOOL)isChineseUserName
{
	NSString *		regex = @"(^[A-Za-z0-9\u4e00-\u9fa5]{3,20}$)";
	NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	
	return [pred evaluateWithObject:self];
}

- (BOOL)isPassword
{
	NSString *		regex = @"(^[A-Za-z0-9]{6,20}$)";
	NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	
	return [pred evaluateWithObject:self];
}

- (BOOL)isEmail
{
	NSString *		regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	
	return [pred evaluateWithObject:self];
}

- (BOOL)isUrl
{
    NSString *		regex = @"http(s)?:\\/\\/([\\w-]+\\.)+[\\w-]+(\\/[\\w- .\\/?%&=]*)?";
	NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	
	return [pred evaluateWithObject:self];
}

- (BOOL)isIPAddress
{
	NSArray *			components = [self componentsSeparatedByString:@"."];
	NSCharacterSet *	invalidCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
	
	if ( [components count] == 4 )
	{
		NSString *part1 = [components objectAtIndex:0];
		NSString *part2 = [components objectAtIndex:1];
		NSString *part3 = [components objectAtIndex:2];
		NSString *part4 = [components objectAtIndex:3];
		
		if ( [part1 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
            [part2 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
            [part3 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
            [part4 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound )
		{
			if ( [part1 intValue] < 255 &&
                [part2 intValue] < 255 &&
                [part3 intValue] < 255 &&
                [part4 intValue] < 255 )
			{
				return YES;
			}
		}
	}
	
	return NO;
}

- (BOOL)isNormal
{
	NSString *		regex = @"([^%&',;=!~?$]+)";
	NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
	return [pred evaluateWithObject:self];
}

- (BOOL)isTelephone
{
    NSString * MOBILE = @"^((0?(13[0-9])|(14[7])|(15[^4,\\D])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9])|(92[0-9])|(98[0-9]))\\d{8})$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    return  [regextestmobile evaluateWithObject:self];
}

- (BOOL)isMobilephone
{
    NSString * MOBILE = @"^[1-9]\\d{10}$";
    NSPredicate *regextestMobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    return  [regextestMobile evaluateWithObject:self];
}

-(BOOL)isNumber
{
    NSString* regex = @"^([1-9][0-9]*)$";
    
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    
    return  [pred evaluateWithObject:self];
}

- (BOOL)isFloat
{
    NSString* regex = @"^[0-9]+(.[0-9]{2})?$";
    
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    
    return  [pred evaluateWithObject:self];
}

- (BOOL)isChineseName
{
	NSString *		regex = @"(^[\u4e00-\u9fa5]{2,16}$)";
	NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	
	return [pred evaluateWithObject:self];
}

- (NSString *)substringFromIndex:(NSUInteger)from untilString:(NSString *)string
{
	return [self substringFromIndex:from untilString:string endOffset:NULL];
}

- (NSString *)substringFromIndex:(NSUInteger)from untilString:(NSString *)string endOffset:(NSUInteger *)endOffset
{
	if ( 0 == self.length )
		return nil;
	
	if ( from >= self.length )
		return nil;
	
	NSRange range = NSMakeRange( from, self.length - from );
	NSRange range2 = [self rangeOfString:string options:NSCaseInsensitiveSearch range:range];
	
	if ( NSNotFound == range2.location )
	{
		if ( endOffset )
		{
			*endOffset = range.location + range.length;
		}
		
		return [self substringWithRange:range];
	}
	else
	{
		if ( endOffset )
		{
			*endOffset = range2.location + range2.length;
		}
		
		return [self substringWithRange:NSMakeRange(from, range2.location - from)];
	}
}

- (NSString *)substringFromIndex:(NSUInteger)from untilCharset:(NSCharacterSet *)charset
{
	return [self substringFromIndex:from untilCharset:charset endOffset:NULL];
}

- (NSString *)substringFromIndex:(NSUInteger)from untilCharset:(NSCharacterSet *)charset endOffset:(NSUInteger *)endOffset
{
	if ( 0 == self.length )
		return nil;
	
	if ( from >= self.length )
		return nil;
    
	NSRange range = NSMakeRange( from, self.length - from );
	NSRange range2 = [self rangeOfCharacterFromSet:charset options:NSCaseInsensitiveSearch range:range];
    
	if ( NSNotFound == range2.location )
	{
		if ( endOffset )
		{
			*endOffset = range.location + range.length;
		}
		
		return [self substringWithRange:range];
	}
	else
	{
		if ( endOffset )
		{
			*endOffset = range2.location + range2.length;
		}
        
		return [self substringWithRange:NSMakeRange(from, range2.location - from)];
	}
}

- (NSUInteger)countFromIndex:(NSUInteger)from inCharset:(NSCharacterSet *)charset
{
	if ( 0 == self.length )
		return 0;
	
	if ( from >= self.length )
		return 0;
	
	NSCharacterSet * reversedCharset = [charset invertedSet];
    
	NSRange range = NSMakeRange( from, self.length - from );
	NSRange range2 = [self rangeOfCharacterFromSet:reversedCharset options:NSCaseInsensitiveSearch range:range];
    
	if ( NSNotFound == range2.location )
	{
		return self.length - from;
	}
	else
	{
		return range2.location - from;
	}
}

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
- (CGSize)sizeWithFont:(UIFont *)font byWidth:(CGFloat)width
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        return [self boundingRectWithSize:CGSizeMake(width, 999999.0f)
                                  options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine
                               attributes:@{NSFontAttributeName:font} context:nil].size;
#else
        return [self sizeWithFont:font
        		constrainedToSize:CGSizeMake(width, 999999.0f)
        			lineBreakMode:UILineBreakModeWordWrap];
#endif
}

- (CGSize)sizeWithFont:(UIFont *)font byHeight:(CGFloat)height
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        return [self boundingRectWithSize:CGSizeMake(999999.0f, height)
                              options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine
                           attributes:@{NSFontAttributeName:font} context:nil].size;
#else
        return [self sizeWithFont:font
                constrainedToSize:CGSizeMake(999999.0f, height)
                    lineBreakMode:UILineBreakModeWordWrap];
#endif
}
- (CGSize)sizeWithFont:(UIFont *)font bySize:(CGSize)size
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        return [self boundingRectWithSize:size
                                  options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine
                               attributes:@{NSFontAttributeName:font} context:nil].size;
#else
        return [self sizeWithFont:font
                constrainedToSize:size
                    lineBreakMode:UILineBreakModeWordWrap];
#endif
}
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

+ (NSString *)fromResource:(NSString *)resName
{
	NSString *	extension = [resName pathExtension];
	NSString *	fullName = [resName substringToIndex:(resName.length - extension.length - 1)];
    
	NSString * path = [[NSBundle mainBundle] pathForResource:fullName ofType:extension];
	return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
}

-(NSString *)replaceUnicode
{
    NSString *tempStr1 = [self stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
   
    NSString* returnStr = [NSPropertyListSerialization propertyListWithData:tempData
                                                                    options:NSPropertyListImmutable
                                                                     format:NULL
                                                                      error:NULL];
    
//    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
//                                                           mutabilityOption:NSPropertyListImmutable
//                                                                     format:NULL
//                                                           errorDescription:NULL];
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}

-(BOOL)toBool
{
    if ([self isEqualToString:@"true"]) {
        return YES;
    }
    if ([self isEqualToString:@"1"]) {
        return YES;
    }
    if ([self isEqualToString:@"yes"]) {
        return YES;
    }
    if ([self isEqualToString:@"YES"]) {
        return YES;
    }
    if ([self isEqualToString:@"TURE"]) {
        return YES;
    }
    if ([self isEqualToString:@"Y"]) {
        return YES;
    }
    return NO;
}

- (BOOL)match:(NSString *)expression
{
	NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:expression
																			options:NSRegularExpressionCaseInsensitive
																			  error:nil];
	if ( nil == regex )
		return NO;
	
	NSUInteger numberOfMatches = [regex numberOfMatchesInString:self
														options:0
														  range:NSMakeRange(0, self.length)];
	if ( 0 == numberOfMatches )
		return NO;
    
	return YES;
}

- (BOOL)matchAnyOf:(NSArray *)array
{
	for ( NSString * str in array )
	{
		if ( NSOrderedSame == [self compare:str options:NSCaseInsensitiveSearch] )
		{
			return YES;
		}
	}
	
	return NO;
}

@end

#pragma mark -

@implementation NSMutableString(DLExtension)

DEF_DYNAMIC(APPEND);
DEF_DYNAMIC(LINE);
DEF_DYNAMIC(REPLACE);

- (NSMutableStringAppendBlock)APPEND
{
	NSMutableStringAppendBlock block = ^ NSMutableString * ( id first, ... )
	{
		va_list args;
		va_start( args, first );
		
		NSString * append = [[NSString alloc] initWithFormat:first arguments:args];
        
		va_end( args );
        
		if ( NO == [self isKindOfClass:[NSMutableString class]] )
		{
			NSMutableString * copy = [self mutableCopy];
			[copy appendString:append];
			
			return copy;
		}
		else
		{
			[self appendString:append];
			
			return self;
		}
	};
	
	return [block copy];
}

- (NSMutableStringAppendBlock)LINE
{
	NSMutableStringAppendBlock block = ^ NSMutableString * ( id first, ... )
	{
		NSString * append = nil;
		
		if ( first )
		{
			va_list args;
			va_start( args, first );
			
			append = [[NSString alloc] initWithFormat:first arguments:args];
            
			va_end( args );
		}
        
		if ( NO == [self isKindOfClass:[NSMutableString class]] )
		{
			NSMutableString * copy = [self mutableCopy];
			
			if ( append )
			{
				[copy appendString:append];
			}
			
			[copy appendString:@"\n"];
			
			return copy;
		}
		else
		{
			if ( append )
			{
				[self appendString:append];
			}
			
			[self appendString:@"\n"];
			
			return self;
		}
        
		return self;
	};
	
	return [block copy];
}

- (NSMutableStringReplaceBlock)REPLACE
{
	NSMutableStringReplaceBlock block = ^ NSMutableString * ( NSString * string1, NSString * string2 )
	{
		[self replaceOccurrencesOfString:string1
							  withString:string2
								 options:NSCaseInsensitiveSearch
								   range:NSMakeRange(0, self.length)];
        
		return self;
	};
	
	return [block copy];
}

@end
