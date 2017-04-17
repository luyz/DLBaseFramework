//
//  UIView+Style.m
//  DLBase
//
//  Created by lucaslu on 15/12/17.
//  Copyright © 2015年 lucaslu. All rights reserved.
//

#import "UIView+Style.h"
#import "DLStyle.h"
#import <objc/runtime.h>
#import "DLStyleCSS.h"

static void* kDZStyleKey = &kDZStyleKey;
static void* kDZStyleClass = &kDZStyleClass;

@implementation UIView (Style)

- (void) registreStyleClass:(Class)cla
{
    objc_setAssociatedObject(self, kDZStyleClass, cla, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (Class) __styleClass
{
    if ([self isKindOfClass:[UIButton class]]) {
        return [DLButtonStyle class];
    } else if ([self isKindOfClass:[UILabel class]])
    {
        return [DLLabelStyle class];
    } else if ([self isKindOfClass:[UISegmentedControl class]])
    {
        return [DLSegementStyle class];
    }
    else if ([self isKindOfClass:[UIPageControl class]]) {
        return [DLPageControlStyle class];
    }
    else if ([self isKindOfClass:[DLTextFieldStyle class]]) {
        return [DLTextFieldStyle class];
    }
    else {
        Class cla = objc_getAssociatedObject(self, kDZStyleClass);
        if (cla) {
            return cla;
        }
        return [DLViewStyle class];
    }
}

- (DLStyle*) __zeroStyle
{
    DLStyle* style;
    Class cla = [self __styleClass];
    if ([(NSObject*)cla respondsToSelector:@selector(zeroStyle)]) {
        style = [[[self __styleClass] zeroStyle ] copy];
    }
    return style;
}
- (void) __storeStyle:(DLStyle*)copyedStyle
{
    objc_setAssociatedObject(self, kDZStyleKey, copyedStyle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [copyedStyle installOnView:self];
    [copyedStyle decorateView:self];
    
}
- (void) setStyle:(DLStyle *)style
{
    id oldStyle = objc_getAssociatedObject(self, kDZStyleKey);
    if (oldStyle) {
        [oldStyle unInstallOnView:self];
    }
    DLStyle* copyedStyle = [self  __zeroStyle] ;
    [copyedStyle copyAttributesWithStyle:style];
    [self __storeStyle:copyedStyle];
    
}

- (DLStyle*) style
{
    DLStyle* style =  objc_getAssociatedObject(self, kDZStyleKey);
    if (!style) {
        Class cla = [self __styleClass];
        if ([(NSObject*)cla respondsToSelector:@selector(zeroStyle)]) {
            style = [[[self __styleClass] zeroStyle ] copy];
            [self __storeStyle:style];
        }
    }
    return style;
}

@end
