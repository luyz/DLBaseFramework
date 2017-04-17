//
//  DLTextStyle.m
//  DLBase
//
//  Created by lucaslu on 15/12/17.
//  Copyright © 2015年 lucaslu. All rights reserved.
//

#import "DLTextStyle.h"

@implementation DLTextStyle
DEF_ZERO_STYLE;

- (void) setTextColor:(UIColor *)textColor
{
    if (_textColor != textColor) {
        _textColor = textColor;
        [self setAttributeNeedRefresh];
    }
}

- (void) setFont:(UIFont *)font
{
    if (_font != font) {
        _font = font;
        [self setAttributeNeedRefresh];
    }
}

- (void) decorateView:(UIView *)aView
{
    [super decorateView:aView];
    
    if ([aView respondsToSelector:@selector(setFont:)]) {
        [aView performSelector:@selector(setFont:) withObject:self.font];
    }
    
    if ([aView respondsToSelector:@selector(setTextColor:)]) {
        [aView performSelector:@selector(setTextColor:) withObject:self.textColor];
    }
}
- (id) copyWithZone:(NSZone *)zone
{
    DLTextStyle* style = [super copyWithZone:zone];
    style.font = self.font;
    style.textColor = self.textColor;
    return style;
}

@end
