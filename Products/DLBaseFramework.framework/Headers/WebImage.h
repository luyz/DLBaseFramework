//
//  WebImage.h
//  WebImage
//
//  Created by Florent Vilmart on 2015-03-14.
//  Copyright (c) 2015 Dailymotion. All rights reserved.
//

//! Project version number for WebImage.
FOUNDATION_EXPORT double WebImageVersionNumber;

//! Project version string for WebImage.
FOUNDATION_EXPORT const unsigned char WebImageVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import "PublicHeader.h"

#import "SDWebImageManager.h"
#import "SDImageCache.h"
#import "SDWebImageCompat.h"
#import "SDWebImageDownloaderOperation.h"
#import "SDWebImagePrefetcher.h"
#import "SDWebImageOperation.h"
#import "SDWebImageDownloader.h"

#import "UIImageView+WebCache.h"
#import "UIImageView+HighlightedWebCache.h"

#import "UIButton+WebCache.h"
#import "UIView+WebCacheOperation.h"
#import "UIView+WebCache.h"
#if !TARGET_OS_TV
#import "MKAnnotationView+WebCache.h"
#endif

#import "UIImage+GIF.h"
#import "UIImage+MultiFormat.h"
#import "UIImage+WebP.h"
#import "UIImage+ForceDecode.h"
#import "NSData+ImageContentType.h"
#import "NSImage+WebCache.h"
