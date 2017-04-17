//
//  DLSwitchStyle.m
//  DLBase
//
//  Created by lucaslu on 15/12/17.
//  Copyright © 2015年 lucaslu. All rights reserved.
//

#import "DLSwitchStyle.h"

@implementation DLSwitchStyle

DEF_ZERO_STYLE;


- (void) setTintColor:(UIColor *)tintColor
{
    if (_tintColor != tintColor) {
        _tintColor = tintColor;
        [self setAttributeNeedRefresh];
    }
}

- (void) setThumbTintColor:(UIColor *)thumbTintColor
{
    if (_thumbTintColor != thumbTintColor) {
        _thumbTintColor = thumbTintColor;
        [self setAttributeNeedRefresh];
    }
}

- (void) setOnTintColor:(UIColor *)onTintColor
{
    if (_onTintColor != onTintColor) {
        _onTintColor = onTintColor;
        [self setAttributeNeedRefresh];
    }
}

- (void) decorateView:(UIView *)aView
{
    [super decorateView:aView];
    if (![aView isKindOfClass:[UISwitch class]]) {
        return;
    }
    UISwitch* sw = (UISwitch*)aView;
    sw.onTintColor = self.onTintColor;
    sw.tintColor = self.tintColor;
    sw.thumbTintColor = self.thumbTintColor;
}
- (void) copyAttributesWithStyle:(id)style
{
    DLBeginCopyAttribute(DLSwitchStyle);
    DLStyleCopyAttribute(tintColor);
    DLStyleCopyAttribute(onTintColor);
    DLStyleCopyAttribute(thumbTintColor);
    DLFinishCopyAttribute;
}

- (id) copyWithZone:(NSZone *)zone
{
    DLSwitchStyle* style = [super copyWithZone:zone];
    style.tintColor = self.tintColor;
    style.thumbTintColor = self.thumbTintColor;
    style.onTintColor = self.onTintColor;
    return style;
}

@end
