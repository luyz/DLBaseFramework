//
//  NSObject+DLTypeConversion.m
//  TickTock
//
//  Created by 卢迎志 on 14-11-28.
//  Copyright (c) 2014年 卢迎志. All rights reserved.
//

#import "NSObject+DLTypeConversion.h"

@implementation NSObject(DLTypeConversion)

-(BOOL)isBlankObject
{
    if (self == NULL) {
        return NO;
    }
    if ([self isKindOfClass:[NSNull class]]) {
        return NO;
    }
    
    return YES;
}

- (NSInteger)asInteger
{
	return [[self asNSNumber] integerValue];
}

- (float)asFloat
{
	return [[self asNSNumber] floatValue];
}

- (BOOL)asBool
{
	return [[self asNSNumber] boolValue];
}

- (NSNumber *)asNSNumber
{
	if ( [self isKindOfClass:[NSNumber class]] )
	{
		return (NSNumber *)self;
	}
	else if ( [self isKindOfClass:[NSString class]] )
	{
		return [NSNumber numberWithFloat:[(NSString *)self floatValue]];
	}
	else if ( [self isKindOfClass:[NSDate class]] )
	{
		return [NSNumber numberWithDouble:[(NSDate *)self timeIntervalSince1970]];
	}
	else if ( [self isKindOfClass:[NSNull class]] )
	{
		return [NSNumber numberWithInteger:0];
	}
    
	return nil;
}

- (NSString *)asNSString
{
	if ( [self isKindOfClass:[NSNull class]] )
		return nil;
    
	if ( [self isKindOfClass:[NSString class]] )
	{
		return (NSString *)self;
	}
	else if ( [self isKindOfClass:[NSData class]] )
	{
		NSData * data = (NSData *)self;
		
		NSString * text = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding] ;
		if ( nil == text )
		{
			text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			if ( nil == text )
			{
				text = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			}
		}
		return text;
	}
	else
	{
		return [NSString stringWithFormat:@"%@", self];
	}
}

- (NSDate *)asNSDate
{
	if ( [self isKindOfClass:[NSDate class]] )
	{
		return (NSDate *)self;
	}
	else if ( [self isKindOfClass:[NSString class]] )
	{
		NSDate * date = nil;
        
		if ( nil == date )
		{
			static NSDateFormatter * formatter = nil;
			
			if ( nil == formatter )
			{
				formatter = [[NSDateFormatter alloc] init];
				[formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss z"];
				[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
			}
			
			date = [formatter dateFromString:(NSString *)self];
		}
        
		if ( nil == date )
		{
			static NSDateFormatter * formatter = nil;
			
			if ( nil == formatter )
			{
				formatter = [[NSDateFormatter alloc] init];
				[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
				[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
			}
            
			date = [formatter dateFromString:(NSString *)self];
		}
        
		if ( nil == date )
		{
			static NSDateFormatter * formatter = nil;
            
			if ( nil == formatter )
			{
				formatter = [[NSDateFormatter alloc] init];
				[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
				[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
			}
			
			date = [formatter dateFromString:(NSString *)self];
		}
        
		if ( nil == date )
		{
			static NSDateFormatter * formatter = nil;
			
			if ( nil == formatter )
			{
				formatter = [[NSDateFormatter alloc] init];
				[formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
				[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
			}
            
			date = [formatter dateFromString:(NSString *)self];
		}
        
		return date;
        
        //		NSTimeZone * local = [NSTimeZone localTimeZone];
        //		return [NSDate dateWithTimeInterval:(3600 + [local secondsFromGMT])
        //								  sinceDate:[dateFormatter dateFromString:text]];
	}
	else
	{
		return [NSDate dateWithTimeIntervalSince1970:[self asNSNumber].doubleValue];
	}
	
	return nil;
}

- (NSData *)asNSData
{
	if ( [self isKindOfClass:[NSString class]] )
	{
		return [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	}
	else if ( [self isKindOfClass:[NSData class]] )
	{
		return (NSData *)self;
	}
    
	return nil;
}

- (NSArray *)asNSArray
{
	if ( [self isKindOfClass:[NSArray class]] )
	{
		return (NSArray *)self;
	}
	else
	{
		return [NSArray arrayWithObject:self];
	}
}

//- (NSArray *)asNSArrayWithClass:(Class)clazz
//{
//	if ( [self isKindOfClass:[NSArray class]] )
//	{
//		NSMutableArray * results = [NSMutableArray array];
//        
//		for ( NSObject * elem in (NSArray *)self )
//		{
//			if ( [elem isKindOfClass:[NSDictionary class]] )
//			{
//				NSObject * obj = [[self class] objectFromDictionary:elem];
//				[results addObject:obj];
//			}
//		}
//		
//		return results;
//	}
//    
//	return nil;
//}

- (NSMutableArray *)asNSMutableArray
{
	if ( [self isKindOfClass:[NSMutableArray class]] )
	{
		return (NSMutableArray *)self;
	}
	
	return nil;
}

- (NSDictionary *)asNSDictionary
{
	if ( [self isKindOfClass:[NSDictionary class]] )
	{
		return (NSDictionary *)self;
	}
    
	return nil;
}

- (NSMutableDictionary *)asNSMutableDictionary
{
	if ( [self isKindOfClass:[NSMutableDictionary class]] )
	{
		return (NSMutableDictionary *)self;
	}
	
	NSDictionary * dict = [self asNSDictionary];
	if ( nil == dict )
		return nil;
    
	return [NSMutableDictionary dictionaryWithDictionary:dict];
}


@end
