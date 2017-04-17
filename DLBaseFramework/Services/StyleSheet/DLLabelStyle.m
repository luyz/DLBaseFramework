//
//  DLLabelStyle.m
//  DLBase
//
//  Created by lucaslu on 15/12/17.
//  Copyright © 2015年 lucaslu. All rights reserved.
//

#import "DLLabelStyle.h"

@implementation DLLabelStyle
DEF_ZERO_STYLE;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setTextStyle:(DLTextStyle*)[DLTextStyle zeroStyle]];
        self.clipsToBounds = YES;
    }
    return self;
}
- (void) setTextAlignment:(NSTextAlignment)textAlignment
{
    _textAlignment = textAlignment;
    [self setAttributeNeedRefresh];
}

- (void) setHighlightedTextColor:(UIColor *)highlightedTextColor
{
    if (_highlightedTextColor != highlightedTextColor) {
        _highlightedTextColor = highlightedTextColor;
        [self setAttributeNeedRefresh];
    }
}

- (void) setShadowColor:(UIColor *)shadowColor
{
    if (_shadowColor != shadowColor) {
        _shadowColor= shadowColor;
        [self setAttributeNeedRefresh];
    }
}

- (void) setShadowOffset:(CGSize)shadowOffset
{
    _shadowOffset = shadowOffset;
    [self setAttributeNeedRefresh];
}

- (void) setAdjustsFontSizeToFitWidth:(CGFloat)adjustsFontSizeToFitWidth
{
    _adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth;
    [self setAttributeNeedRefresh];
}
- (void) setTextStyle:(DLTextStyle *)textStyle
{
    [_textStyle unInstallOnView:self.linkedView];
    _textStyle = [textStyle copy];
    [_textStyle installOnView:self.linkedView];
    [_textStyle setAttributeNeedRefresh];
}

- (void) decorateView:(UIView *)aView
{
    [super decorateView:aView];
    if (![aView isKindOfClass:[UILabel class]]) {
        return;
    }
    UILabel* label = (UILabel*)aView;
    label.textAlignment = self.textAlignment;
    [self.textStyle decorateView:aView];
    label.highlightedTextColor = _highlightedTextColor;
    label.shadowColor = _shadowColor;
    label.shadowOffset = _shadowOffset;
    label.adjustsFontSizeToFitWidth = _adjustsFontSizeToFitWidth;
    
}

- (void) copyAttributesWithStyle:(id)style
{
    DLBeginCopyAttribute(DLLabelStyle);
    DLStyleCopyAttribute(highlightedTextColor)
    DLStyleCopyAttribute(shadowColor)
    DLStyleCopyAttribute(shadowOffset)
    DLStyleCopyAttribute(adjustsFontSizeToFitWidth)
    DLStyleCopyAttribute(textAlignment)
    if ([origin respondsToSelector:@selector(textStyle)]) {
        self.textStyle = [origin.textStyle copy];
    }
    DLFinishCopyAttribute
}

- (id) copyWithZone:(NSZone *)zone
{
    DLLabelStyle* style = [super copyWithZone:zone];
    style.textAlignment = self.textAlignment;
    style.textStyle = [[self textStyle] copy];
    style.highlightedTextColor = _highlightedTextColor;
    style.shadowColor = _shadowColor;
    style.shadowOffset= _shadowOffset;
    style.adjustsFontSizeToFitWidth = _adjustsFontSizeToFitWidth;
    return style;
}


@end
