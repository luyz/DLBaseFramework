//
//  NSData+DLDes.h
//  Traderoute
//
//  Created by 卢迎志 on 15-1-19.
//  Copyright (c) 2015年 卢迎志. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JoDes : NSObject

+ (NSString *) encode:(NSString *)str key:(NSString *)key;
+ (NSString *) decode:(NSString *)str key:(NSString *)key;

@end

@interface NSData(DLDes)

+ (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key;
+ (NSData *)DESDecrypt:(NSData *)data WithKey:(NSString *)key;

@end
