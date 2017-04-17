//
//  DLKeychain.m
//  TickTock
//
//  Created by 卢迎志 on 14-11-28.
//  Copyright (c) 2014年 卢迎志. All rights reserved.
//

#import "DLKeychain.h"
#import "NSString+DLExtension.h"
#import "DLSystemInfo.h"

@implementation DLKeychain

DEF_SINGLETON(DLKeychain);

DEF_MODEL(defaultDomain);

+ (void)setDefaultDomain:(NSString *)domain
{
	[[DLKeychain sharedInstance] setDefaultDomain:domain];
}

+ (NSString *)readValueForKey:(NSString *)key
{
	return [[DLKeychain sharedInstance] readValueForKey:key andDomain:nil];
}

+ (NSString *)readValueForKey:(NSString *)key andDomain:(NSString *)domain
{
	return [[DLKeychain sharedInstance] readValueForKey:key andDomain:domain];
}

- (NSString *)readValueForKey:(NSString *)key andDomain:(NSString *)domain
{
	if ( nil == key )
		return nil;
    
	if ( NSNotFound != [key rangeOfString:@"/" options:NSCaseInsensitiveSearch].location )
	{
		NSUInteger	offset = 0;
		
		domain	= [key substringFromIndex:0 untilCharset:[NSCharacterSet characterSetWithCharactersInString:@"/"] endOffset:&offset];
		key		= [key substringFromIndex:offset];
	}
    
	if ( nil == domain )
	{
		domain = self.defaultDomain;
		if ( nil == domain )
		{
			domain = DEFAULT_DOMAIN;
		}
	}
	
	domain = [domain stringByAppendingString:[DLSystemInfo appIdentifier]];
    
	NSArray * keys = [[NSArray alloc] initWithObjects: (__bridge NSString *) kSecClass, kSecAttrAccount, kSecAttrService, nil];
	NSArray * objects = [[NSArray alloc] initWithObjects: (__bridge NSString *) kSecClassGenericPassword, key, domain, nil] ;
	
	NSMutableDictionary * query = [[NSMutableDictionary alloc] initWithObjects: objects forKeys: keys] ;
	NSMutableDictionary * attributeQuery = [query mutableCopy];
	[attributeQuery setObject: (id) kCFBooleanTrue forKey:(__bridge id) kSecReturnAttributes];
	
	CFTypeRef attributeResult = NULL;
    CFDictionaryRef cfquery = (CFDictionaryRef)CFBridgingRetain(attributeQuery);
	OSStatus status = SecItemCopyMatching( cfquery, &attributeResult );
	CFRelease(cfquery);
    
	if ( noErr != status )
		return nil;
	
	NSMutableDictionary * passwordQuery = [query mutableCopy];
	[passwordQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
	
	CFTypeRef resultData = nil;
    CFDictionaryRef psquery = (CFDictionaryRef)CFBridgingRetain(passwordQuery);
	status = SecItemCopyMatching(psquery,&resultData );
    CFRelease(psquery);
	
	if ( noErr != status )
		return nil;
	
	if ( nil == resultData )
		return nil;
	
	NSString * password = CFBridgingRelease(resultData);
    
	return password ;
}

+ (void)writeValue:(NSString *)value forKey:(NSString *)key
{
	[[DLKeychain sharedInstance] writeValue:value forKey:key andDomain:nil];
}

+ (void)writeValue:(NSString *)value forKey:(NSString *)key andDomain:(NSString *)domain
{
	[[DLKeychain sharedInstance] writeValue:value forKey:key andDomain:domain];
}

- (void)writeValue:(NSString *)value forKey:(NSString *)key andDomain:(NSString *)domain
{
	if ( nil == key )
		return;
	
	if ( NSNotFound != [key rangeOfString:@"/" options:NSCaseInsensitiveSearch].location )
	{
		NSUInteger	offset = 0;
		
		domain	= [key substringFromIndex:0 untilCharset:[NSCharacterSet characterSetWithCharactersInString:@"/"] endOffset:&offset];
		key		= [key substringFromIndex:offset];
	}
    
	if ( nil == value )
	{
		value = @"";
	}
    
	if ( nil == domain )
	{
		domain = self.defaultDomain;
		if ( nil == domain )
		{
			domain = DEFAULT_DOMAIN;
		}
	}
	
	domain = [domain stringByAppendingString:[DLSystemInfo appIdentifier]];
    
	OSStatus status = 0;
	
	NSString * password = [DLKeychain readValueForKey:key andDomain:domain];
	if ( password )
	{
		if ( [password isEqualToString:value] )
			return;
        
		NSArray * keys = [[NSArray alloc] initWithObjects:(__bridge NSString *)kSecClass, kSecAttrService, kSecAttrLabel, kSecAttrAccount, nil] ;
		NSArray * objects = [[NSArray alloc] initWithObjects:(__bridge NSString *)kSecClassGenericPassword, domain, domain, key, nil] ;
		
		NSDictionary * query = [[NSDictionary alloc] initWithObjects:objects forKeys:keys] ;
		status = SecItemUpdate( (__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)[NSDictionary dictionaryWithObject:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge NSString *)kSecValueData] );
	}
	else
	{
		NSArray * keys = [[NSArray alloc] initWithObjects:(__bridge NSString *)kSecClass, kSecAttrService, kSecAttrLabel, kSecAttrAccount, kSecValueData, nil];
		NSArray * objects = [[NSArray alloc] initWithObjects:(__bridge NSString *)kSecClassGenericPassword, domain, domain, key, [value dataUsingEncoding:NSUTF8StringEncoding], nil];
		
		NSDictionary * query = [[NSDictionary alloc] initWithObjects: objects forKeys: keys];
		status = SecItemAdd( (__bridge CFDictionaryRef)query, NULL);
	}
	
	if ( noErr != status )
	{
		//ERROR( @"writeValue, status = %d", status );
	}
}

+ (void)deleteValueForKey:(NSString *)key
{
	[[DLKeychain sharedInstance] deleteValueForKey:key andDomain:nil];
}

+ (void)deleteValueForKey:(NSString *)key andDomain:(NSString *)domain
{
	[[DLKeychain sharedInstance] deleteValueForKey:key andDomain:domain];
}

- (void)deleteValueForKey:(NSString *)key andDomain:(NSString *)domain
{
	if ( nil == key )
		return;
	
	if ( NSNotFound != [key rangeOfString:@"/" options:NSCaseInsensitiveSearch].location )
	{
		NSUInteger	offset = 0;
		
		domain	= [key substringFromIndex:0 untilCharset:[NSCharacterSet characterSetWithCharactersInString:@"/"] endOffset:&offset];
		key		= [key substringFromIndex:offset];
	}
    
	if ( nil == domain )
	{
		domain = self.defaultDomain;
		if ( nil == domain )
		{
			domain = DEFAULT_DOMAIN;
		}
	}
	
	domain = [domain stringByAppendingString:[DLSystemInfo appIdentifier]];
    
	NSArray * keys = [[NSArray alloc] initWithObjects:(__bridge NSString *)kSecClass, kSecAttrAccount, kSecAttrService, kSecReturnAttributes, nil] ;
	NSArray * objects = [[NSArray alloc] initWithObjects:(__bridge NSString *)kSecClassGenericPassword, key, domain, kCFBooleanTrue, nil] ;
	
	NSDictionary * query = [[NSDictionary alloc] initWithObjects:objects forKeys:keys] ;
	SecItemDelete( (__bridge CFDictionaryRef)query );
}

- (BOOL)hasObjectForKey:(id)key
{
	id obj = [self readValueForKey:key andDomain:nil];
	return obj ? YES : NO;
}

- (id)objectForKey:(id)key
{
	return [self readValueForKey:key andDomain:nil];
}

- (void)setObject:(id)object forKey:(id)key
{
	[self writeValue:object forKey:key andDomain:nil];
}

- (void)removeObjectForKey:(id)key
{
	[self deleteValueForKey:key andDomain:nil];
}

- (void)removeAllObjects
{
	// TODO:
}

- (id)objectForKeyedSubscript:(id)key
{
	if ( nil == key || NO == [key isKindOfClass:[NSString class]] )
		return nil;
    
	return [self readValueForKey:key andDomain:nil];
}

- (void)setObject:(id)obj forKeyedSubscript:(id)key
{
	if ( nil == key || NO == [key isKindOfClass:[NSString class]] )
		return;
	
	if ( nil == obj )
	{
		[self deleteValueForKey:key andDomain:nil];
	}
	else
	{
		[self writeValue:obj forKey:key andDomain:nil];
	}
}

@end
