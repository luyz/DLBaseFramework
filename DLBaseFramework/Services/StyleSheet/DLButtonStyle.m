//
//  DLButtonStyle.m
//  DLBase
//
//  Created by lucaslu on 15/12/17.
//  Copyright © 2015年 lucaslu. All rights reserved.
//

#import "DLButtonStyle.h"

@implementation DLButtonStyle

DEF_ZERO_STYLE;

@synthesize normalStyle = _normalStyle;
@synthesize disabledStyle = _disabledStyle;
@synthesize hightlightedStyle = _hightlightedStyle;

- (instancetype) init
{
    self = [super init];
    if (!self) {
        return self;
    }
    return self;
}

- (DLButtonStateStyle*) normalStyle
{
    if (!_normalStyle) {
        _normalStyle = [[DLButtonStateStyle zeroStyle] copy];
    }
    return _normalStyle;
}

- (DLButtonStateStyle*) disabledStyle
{
    if (!_disabledStyle) {
        _disabledStyle = [[DLButtonStateStyle zeroStyle] copy];
    }
    return _disabledStyle;
}

- (DLButtonStateStyle*) hightlightedStyle
{
    if (!_hightlightedStyle) {
        _hightlightedStyle = [[DLButtonStateStyle zeroStyle] copy];
    }
    return _hightlightedStyle;
}

-(void) setNormalStyle:(DLButtonStateStyle *)normalStyle
{
    if (_normalStyle != normalStyle) {
        _normalStyle = [normalStyle copy];
        _normalStyle.state = UIControlStateNormal;
        [self setAttributeNeedRefresh];
    }
}

- (void) setDisabledStyle:(DLButtonStateStyle *)disabledStyle
{
    if (_disabledStyle != disabledStyle) {
        _disabledStyle = [disabledStyle copy];
        _disabledStyle.state = UIControlStateDisabled;
        [self setAttributeNeedRefresh];
    }
}

- (void) setHightlightedStyle:(DLButtonStateStyle *)hightlightedStyle
{
    if (_hightlightedStyle != hightlightedStyle) {
        _hightlightedStyle = [hightlightedStyle copy];
        _hightlightedStyle.state = UIControlStateHighlighted;
        [self setAttributeNeedRefresh];
    }
}

- (void) copyAttributesWithStyle:(id)style
{
    DLBeginCopyAttribute(DLButtonStyle);
    DLStyleCopyAttribute_Copy(disabledStyle);
    DLStyleCopyAttribute_Copy(normalStyle);
    DLStyleCopyAttribute_Copy(hightlightedStyle);
    DLFinishCopyAttribute;
}

- (void) decorateView:(UIView *)aView
{
    [super decorateView:aView];
    if (![aView isKindOfClass:[UIButton class]]) {
        return;
    }
    [self.disabledStyle decorateView:aView];
    [self.normalStyle decorateView:aView];
    [self.hightlightedStyle decorateView:aView];
}

- (id) copyWithZone:(NSZone *)zone
{
    DLButtonStyle* style = [super copyWithZone:zone];
    style.hightlightedStyle = [self.hightlightedStyle copy];
    style.normalStyle = [self.normalStyle copy];
    style.disabledStyle = [self.disabledStyle copy];
    return style;
}


@end
