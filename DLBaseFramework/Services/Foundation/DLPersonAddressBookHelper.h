//
//  DLPersonAddressBookHelper.h
//  Catalyzer
//
//  Created by luyz on 2017/3/26.
//  Copyright © 2017年 luyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLSingleton.h"
#import "DLModel.h"

typedef void (^DLPersonAddressBookHelperBlock)(NSInteger tag,id data);

@interface DLPersonAddressBookHelper : NSObject

AS_SINGLETON(DLPersonAddressBookHelper);

AS_BLOCK(DLPersonAddressBookHelperBlock, block);

-(void)initData;

-(void)getAllData;

-(void)checkStatusAndGetData:(void (^)(BOOL status))block;

@end
