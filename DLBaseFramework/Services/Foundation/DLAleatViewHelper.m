//
//  DLAleatViewHelper.m
//  TestBaseProject
//
//  Created by luyz on 2016/10/30.
//  Copyright © 2016年 luyz. All rights reserved.
//

#import "DLAleatViewHelper.h"
#import "NSString+DLExtension.h"

@implementation DLAleatViewHelper


+(void)showAleat:(NSString*)content withController:(UIViewController*)controller
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:content preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:archiveAction];
    
    [controller presentViewController:alertController animated:YES completion:nil];
}

+(void)showAleat:(NSString*)content withController:(UIViewController*)controller withBlock:(void (^)(NSInteger tag))block
{
    [DLAleatViewHelper showAleat:content withItems:[NSArray arrayWithObjects:@"确定", nil] withController:controller withBlock:block];
}

+(void)showAleat:(NSString*)title withContent:(NSString*)content withController:(UIViewController*)controller withBlock:(void (^)(NSInteger tag))block
{
    [DLAleatViewHelper showAleat:title withContent:content withItems:[NSArray arrayWithObjects:@"取消",@"确定", nil] withController:controller withBlock:block];
}

+(void)showAleat:(NSString*)title
     withContent:(NSString*)content
       withItems:(NSArray*)array
  withController:(UIViewController*)controller
       withBlock:(void (^)(NSInteger tag))block
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
    
    for (int i=0; i<[array count]; i++) {
        NSString* tempStr = [array objectAtIndex:i];
        if ([tempStr notEmpty]) {
            UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:tempStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (block != nil) {
                    block(i);
                }
            }];
            [alertController addAction:archiveAction];
        }
    }
    
    [controller presentViewController:alertController animated:YES completion:nil];
}

+(void)showAleat:(NSString*)content withItems:(NSArray*)array withController:(UIViewController*)controller withBlock:(void (^)(NSInteger tag))block
{
    [DLAleatViewHelper showAleat:nil withContent:content withItems:array withController:controller withBlock:block];
}

+(void)showAleatSheet:(NSString*)title withItems:(NSArray*)array withController:(UIViewController*)controller withBlock:(void (^)(NSInteger tag))block
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (int i=0; i<[array count]; i++) {
        NSString* tempStr = [array objectAtIndex:i];
        if ([tempStr notEmpty]) {
            UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:tempStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (block != nil) {
                    block(i);
                }
            }];
            [alertController addAction:archiveAction];
        }
    }
    
    [controller presentViewController:alertController animated:YES completion:nil];
}

@end
