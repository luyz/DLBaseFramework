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
            [self addRefreshWithBlock:block withShowFooter:YES];
        }else if (self.myCollectionView!=nil){
            [self addRefreshWithBlock:block withShowFooter:YES];
        }else if (self.myScrollView!=nil){
            [self addRefreshWithBlock:block withShowFooter:YES];
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
            [self addRefreshWithBlock:block withShowFooter:NO];
        }else if (self.myCollectionView!=nil){
            [self addRefreshWithBlock:block withShowFooter:NO];
        }else if (self.myScrollView!=nil){
            [self addRefreshWithBlock:block withShowFooter:NO];
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

-(void)addRefreshWithBlock:(TDLRefreshBlock)block withShowFooter:(BOOL)show
{
    
    MJRefreshHeader* tempHeader = nil;
    MJRefreshFooter* tempFooter = nil;
    
    tempHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        if (self.isRefresh || self.isFooter) {
            return ;
        }
        self.isRefresh = YES;
        
        [self getData:block];
    }];
    tempFooter = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (self.isRefresh || self.isFooter) {
            return ;
        }
        
        self.isFooter = YES;
        
        [self getData:block];
    }];
    tempFooter.hidden = !show;
    
    if (self.myTableView!=nil) {
        self.myTableView.mj_footer = tempFooter;
        self.myTableView.mj_header = tempHeader;
    }else if (self.myCollectionView!=nil){
        self.myCollectionView.mj_footer = tempFooter;
        self.myCollectionView.mj_header = tempHeader;
    }else if (self.myScrollView!=nil){
        self.myScrollView.mj_footer = tempFooter;
        self.myScrollView.mj_header = tempHeader;
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
            if (show) {
                [self.myTableView.mj_footer endRefreshing];
            }else{
                [self.myTableView.mj_footer endRefreshingWithNoMoreData];
            }
        }else if (self.myCollectionView) {
            if (show) {
                [self.myCollectionView.mj_footer endRefreshing];
            }else{
                [self.myCollectionView.mj_footer endRefreshingWithNoMoreData];
            }
        }else if (self.myScrollView) {
            if (show) {
                [self.myScrollView.mj_footer endRefreshing];
            }else{
                [self.myScrollView.mj_footer endRefreshingWithNoMoreData];
            }
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
            [self.myTableView.mj_header beginRefreshing];
        }else if (self.myCollectionView) {
            [self.myCollectionView.mj_header beginRefreshing];
        }else if (self.myScrollView) {
            [self.myScrollView.mj_header beginRefreshing];
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
            [self.myTableView.mj_header beginRefreshing];
        }else if (self.myCollectionView) {
            [self.myCollectionView.mj_header beginRefreshing];
        }else if (self.myScrollView) {
            [self.myScrollView.mj_header beginRefreshing];
        }
    }
}

- (void)triggerScrolling
{
    if (self.myType == ERefreshAndFooter) {
        if (self.myTableView) {
            [self.myTableView.mj_footer beginRefreshing];
        }else if (self.myCollectionView) {
            [self.myCollectionView.mj_footer beginRefreshing];
        }else if (self.myScrollView) {
            [self.myScrollView.mj_footer beginRefreshing];
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
            [self.myTableView.mj_header endRefreshing];
        }else if (self.myCollectionView) {
            [self.myCollectionView.mj_header endRefreshing];
        }else if (self.myScrollView) {
            [self.myScrollView.mj_header endRefreshing];
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
            [self.myTableView.mj_header endRefreshing];
        }else if (self.myCollectionView) {
            [self.myCollectionView.mj_header endRefreshing];
        }else if (self.myScrollView) {
            [self.myScrollView.mj_header endRefreshing];
        }
    }
}

- (void)stopScrolling
{
    if (self.myType == ERefreshAndFooter) {
        if (self.myTableView) {
            [self.myTableView.mj_footer endRefreshing];
        }else if (self.myCollectionView) {
            [self.myCollectionView.mj_footer endRefreshing];
        }else if (self.myScrollView) {
            [self.myScrollView.mj_footer endRefreshing];
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
