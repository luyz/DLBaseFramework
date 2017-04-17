//
//  DLUserDefaults.m
//  TickTock
//
//  Created by 卢迎志 on 14-12-5.
//  Copyright (c) 2014年 卢迎志. All rights reserved.
//

#import "DLUserDefaults.h"
#import "DLSystemInfo.h"

@implementation DLUserDefaults

DEF_SINGLETON(DLUserDefaults);

- (NSString*)getAppKey:(NSString*)key
{
    return [NSString stringWithFormat:@"%@_%@",[DLSystemInfo projectName],key];
}

- (BOOL)hasObjectForKey:(id)key
{
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:[self getAppKey:key]];
    return value ? YES : NO;
}

- (id)objectForKey:(NSString *)key
{
    if ( nil == key )
    {
        return nil;
    }
    
    if ([self hasObjectForKey:key]) {
        id value = [[NSUserDefaults standardUserDefaults] objectForKey:[self getAppKey:key]];
        return value;
    }
    
    return nil;
}

- (void)setObject:(id)value forKey:(NSString *)key
{
    if ( nil == key || nil == value )
        return;
    
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:[self getAppKey:key]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeObjectForKey:(NSString *)key
{
    if ( nil == key )
        return;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self getAppKey:key]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeAllObjects
{
    [NSUserDefaults resetStandardUserDefaults];
}

- (id)objectForKeyedSubscript:(id)key
{
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id)key
{
    if ( obj )
    {
        [self setObject:obj forKey:key];
    }
    else
    {
        [self removeObjectForKey:key];
    }
}

@end
