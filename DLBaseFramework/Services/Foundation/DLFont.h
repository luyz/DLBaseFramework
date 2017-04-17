//
//  DLFont.h
//  DLBaseFramework
//
//  Created by luyz on 2016/12/11.
//  Copyright © 2016年 luyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *字体相关宏
 */
#define DLPingFangFONT_REGULAR(F) [UIFont fontWithName:@"PingFangSC-Regular" size:F]
#define DLPingFangFONT_LIGHT(F) [UIFont fontWithName:@"PingFangSC-Light" size:F]
#define DLPingFangFONT_LIGHT_BOLD(F) [UIFont fontWithName:@"PingFangSC-Light-Bold" size:F]
#define DLFontSize(Size) [UIFont systemFontOfSize:Size]
#define DLFontBoldSize(size) [UIFont boldSystemFontOfSize:Size]

@interface DLFont : NSObject


@end
