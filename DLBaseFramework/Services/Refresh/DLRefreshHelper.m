//
//  DLRefreshHelper.m
//  DLBaseFramework
//
//  Created by luyz on 2017/2/12.
//  Copyright © 2017年 luyz. All rights reserved.
//

#import "DLRefreshHelper.h"
#import "DLModel.h"
#import "DLAsynThead.h"
#import "MJRefresh.h"
#import "SVPullToRefresh.h"

@interface DLRefreshHelper ()

AS_MODEL_STRONG(UITableView, myTableView);
AS_MODEL_STRONG(UICollectionView, myCollectionView);
AS_MODEL_STRONG(UIScrollView, myScrollView);

AS_BOOL(isRefresh);
AS_BOOL(isFooter);

AS_MODEL(TRefreshType, myType);

@end

@implementation DLRefreshHelper

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        
        self.isRefresh = NO;
        self.isFooter = NO;
    }
    
    return self;
}

-(void)initRefreshTableView:(UITableView*)view withType:(TRefreshType)type withBlock:(TDLRefreshBlock)block
{
    self.myTableView = view;
    self.myType = type;
    
    [self addHandlewithBlock:block];
}

-(void)initRefreshCollectionView:(UICollectionView*)view withType:(TRefreshType)type withBlock:(TDLRefreshBlock)block
{
    self.myCollectionView = view;
    self.myType = type;
    
    [self addHandlewithBlock:block];
}

-(void)initRefreshScrollView:(UIScrollView*)view withType:(TRefreshType)type withBlock:(TDLRefreshBlock)block
{
    self.myScrollView = view;
    self.myType = type;
 
    [self addHandlewithBlock:block];
}

-(void)addHandlewithBlock:(TDLRefreshBlock)block
{
    if (self.myType == ERefreshAndFooter) {
        if (self.myTableView!=nil) {
            [self addRefreshAndFooter:self.myTableView withBlock:block withShowFooter:YES];
        }else if (self.myCollectionView!=nil){
            [self addRefreshAndFooter:self.myCollectionView withBlock:block withShowFooter:YES];
        }else if (self.myScrollView!=nil){
            [self addRefreshAndFooter:self.myScrollView withBlock:block withShowFooter:YES];
        }
    }else if (self.myType == ERefreshAndScrollBottom) {
        if (self.myTableView!=nil) {
            [self addRefreshAndScroll:self.myTableView withBlock:block withShowFooter:YES];
        }else if (self.myCollectionView!=nil){
            [self addRefreshAndScroll:self.myCollectionView withBlock:block withShowFooter:YES];
        }else if (self.myScrollView!=nil){
            [self addRefreshAndScroll:self.myScrollView withBlock:block withShowFooter:YES];
        }
    }else if (self.myType == EOnlyRefresh) {
        if (self.myTableView!=nil) {
            [self addRefreshAndFooter:self.myTableView withBlock:block withShowFooter:NO];
        }else if (self.myCollectionView!=nil){
            [self addRefreshAndFooter:self.myCollectionView withBlock:block withShowFooter:NO];
        }else if (self.myScrollView!=nil){
            [self addRefreshAndFooter:self.myScrollView withBlock:block withShowFooter:NO];
        }
    }
}

-(void)addRefreshAndScroll:(id)view withBlock:(TDLRefreshBlock)block withShowFooter:(BOOL)show
{
    [view addPullToRefreshWithActionHandler:^{
       
        if (self.isRefresh || self.isFooter) {
            return ;
        }
        
        self.isRefresh = YES;
        
        [self getData:block];
    }];
    
    if (show) {
        [view addInfiniteScrollingWithActionHandler:^{
            
            if (self.isRefresh || self.isFooter) {
                return ;
            }
            
            self.isFooter = YES;
            
            [self getData:block];
        }];
    }
}

-(void)addRefreshAndFooter:(id)view withBlock:(TDLRefreshBlock)block withShowFooter:(BOOL)show
{
    [view addHeaderWithCallback:^{
        
        if (self.isRefresh || self.isFooter) {
            return ;
        }
        
        self.isRefresh = YES;
        
        [self getData:block];
    }];
    
    if (show) {
        [view addFooterWithCallback:^{
            
            if (self.isRefresh || self.isFooter) {
                return ;
            }
            
            self.isFooter = YES;
            
            [self getData:block];
        }];
    }
}

-(void)getData:(TDLRefreshBlock)block
{
    [DLAsynThead toAsyn:^{
        if (block!=nil) {
            block(self.isRefresh?0:1);
        }
    }];
}

-(void)handleData:(BOOL)reachedTheEnd
{
    if (self.isRefresh) {
        self.isRefresh = NO;
        
        [self stopRefresh];
        
        [self handleScroll:reachedTheEnd];
    }
    
    if (self.isFooter) {
        self.isFooter = NO;
        
        [self stopScrolling];
        
        [self handleScroll:reachedTheEnd];
    }
}

-(void)handleScroll:(BOOL)show
{
    if (self.myType == ERefreshAndFooter) {
        if (self.myTableView) {
            [self.myTableView setFooterHidden:!show];
        }else if (self.myCollectionView) {
            [self.myCollectionView setFooterHidden:!show];
        }else if (self.myScrollView) {
            [self.myScrollView setFooterHidden:!show];
        }
    }else if (self.myType == ERefreshAndScrollBottom) {
        if (self.myTableView) {
            self.myTableView.infiniteScrollingView.enabled = show;
        }else if (self.myCollectionView) {
            self.myCollectionView.infiniteScrollingView.enabled = show;
        }else if (self.myScrollView) {
            self.myScrollView.infiniteScrollingView.enabled = show;
        }
    }
}

- (void)triggerRefresh
{
    if (self.myType == ERefreshAndFooter) {
        if (self.myTableView) {
            [self.myTableView headerBeginRefreshing];
        }else if (self.myCollectionView) {
            [self.myCollectionView headerBeginRefreshing];
        }else if (self.myScrollView) {
            [self.myScrollView headerBeginRefreshing];
        }
    }else if (self.myType == ERefreshAndScrollBottom) {
        if (self.myTableView) {
            [self.myTableView triggerPullToRefresh];
        }else if (self.myCollectionView) {
            [self.myCollectionView triggerPullToRefresh];
        }else if (self.myScrollView) {
            [self.myScrollView triggerPullToRefresh];
        }
    }else if (self.myType == EOnlyRefresh) {
        if (self.myTableView) {
            [self.myTableView headerBeginRefreshing];
        }else if (self.myCollectionView) {
            [self.myCollectionView headerBeginRefreshing];
        }else if (self.myScrollView) {
            [self.myScrollView headerBeginRefreshing];
        }
    }
}

- (void)triggerScrolling
{
    if (self.myType == ERefreshAndFooter) {
        if (self.myTableView) {
            [self.myTableView footerBeginRefreshing];
        }else if (self.myCollectionView) {
            [self.myCollectionView footerBeginRefreshing];
        }else if (self.myScrollView) {
            [self.myScrollView footerBeginRefreshing];
        }
    }else if (self.myType == ERefreshAndScrollBottom) {
        if (self.myTableView) {
            [self.myTableView triggerInfiniteScrolling];
        }else if (self.myCollectionView) {
            [self.myCollectionView triggerInfiniteScrolling];
        }else if (self.myScrollView) {
            [self.myScrollView triggerInfiniteScrolling];
        }
    }
}

- (void)stopRefresh
{
    if (self.myType == ERefreshAndFooter) {
        if (self.myTableView) {
            [self.myTableView headerEndRefreshing];
        }else if (self.myCollectionView) {
            [self.myCollectionView headerEndRefreshing];
        }else if (self.myScrollView) {
            [self.myScrollView headerEndRefreshing];
        }
    }else if (self.myType == ERefreshAndScrollBottom) {
        if (self.myTableView) {
            [self.myTableView.pullToRefreshView stopAnimating];
        }else if (self.myCollectionView) {
            [self.myCollectionView.pullToRefreshView stopAnimating];
        }else if (self.myScrollView) {
            [self.myScrollView.pullToRefreshView stopAnimating];
        }
    }else if (self.myType == EOnlyRefresh) {
        if (self.myTableView) {
            [self.myTableView headerEndRefreshing];
        }else if (self.myCollectionView) {
            [self.myCollectionView headerEndRefreshing];
        }else if (self.myScrollView) {
            [self.myScrollView headerEndRefreshing];
        }
    }
}

- (void)stopScrolling
{
    if (self.myType == ERefreshAndFooter) {
        if (self.myTableView) {
            [self.myTableView footerEndRefreshing];
        }else if (self.myCollectionView) {
            [self.myCollectionView footerEndRefreshing];
        }else if (self.myScrollView) {
            [self.myScrollView footerEndRefreshing];
        }
    }else if (self.myType == ERefreshAndScrollBottom) {
        if (self.myTableView) {
            [self.myTableView.infiniteScrollingView stopAnimating];
        }else if (self.myCollectionView) {
            [self.myCollectionView.infiniteScrollingView stopAnimating];
        }else if (self.myScrollView) {
            [self.myScrollView.infiniteScrollingView stopAnimating];
        }
    }
}

@end
