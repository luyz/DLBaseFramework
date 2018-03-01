//
//  DLAleatViewHelper.h
//  TestBaseProject
//
//  Created by luyz on 2016/10/30.
//  Copyright © 2016年 luyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DLAleatViewHelper : NSObject

+(void)showAleat:(NSString*)content withController:(UIViewController*)controller;

+(void)showAleat:(NSString*)content withController:(UIViewController*)controller withBlock:(void (^)(NSInteger tag))block;

+(void)showAleat:(NSString*)title withContent:(NSString*)content withController:(UIViewController*)controller withBlock:(void (^)(NSInteger tag))block;

+(void)showAleat:(NSString*)title withContent:(NSString*)content withItems:(NSArray*)array withController:(UIViewController*)controller withBlock:(void (^)(NSInteger tag))block;

+(void)showAleat:(NSString*)content withItems:(NSArray*)array withController:(UIViewController*)controller withBlock:(void (^)(NSInteger tag))block;

+(void)showAleatSheet:(NSString*)title withItems:(NSArray*)array withController:(UIViewController*)controller withBlock:(void (^)(NSInteger tag))block;

@end
