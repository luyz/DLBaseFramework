//
//  DLStyle.m
//  DLBase
//
//  Created by lucaslu on 15/12/16.
//  Copyright © 2015年 lucaslu. All rights reserved.
//

#import "DLStyle.h"
#import "NSArray+DLExtension.h"
#import "DLStyleRender.h"

@implementation DLStyle
DEF_ZERO_STYLE;

DEF_MODEL(childStyle);

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.childStyle = [NSMutableArray new];
    }
    return self;
}
- (void) copyAttributesWithStyle:(id)style
{
    if (![style isKindOfClass:[DLStyle class]]) {
        return ;
    }
    return;
}

- (void) decorateView:(UIView *)aView
{
    
}

- (id) copyWithZone:(NSZone *)zone
{
    DLStyle* style = [[[self class] allocWithZone:zone] init];
    return style;
}

- (void) installOnView:(UIView *)aView
{
    _linkedView = aView;
}

- (void) unInstallOnView:(UIView *)aView
{
    _linkedView = nil;
}

- (void) setAttributeNeedRefresh
{
    if (self.linkedView) {
        [[DLStyleRender sharedInstance] addNeedRenderStyle:self];
    }
}


- (void) addChildStyle:(DLStyle*)style
{
    if (style) {
        [self.childStyle addObject:style.copy];
    }
}

- (void) removeChildStyle:(DLStyle*)style
{
    [self.childStyle removeObject:style.copy];
}

- (void) removeAllChildStyle
{
    [self.childStyle removeAllObjects];
}

@end
