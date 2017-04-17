//
//  DLHttpHelper.m
//  TickTock
//
//  Created by 卢迎志 on 14-12-5.
//  Copyright (c) 2014年 卢迎志. All rights reserved.
//

#import "DLHttpHelper.h"
#import "NSString+DLExtension.h"
#import "DLHttpFormModel.h"
#import <netdb.h>
#import "SVProgressHUD.h"
#import "DLLog.h"
#import "DLBaseEngine.h"
#import "DLCache.h"

#import "AFNetworking.h"

@interface DLHttpHelper ()

@end

@implementation DLHttpHelper

DEF_SINGLETON(DLHttpHelper);

-(id)init
{
    self = [super init];
    
    if (self) {
        
        self.timeOut = 60;
        
    }
    
    return self;
}

- (void)AFNetworkStatus:(void (^)(DLHttpStatus netState))statusBlock
{
    //1.创建网络监测者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    /*枚举里面四个状态  分别对应 未知 无网络 数据 WiFi
     typedef NS_ENUM(NSInteger, AFNetworkReachabilityStatus) {
     AFNetworkReachabilityStatusUnknown          = -1,      未知
     AFNetworkReachabilityStatusNotReachable     = 0,       无网络
     AFNetworkReachabilityStatusReachableViaWWAN = 1,       蜂窝数据网络
     AFNetworkReachabilityStatusReachableViaWiFi = 2,       WiFi
     };
     */
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //这里是监测到网络改变的block  可以写成switch方便
        //在里面可以随便写事件
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            {
                NSLog(@"未知网络状态");
                if (statusBlock!=nil) {
                    statusBlock(DLHttpStatusUnknown);
                }
            }
                break;
            case AFNetworkReachabilityStatusNotReachable:
            {
                NSLog(@"无网络");
                if (statusBlock!=nil) {
                    statusBlock(DLHttpStatusNotReachable);
                }
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                NSLog(@"蜂窝数据网");
                if (statusBlock!=nil) {
                    statusBlock(DLHttpStatusReachableViaWWAN);
                }
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                NSLog(@"WiFi网络");
                if (statusBlock!=nil) {
                    statusBlock(DLHttpStatusReachableViaWiFi);
                }
            }
                break;
            default:
                break;
        }
        
    }] ;
}

+(BOOL)isNetworkReachable
{
    
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    struct sockaddr_in6 zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin6_len = sizeof(zeroAddress);
    zeroAddress.sin6_family = AF_INET6;
#else
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
#endif
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    
    BOOL result = (isReachable && !needsConnection) ? YES : NO;
    
    if (!result) {
        
        [SVProgressHUD dismiss];
        
        [SVProgressHUD showInfoWithStatus:@"启动蜂窝移动数据或Wi-Fi来访问数据"];
    }
    return result;
}

+(void)DownFile:(NSString*)url
       withPath:(NSString*)filePath
   withProgress:(void (^)(CGFloat))downloadProgress
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSString *error))failure
{
    [[DLHttpHelper sharedInstance] DownFile:url
                                   withPath:filePath
                               withProgress:downloadProgress
                                    success:success
                                    failure:failure];
}

-(void)DownFile:(NSString*)url
       withPath:(NSString*)filePath
   withProgress:(void (^)(CGFloat))downloadProgressblock
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSString *error))failure
{
    if (![DLHttpHelper isNetworkReachable]) {
        if (failure!=nil) {
            failure(nil);
        }
        return;
    }
    
    NSURL *tempUrl = [NSURL URLWithString:url];
    
    //3.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:tempUrl];
    
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer setTimeoutInterval:[DLHttpHelper sharedInstance].timeOut];
    
    manager.securityPolicy = [DLHttpHelper handleSecurity:[DLBaseEngine sharedInstance].myCerSet];
    
    NSLog(@"down url:%@",url);
    
    //下载任务
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request
                                                             progress:^(NSProgress * _Nonnull downloadProgress) {
        //打印下下载进度
        CGFloat tempProgress = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
        NSLog(@"progress:.02f",tempProgress);
                                                                 // 回到主队列刷新UI
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     // 设置进度条的百分比
                                                                     if (downloadProgressblock!=nil) {
                                                                         downloadProgressblock(tempProgress);
                                                                     }
                                                                 });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //下载地址
        [DLCache createNewDir:filePath];
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //下载完成调用的方法
        NSLog(@"下载完成：");
        if ([DLCache isFileExists:[filePath path]]) {
            
            NSLog(@"%@",filePath);
            
            if (success!=nil) {
                success([filePath path]);
            }
        }else{
            if (failure!=nil) {
                failure(error.description);
            }
        }
    }];
    
    //开始启动任务
    [task resume];
}

+(void)GetData:(NSString*)url
withParameters:(NSDictionary*)params
       success:(void (^)(id responseObject))success
       failure:(void (^)(NSString *error))failure
{
    [[DLHttpHelper sharedInstance] GetData:url
                               withHeaders:nil
                            withParameters:params
                              withProgress:nil
                                   success:success
                                   failure:failure];
}

+(void)GetData:(NSString*)url
   withHeaders:(NSDictionary*)headers
withParameters:(NSDictionary*)params
       success:(void (^)(id responseObject))success
       failure:(void (^)(NSString *error))failure
{
    [[DLHttpHelper sharedInstance] GetData:url
                               withHeaders:headers
                            withParameters:params
                              withProgress:nil
                                   success:success
                                   failure:failure];
}

+(void)GetData:(NSString *)url
withParameters:(NSDictionary *)params
  withProgress:(void (^)(CGFloat progress))downloadProgress
       success:(void (^)(id responseObject))success
       failure:(void (^)(NSString *error))failure
{
    [[DLHttpHelper sharedInstance] GetData:url
                               withHeaders:nil
                            withParameters:params
                              withProgress:downloadProgress
                                   success:success
                                   failure:failure];
}

-(void)GetData:(NSString*)url
   withHeaders:(NSDictionary*)headers
withParameters:(NSDictionary*)params
  withProgress:(void (^)(CGFloat progress))progress
       success:(void (^)(id responseObject))success
       failure:(void (^)(NSString *error))failure
{
    if (![DLHttpHelper isNetworkReachable]) {
        if (failure!=nil) {
            failure(nil);
        }
        return;
    }
    NSString* tempUrl = @"";
    
    NSRange tempPos = [url rangeOfString:@"?"];
    
    if ([params.allKeys count]>0) {
        for (int i=0; i<[params.allKeys count]; i++) {
            NSString* key = [params.allKeys objectAtIndex:i];
            NSString* value = [params.allValues objectAtIndex:i];
            if ([key notEmpty]) {
                NSString* tempItem = [NSString stringWithFormat:@"%@=%@",key,[value URLEncoding]];
                if (tempItem.length>0) {
                    if (tempUrl.length == 0) {
                        if (tempPos.length>0) {
                            tempUrl = [NSString stringWithFormat:@"&%@",tempItem];
                        }else{
                            tempUrl = [NSString stringWithFormat:@"?%@",tempItem];
                        }
                    }else{
                        tempUrl = [NSString stringWithFormat:@"%@&%@",tempUrl,tempItem];
                    }
                }
            }
        }
    }
    
    tempUrl = [NSString stringWithFormat:@"%@%@",url,tempUrl];
    
    INFO(@"GET URL:%@",tempUrl);
    
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer setTimeoutInterval:[DLHttpHelper sharedInstance].timeOut];
    
    for (int i=0; i<[headers.allKeys count]; i++) {
        NSString* tempKey = [headers.allKeys objectAtIndex:i];
        NSString* tempValue = [headers.allValues objectAtIndex:i];
        if (tempKey!=nil && tempValue!=nil) {
            [manager.requestSerializer setValue:tempValue forHTTPHeaderField:tempKey];
        }
    }
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    manager.securityPolicy = [DLHttpHelper handleSecurity:[DLBaseEngine sharedInstance].myCerSet];
    
    [manager GET:tempUrl
           parameters:nil
             progress:^(NSProgress * _Nonnull downloadProgress) {
//                 INFO(@"downloadProgress:%@:%@:%@",downloadProgress,downloadProgress.completedUnitCount,downloadProgress.totalUnitCount);
                 
                 if (progress!=nil) {
                     progress(1.0*downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
                 }
              }
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  NSString* responseStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                  INFO(@"data: %@",responseStr);
                  if (success!=nil) {
                      success(responseStr);
                  }
              }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  ERROR(@"Error: %@", [error localizedDescription]);
                  if (failure!=nil) {
                      failure([error localizedDescription]);
                  }
              }];
}

+(void)PostData:(NSString*)url
 withParameters:(NSDictionary*)params
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSString *error))failure
{
    [[DLHttpHelper sharedInstance] PostData:url
                                withHeaders:nil
                             withParameters:params
                               withProgress:nil
                                    success:success
                                    failure:failure];
}

+(void)PostData:(NSString*)url
    withHeaders:(NSDictionary*)headers
 withParameters:(NSDictionary*)params
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSString *error))failure
{
    [[DLHttpHelper sharedInstance] PostData:url
                                withHeaders:headers
                             withParameters:params
                               withProgress:nil
                                    success:success
                                    failure:failure];
}

+(void)PostData:(NSString *)url
 withParameters:(NSDictionary *)params
   withProgress:(void (^)(CGFloat progress))downloadProgress
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSString * error))failure
{
    [[DLHttpHelper sharedInstance] PostData:url
                                withHeaders:nil
                             withParameters:params
                               withProgress:downloadProgress
                                    success:success
                                    failure:failure];
}

-(void)PostData:(NSString*)url
    withHeaders:(NSDictionary*)headers
 withParameters:(NSDictionary*)params
   withProgress:(void (^)(CGFloat progress))progress
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSString *error))failure
{
    if (![DLHttpHelper isNetworkReachable]) {
        if (failure!=nil) {
            failure(nil);
        }
        return;
    }
    
    INFO(@"POST URL:%@",url);
    INFO(@"Params:%@",params);
    
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer setTimeoutInterval:[DLHttpHelper sharedInstance].timeOut];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    manager.securityPolicy = [DLHttpHelper handleSecurity:[DLBaseEngine sharedInstance].myCerSet];
    
    for (int i=0; i<[headers.allKeys count]; i++) {
        NSString* tempKey = [headers.allKeys objectAtIndex:i];
        NSString* tempValue = [headers.allValues objectAtIndex:i];
        if (tempKey!=nil && tempValue!=nil) {
            [manager.requestSerializer setValue:tempValue forHTTPHeaderField:tempKey];
        }
    }
    
    [manager POST:url
            parameters:params
              progress:^(NSProgress * _Nonnull downloadProgress) {
//                  INFO(@"downloadProgress:%@:%@:%@",downloadProgress,downloadProgress.completedUnitCount,downloadProgress.totalUnitCount);
                  if (progress!=nil) {
                      progress(1.0*downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
                  }
               }
               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    NSString* responseStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                    INFO(@"data: %@",responseStr);
                    if (success!=nil) {
                        success(responseStr);
                    }
               }
               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    ERROR(@"Error: %@", [error localizedDescription]);
                    if (failure!=nil) {
                        failure([error localizedDescription]);
                    }
               }];
}

+(void)PostFormData:(NSString*)url
     withParameters:(NSDictionary*)params
       withFormData:(NSMutableArray*)formdata
            success:(void (^)(id responseObject))success
            failure:(void (^)(NSString *error))failure
{
    [[DLHttpHelper sharedInstance] PostFormData:url
                                    withHeaders:nil
                                 withParameters:params
                                   withFormData:formdata
                                   withProgress:nil
                                        success:success
                                        failure:failure];
}

+(void)PostFormData:(NSString*)url
        withHeaders:(NSDictionary*)headers
     withParameters:(NSDictionary*)params
       withFormData:(NSMutableArray*)formdata
            success:(void (^)(id responseObject))success
            failure:(void (^)(NSString *error))failure
{
    [[DLHttpHelper sharedInstance] PostFormData:url
                                    withHeaders:headers
                                 withParameters:params
                                   withFormData:formdata
                                   withProgress:nil
                                        success:success
                                        failure:failure];
}

+(void)PostFormData:(NSString *)url
     withParameters:(NSDictionary *)params
       withFormData:(NSMutableArray *)formdata
       withProgress:(void (^)(CGFloat progress))downloadProgress
            success:(void (^)(id responseObject))success
            failure:(void (^)(NSString *error))failure
{
    [[DLHttpHelper sharedInstance] PostFormData:url
                                    withHeaders:nil
                                 withParameters:params
                                   withFormData:formdata
                                   withProgress:downloadProgress
                                        success:success
                                        failure:failure];
}

-(void)PostFormData:(NSString*)url
        withHeaders:(NSDictionary*)headers
     withParameters:(NSDictionary*)params
       withFormData:(NSMutableArray*)formdata
       withProgress:(void (^)(CGFloat progress))progress
            success:(void (^)(id responseObject))success
            failure:(void (^)(NSString *error))failure
{
    if (![DLHttpHelper isNetworkReachable]) {
        if (failure!=nil) {
            failure(nil);
        }
        return;
    }
    INFO(@"POST FORM URL:%@",url);
    INFO(@"Params:%@",params);
    
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer setTimeoutInterval:[DLHttpHelper sharedInstance].timeOut];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    manager.securityPolicy = [DLHttpHelper handleSecurity:[DLBaseEngine sharedInstance].myCerSet];
    
    for (int i=0; i<[headers.allKeys count]; i++) {
        NSString* tempKey = [headers.allKeys objectAtIndex:i];
        NSString* tempValue = [headers.allValues objectAtIndex:i];
        if (tempKey!=nil && tempValue!=nil) {
            [manager.requestSerializer setValue:tempValue forHTTPHeaderField:tempKey];
        }
    }
    
    [manager POST:url
            parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    for (int i=0; i<[formdata count]; i++) {
                        DLHttpFormModel* tempItem = [formdata objectAtIndex:i];
                        if (tempItem!=nil && [tempItem.filekey notEmpty] && tempItem.fileUrl!=nil ) {
                            [formData appendPartWithFileURL:tempItem.fileUrl name:tempItem.filekey error:nil];
                        }
                    }
                }
                progress:^(NSProgress * _Nonnull downloadProgress) {
//                    INFO(@"downloadProgress:%@:%@:%@",downloadProgress,downloadProgress.completedUnitCount,downloadProgress.totalUnitCount);
                    if (progress!=nil) {
                        progress(1.0*downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
                    }
                }
                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                   NSString* responseStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                   INFO(@"data: %@",responseStr);
                   if (success!=nil) {
                       success(responseStr);
                   }
                }
                failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                   ERROR(@"Error: %@", [error localizedDescription]);
                   if (failure!=nil) {
                       failure([error localizedDescription]);
                   }
                }];
}

+(void)PostJsonData:(NSString*)url
     withParameters:(NSDictionary*)params
            success:(void (^)(id responseObject))success
            failure:(void (^)(NSString *error))failure
{
    [[DLHttpHelper sharedInstance] PostJsonData:url
                                    withHeaders:nil
                                 withParameters:params
                                   withProgress:nil
                                        success:success
                                        failure:failure];
}

+(void)PostJsonData:(NSString*)url
        withHeaders:(NSDictionary*)headers
     withParameters:(NSDictionary*)params
            success:(void (^)(id responseObject))success
            failure:(void (^)(NSString *error))failure
{
    [[DLHttpHelper sharedInstance] PostJsonData:url
                                    withHeaders:headers
                                 withParameters:params
                                   withProgress:nil
                                        success:success
                                        failure:failure];
}

+(void)PostJsonData:(NSString *)url
     withParameters:(NSDictionary *)params
       withProgress:(void (^)(CGFloat progress))downloadProgress
            success:(void (^)(id responseObject))success
            failure:(void (^)(NSString *error))failure
{
    [[DLHttpHelper sharedInstance] PostJsonData:url
                                    withHeaders:nil
                                 withParameters:params
                                   withProgress:downloadProgress
                                        success:success
                                        failure:failure];
}

-(void)PostJsonData:(NSString*)url
        withHeaders:(NSDictionary*)headers
 withParameters:(NSDictionary*)params
   withProgress:(void (^)(CGFloat progress))progress
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSString *error))failure
{
    if (![DLHttpHelper isNetworkReachable]) {
        if (failure!=nil) {
            failure(nil);
        }
        return;
    }
    
    INFO(@"POST URL:%@",url);
    INFO(@"Params:%@",params);
    
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer setTimeoutInterval:[DLHttpHelper sharedInstance].timeOut];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    manager.securityPolicy = [DLHttpHelper handleSecurity:[DLBaseEngine sharedInstance].myCerSet];
    
    for (int i=0; i<[headers.allKeys count]; i++) {
        NSString* tempKey = [headers.allKeys objectAtIndex:i];
        NSString* tempValue = [headers.allValues objectAtIndex:i];
        if (tempKey!=nil && tempValue!=nil) {
            [manager.requestSerializer setValue:tempValue forHTTPHeaderField:tempKey];
        }
    }
    
    [manager POST:url
            parameters:params
              progress:^(NSProgress * _Nonnull downloadProgress) {
//                  INFO(@"downloadProgress:%@:%@:%@",downloadProgress,downloadProgress.completedUnitCount,downloadProgress.totalUnitCount);
                  if (progress!=nil) {
                      progress(1.0*downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
                  }
              }
               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                   NSDictionary* responseJsonDic = responseObject;
                   if (success!=nil) {
                       success(responseJsonDic);
                   }
               }
               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                   ERROR(@"Error: %@", [error localizedDescription]);
                   if (failure!=nil) {
                       failure([error localizedDescription]);
                   }
               }];
}

+(AFSecurityPolicy*)handleSecurity:(NSSet*)recSet
{
    if(recSet==nil){
        
        AFSecurityPolicy* policy = [AFSecurityPolicy defaultPolicy];
        policy.allowAllSSL = YES;
        return policy;
    }
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    // 是否允许,NO-- 不允许无效的证书
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = YES;
    // 设置证书
    
    [securityPolicy setPinnedCertificates:recSet];
    
    return securityPolicy;
}

@end
