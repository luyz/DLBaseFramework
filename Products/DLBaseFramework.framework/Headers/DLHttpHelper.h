//
//  DLHttpHelper.h
//  TickTock
//
//  Created by 卢迎志 on 14-12-5.
//  Copyright (c) 2014年 卢迎志. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLSingleton.h"
#import "DLModel.h"

typedef NS_ENUM(NSInteger, DLHttpStatus) {
    DLHttpStatusUnknown          = -1,      //未知
    DLHttpStatusNotReachable     = 0,       //无网络
    DLHttpStatusReachableViaWWAN = 1,       //蜂窝数据网络
    DLHttpStatusReachableViaWiFi = 2,       //WiFi
};

typedef NS_ENUM(NSInteger,DLHttpFailStatus) {
    ENotNetwork     = 0,//无网络
    EHttpError      = 1,//http error
    EProtocolError  = 2,//协议error
    EParseError     = 3,//解析error
    ETimerOutError  = 4,//联网超时
};

typedef void (^THttpDownloadProgessBlock)(CGFloat progress);
typedef void (^THttpSuccessBlock)(id responseObject);
typedef void (^THttpFailBlock)(DLHttpFailStatus status,NSString* error);

@interface DLHttpHelper : NSObject

AS_SINGLETON(DLHttpHelper);

AS_INT_ASSIGN(timeOut);

AS_MODEL_STRONG(NSString, baseUrl);

/**
 *  获取网络状态
 *
 *  @return YES or NO
 */
+(BOOL)isNetworkReachable;
/**
 *  下载文件
 *
 *  @param url              url地址
 *  @param filePath         存储路径
 *  @param downloadProgress 下载进度
 *  @param success          成功
 *  @param failure          失败
 */
+(void)DownFile:(NSString*)url
       withPath:(NSString*)filePath
   withProgress:(THttpDownloadProgessBlock)downloadProgress
        success:(THttpSuccessBlock)success
        failure:(THttpFailBlock)failure;
/**
 *  GET 方式请求http
 *
 *  @param url     url地址
 *  @param headers header头信息
 *  @param params  body信息
 *  @param success 成功
 *  @param failure 失败
 */
+(void)GetData:(NSString*)url
   withHeaders:(NSDictionary*)headers
withParameters:(NSDictionary*)params
       success:(THttpSuccessBlock)success
       failure:(THttpFailBlock)failure;
/**
 *  GET 方式请求http
 *
 *  @param url     url地址
 *  @param params  body信息
 *  @param success 成功
 *  @param failure 失败
 */
+(void)GetData:(NSString*)url
withParameters:(NSDictionary*)params
       success:(THttpSuccessBlock)success
       failure:(THttpFailBlock)failure;
/**
 *  GET 方式请求http
 *
 *  @param url     url地址
 *  @param params  body信息
 *  @param downloadProgress 下载进度
 *  @param success 成功
 *  @param failure 失败
 */
+(void)GetData:(NSString*)url
withParameters:(NSDictionary*)params
  withProgress:(THttpDownloadProgessBlock)downloadProgress
       success:(THttpSuccessBlock)success
       failure:(THttpFailBlock)failure;
/**
 *  POST 方式请求http
 *
 *  @param url     url地址
 *  @param params  body信息
 *  @param success 成功
 *  @param failure 失败
 */
+(void)PostData:(NSString*)url
 withParameters:(NSDictionary*)params
        success:(THttpSuccessBlock)success
        failure:(THttpFailBlock)failure;
/**
 *  POST 方式请求http
 *
 *  @param url     url地址
 *  @param headers header头信息
 *  @param params  body信息
 *  @param success 成功
 *  @param failure 失败
 */
+(void)PostData:(NSString*)url
    withHeaders:(NSDictionary*)headers
 withParameters:(NSDictionary*)params
        success:(THttpSuccessBlock)success
        failure:(THttpFailBlock)failure;
/**
 *  POST 方式请求http
 *
 *  @param url     url地址
 *  @param params  body信息
 *  @param downloadProgress 下载进度
 *  @param success 成功
 *  @param failure 失败
 */
+(void)PostData:(NSString*)url
 withParameters:(NSDictionary*)params
   withProgress:(THttpDownloadProgessBlock)downloadProgress
        success:(THttpSuccessBlock)success
        failure:(THttpFailBlock)failure;

/**
 *  POST FORM 方式请求http
 *
 *  @param url     url地址
 *  @param params  body信息
 *  @param formdata form的文件信息
 *  @param success 成功
 *  @param failure 失败
 */
+(void)PostFormData:(NSString*)url
     withParameters:(NSDictionary*)params
       withFormData:(NSMutableArray*)formdata
            success:(THttpSuccessBlock)success
            failure:(THttpFailBlock)failure;

/**
 *  POST FORM 方式请求http
 *
 *  @param url     url地址
 *  @param headers header头信息
 *  @param params  body信息
 *  @param formdata form的文件信息
 *  @param success 成功
 *  @param failure 失败
 */
+(void)PostFormData:(NSString*)url
        withHeaders:(NSDictionary*)headers
     withParameters:(NSDictionary*)params
       withFormData:(NSMutableArray*)formdata
            success:(THttpSuccessBlock)success
            failure:(THttpFailBlock)failure;
/**
 *  POST FORM 方式请求http
 *
 *  @param url     url地址
 *  @param params  body信息
 *  @param formdata form的文件信息
 *  @param downloadProgress 下载进度
 *  @param success 成功
 *  @param failure 失败
 */
+(void)PostFormData:(NSString*)url
     withParameters:(NSDictionary*)params
       withFormData:(NSMutableArray*)formdata
       withProgress:(THttpDownloadProgessBlock)downloadProgress
            success:(THttpSuccessBlock)success
            failure:(THttpFailBlock)failure;
/**
 *  POST JSON 方式请求http
 *
 *  @param url     url地址
 *  @param params  body信息
 *  @param success 成功
 *  @param failure 失败
 */
+(void)PostJsonData:(NSString*)url
     withParameters:(NSDictionary*)params
            success:(THttpSuccessBlock)success
            failure:(THttpFailBlock)failure;

/**
 *  POST JSON 方式请求http
 *
 *  @param url     url地址
 *  @param headers header头信息
 *  @param params  body信息
 *  @param success 成功
 *  @param failure 失败
 */
+(void)PostJsonData:(NSString*)url
        withHeaders:(NSDictionary*)headers
     withParameters:(NSDictionary*)params
            success:(THttpSuccessBlock)success
            failure:(THttpFailBlock)failure;

/**
 *  POST JSON 方式请求http
 *
 *  @param url     url地址
 *  @param params  body信息
 *  @param downloadProgress 下载进度
 *  @param success 成功
 *  @param failure 失败
 */
+(void)PostJsonData:(NSString*)url
     withParameters:(NSDictionary*)params
       withProgress:(THttpDownloadProgessBlock)downloadProgress
            success:(THttpSuccessBlock)success
            failure:(THttpFailBlock)failure;



@end
