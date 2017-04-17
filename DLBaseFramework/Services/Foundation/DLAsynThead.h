//
//  DLAsynThead.h
//  DLBaseFramework
//
//  Created by luyz on 2017/2/12.
//  Copyright © 2017年 luyz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLAsynThead : NSObject

+(void)toAsyn:(void (^)())block;

+(void)toAsynWait:(NSTimeInterval)ti withBlock:(void (^)())block;

@end
