//
//  NSDictionary+DLExtension.m
//  TickTock
//
//  Created by 卢迎志 on 14-12-1.
//  Copyright (c) 2014年 卢迎志. All rights reserved.
//

#import "NSDictionary+DLExtension.h"

@implementation NSDictionary(DLExtension)

-(id)hasItemAndBack:(NSString*)key
{
    if ([self objectForKey:key]!=nil) {
        if ([self objectForKey:key] == NULL) {
            return nil;
        }
        if ([[self objectForKey:key] isKindOfClass:[NSNull class]]) {
            return nil;
        }
        return [self objectForKey:key];
    }
    return nil;
}

@end


@implementation NSMutableDictionary(DLExtension)

DEF_FACTORY(NSMutableDictionary);

-(id)hasItemAndBack:(NSString*)key
{
    if ([self objectForKey:key]!=nil) {
        if ([self objectForKey:key] == NULL) {
            return nil;
        }
        if ([[self objectForKey:key] isKindOfClass:[NSNull class]]) {
            return nil;
        }
        return [self objectForKey:key];
    }
    return nil;
}

-(void)sObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (anObject!=nil) {
        [self setObject:anObject forKey:aKey];
    }
}

@end
