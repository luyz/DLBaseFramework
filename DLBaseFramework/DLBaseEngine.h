//
//  DLBaseEngine.h
//  DLBaseFramework
//
//  Created by luyz on 16/6/15.
//  Copyright © 2016年 luyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLSingleton.h"
#import "DLModel.h"

@interface DLBaseEngine : NSObject

AS_SINGLETON(DLBaseEngine);
/**
 *  userkey 用户登录后唯一标示
 */
AS_MODEL_STRONG(NSString, myUserKey);
/**
 *  cerSet 用于https 认证的证书
 */
AS_MODEL_STRONG(NSSet, myCerSet);

-(void)registerEngine;

@end
