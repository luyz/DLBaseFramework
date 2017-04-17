//
//  DLTextFieldStyle.m
//  DLBase
//
//  Created by lucaslu on 15/12/17.
//  Copyright © 2015年 lucaslu. All rights reserved.
//

#import "DLTextFieldStyle.h"

@implementation DLTextFieldStyle
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
    if (![aView isKindOfClass:[UITextField class]]) {
        return;
    }
//    UITextField* textField = (UITextField*)aView;
    [self.textStyle decorateView:aView];
    
}

- (void) copyAttributesWithStyle:(id)style
{
    DLBeginCopyAttribute(DLTextFieldStyle);
    if ([origin respondsToSelector:@selector(textStyle)]) {
        self.textStyle = [origin.textStyle copy];
    }
    DLFinishCopyAttribute;
}

- (id) copyWithZone:(NSZone *)zone
{
    DLTextFieldStyle* style = [super copyWithZone:zone];
    style.textStyle = [[self textStyle] copy];
    return style;
}

@end
