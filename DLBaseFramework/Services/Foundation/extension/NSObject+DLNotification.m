//
//  NSObject+DLNotification.m
//  Auction
//
//  Created by 卢迎志 on 14-12-10.
//
//

#import "NSObject+DLNotification.h"
#import "DLLog.h"

#pragma mark -

@implementation NSNotification(DLNotification)

- (BOOL)is:(NSString *)name
{
	return [self.name isEqualToString:name];
}

- (BOOL)isKindOf:(NSString *)prefix
{
	return [self.name hasPrefix:prefix];
}

@end

#pragma mark -

@implementation NSObject(DLNotification)


+ (NSString *)NOTIFICATION
{
	return [self NOTIFICATION_TYPE];
}

+ (NSString *)NOTIFICATION_TYPE
{
	return [NSString stringWithFormat:@"notify.%@.", [self description]];
}

- (void)handleNotification:(NSNotification *)notification
{
}

- (void)observeNotification:(NSString *)notificationName
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:notificationName
												  object:nil];
	
	NSArray * array = [notificationName componentsSeparatedByString:@"."];
	if ( array && array.count > 1 )
	{
		NSString * clazz = (NSString *)[array objectAtIndex:1];
		NSString * name = (NSString *)[array objectAtIndex:2];
		{
			NSString * selectorName;
			SEL selector;
            
			selectorName = [NSString stringWithFormat:@"handleNotification_%@_%@:", clazz, name];
			selector = NSSelectorFromString(selectorName);
			
			if ( [self respondsToSelector:selector] )
			{
				[[NSNotificationCenter defaultCenter] addObserver:self
														 selector:selector
															 name:notificationName
														   object:nil];
				return;
			}
            
			selectorName = [NSString stringWithFormat:@"handleNotification_%@:", clazz];
			selector = NSSelectorFromString(selectorName);
			
			if ( [self respondsToSelector:selector] )
			{
				[[NSNotificationCenter defaultCenter] addObserver:self
														 selector:selector
															 name:notificationName
														   object:nil];
				return;
			}
		}
	}
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleNotification:)
												 name:notificationName
											   object:nil];
}

- (void)unobserveNotification:(NSString *)name
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:name
												  object:nil];
}

- (void)unobserveAllNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (BOOL)postNotification:(NSString *)name
{
	INFO( @"Notification '%@'", [name stringByReplacingOccurrencesOfString:@"notify." withString:@""] );
    
	[[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
	return YES;
}

+ (BOOL)postNotification:(NSString *)name withObject:(NSObject *)object
{
	[[NSNotificationCenter defaultCenter] postNotificationName:name object:object];
	return YES;
}

- (BOOL)postNotification:(NSString *)name
{
	return [[self class] postNotification:name];
}

- (BOOL)postNotification:(NSString *)name withObject:(NSObject *)object
{
	return [[self class] postNotification:name withObject:object];
}

@end
