//
//  DLRefreshHelper.h
//  DLBaseFramework
//
//  Created by luyz on 2017/2/12.
//  Copyright © 2017年 luyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    ERefreshAndFooter = 1,
    ERefreshAndScrollBottom,
    EOnlyRefresh
}TRefreshType;

typedef void (^TDLRefreshBlock)(NSInteger tag);

@interface DLRefreshHelper : NSObject

-(void)initRefreshTableView:(UITableView*)view withType:(TRefreshType)type withBlock:(TDLRefreshBlock)block;

-(void)initRefreshCollectionView:(UICollectionView*)view withType:(TRefreshType)type withBlock:(TDLRefreshBlock)block;

-(void)initRefreshScrollView:(UIScrollView*)view withType:(TRefreshType)type withBlock:(TDLRefreshBlock)block;

-(void)handleData:(BOOL)reachedTheEnd;

- (void)triggerRefresh;
- (void)triggerScrolling;

@end
