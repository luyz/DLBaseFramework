//
//  DLStyleRender.m
//  DLBase
//
//  Created by lucaslu on 15/12/16.
//  Copyright © 2015年 lucaslu. All rights reserved.
//

#import "DLStyleRender.h"
#import "DLStyle.h"
#import <QuartzCore/QuartzCore.h>
#import "DLModel.h"


@interface DLWeakLink : NSObject

@property (nonatomic, weak) NSObject* weakObject;

@end

@implementation DLWeakLink

@synthesize weakObject;

@end

@interface DLStyleRender ()

AS_MODEL_STRONG(CADisplayLink, displayLink);

AS_MODEL_STRONG(NSMutableArray, needRenderStyle);

@end

@implementation DLStyleRender

DEF_SINGLETON(DLStyleRender);

DEF_MODEL(displayLink);
DEF_MODEL(needRenderStyle);

-(void)dealloc
{
    [self.displayLink invalidate];
}


- (instancetype) init
{
    self = [super init];
    if (!self) {
        return self;
    }
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplay:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    self.needRenderStyle = [NSMutableArray new];
    
    return self;
}

- (void) handleDisplay:(CADisplayLink*)link
{
    if (self.needRenderStyle.count == 0) {
        return;
    }
    for (DLWeakLink* link in self.needRenderStyle) {
        DLStyle* style = (DLStyle*)link.weakObject;
        [style decorateView:style.linkedView];
    }
    [self.needRenderStyle removeAllObjects];
}

- (BOOL) hasStyle:(DLStyle*)style
{
    for (DLWeakLink* link  in self.needRenderStyle) {
        if (link.weakObject == style) {
            return YES;
        }
    }
    return NO;
}

- (void) addNeedRenderStyle:(DLStyle*)style
{
    if ([self hasStyle:style]) {
        return;
    }
    DLWeakLink* link = [DLWeakLink new];
    link.weakObject = style;
    [self.needRenderStyle addObject:link];
}


@end
