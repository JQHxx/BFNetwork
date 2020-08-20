//
//  BFNetwork.m
//  Network
//
//  Created by midland on 2019/10/31.
//  Copyright © 2019 JQHxx. All rights reserved.
//

#import "BFNetwork.h"

NSString *const ResponseErrorKey = @"com.alamofire.serialization.response.error.response";
#define Kboundary  @"----WebKitFormBoundaryjh7urS5p3OcvqXAT"
#define KNewLine [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]

@interface BFNetwork ()

@end

@implementation BFNetwork

static BFNetwork *_instance = nil;

+(instancetype)shareNetwork {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [[self alloc]init];
        }
    });
    return _instance;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

-(id)copyWithZone:(NSZone *)zone {
    return _instance;
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    return _instance;
}

- (NSURLSessionTask *)sendRequest:(BFNetworkRequest *)request
                          success:(nullable BFSuccessBlock)success
                          failure:(nullable BFFailureBlock)failure {
    switch (request.requestType) {
        case GET: {
            return [self getRequest:request success:success failure:failure];
        }
        case POST: {
            return [self postRequest:request success:success failure:failure];
        }
        case FORM: {
            return [self uploadRequest:request success:success failure:failure];
        }
    }
}

#pragma mark - Private methods
- (NSURLSessionTask *)getRequest:(BFNetworkRequest *)request
                         success:(BFSuccessBlock)success
                         failure:(BFFailureBlock)failure {
    NSString *serverURL = [NSString stringWithFormat:@"%@%@", request.serverURL, request.methodName];
    NSString *urlString = [NSString string];
    if (request.params) {
        //参数拼接url
        NSString *paramStr = [self dealWithParam:request.params];
        urlString = [serverURL stringByAppendingString:paramStr];
    } else {
        urlString = serverURL;
    }
    // 对URL中的中文进行转码
    NSString *pathStr = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableURLRequest *mRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:pathStr]];
    [request.header enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSString *_Nonnull obj, BOOL * _Nonnull stop) {
        [mRequest setValue:obj forHTTPHeaderField:key];
    }];
    mRequest.timeoutInterval = request.timeout;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:mRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                //利用iOS自带原生JSON解析data数据 保存为Dictionary
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                success(dict);
                
            } else {
                
                NSHTTPURLResponse *httpResponse = error.userInfo[ResponseErrorKey];
                if (httpResponse.statusCode != 0) {
                    NSString *ResponseStr = [self showErrorInfoWithStatusCode:httpResponse.statusCode];
                    failure(ResponseStr);
                    
                } else {
                    NSString *ErrorCode = [self showErrorInfoWithStatusCode:error.code];
                    failure(ErrorCode);
                }
            }
        });
    }];
    
    [task resume];
    return task;
}

- (NSURLSessionTask *)postRequest:(BFNetworkRequest *)request
                          success:(BFSuccessBlock)success
                          failure:(BFFailureBlock)failure {
    NSString *serverURL = [NSString stringWithFormat:@"%@%@", request.serverURL, request.methodName];
    NSMutableURLRequest *mRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverURL]];
    [mRequest setHTTPMethod:@"POST"];
    
    //把字典中的参数进行拼接
    NSString *body = [self dealWithParam:request.params];
    NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [request.header enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSString *_Nonnull obj, BOOL * _Nonnull stop) {
        [mRequest setValue:obj forHTTPHeaderField:key];
    }];
    if (request.isPostJson) {
        [mRequest setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request.params options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        bodyData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    //设置本次请求的数据请求格式
    //[mRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    // 设置本次请求请求体的长度(因为服务器会根据你这个设定的长度去解析你的请求体中的参数内容)
    [mRequest setValue:[NSString stringWithFormat:@"%ld", bodyData.length] forHTTPHeaderField:@"Content-Length"];
    //设置请求体
    [mRequest setHTTPBody:bodyData];
    //设置请求最长时间
    mRequest.timeoutInterval = request.timeout;
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:mRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data) {
            //利用iOS自带原生JSON解析data数据 保存为Dictionary
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            success(dict);
            
        } else {
            NSHTTPURLResponse *httpResponse = error.userInfo[ResponseErrorKey];
            if (httpResponse.statusCode != 0) {
                NSString *ResponseStr = [self showErrorInfoWithStatusCode:httpResponse.statusCode];
                failure(ResponseStr);
                
            } else {
                NSString *ErrorCode = [self showErrorInfoWithStatusCode:error.code];
                failure(ErrorCode);
            }
        }
    }];
    [task resume];
    return task;
}

- (NSURLSessionUploadTask *)uploadRequest:(BFNetworkRequest *)request
                                  success:(BFSuccessBlock)success
                                  failure:(BFFailureBlock)failure {
    
    NSString *serverURL = [NSString stringWithFormat:@"%@%@", request.serverURL, request.methodName];
    // 01 确定请求路径
    NSURL *url = [NSURL URLWithString:serverURL];
    // 02 创建"可变"请求对象
    NSMutableURLRequest *mRequest  =[NSMutableURLRequest requestWithURL:url];
    // 03 修改请求方法"POST"
    mRequest.HTTPMethod = @"POST";
    //'设置请求头:告诉服务器这是一个文件上传请求,请准备接受我的数据
    //Content-Type:multipart/form-data; boundary=分隔符
    NSString *headerStr = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",Kboundary];
    [mRequest setValue:headerStr forHTTPHeaderField:@"Content-Type"];
    [request.header enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSString *_Nonnull obj, BOOL * _Nonnull stop) {
        [mRequest setValue:obj forHTTPHeaderField:key];
    }];
    //04 拼接参数-(设置请求体)
    //'按照固定的格式来拼接'
    NSData *data = [self getBodyData: request];
    //!!!! request.HTTPBody = data;
    
    //05 创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    //06 根据会话对象创建uploadTask请求
    /*
     第一个参数:请求对象
     第二个参数:要传递的是本应该设置为请求体的参数
     第三个参数:completionHandler 当上传完成的时候调用
     data:响应体
     response:响应头信息
     */
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:mRequest fromData:data completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 08 解析服务器返回的数据
        if (data) {
            //利用iOS自带原生JSON解析data数据 保存为Dictionary
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            success(dict);
            
        } else {
            NSHTTPURLResponse *httpResponse = error.userInfo[ResponseErrorKey];
            if (httpResponse.statusCode != 0) {
                NSString *ResponseStr = [self showErrorInfoWithStatusCode:httpResponse.statusCode];
                failure(ResponseStr);
                
            } else {
                NSString *ErrorCode = [self showErrorInfoWithStatusCode:error.code];
                failure(ErrorCode);
            }
        }
    }];
    
    //07 发送请求
    [uploadTask resume];
    return uploadTask;
    
}

-(NSData *)getBodyData:(BFNetworkRequest *)request {
    NSMutableData *data = [NSMutableData data];
    
    [request.params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[NSData class]]) {
            //01 文件参数
            /*
             --分隔符
             Content-Disposition: form-data; name="file"; filename="Snip20160716_103.png"
             Content-Type: image/png
             空行
             文件数据
             */
            
            [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [data appendData:KNewLine];
            //file 文件参数 参数名 == username
            //filename 文件上传到服务器之后以什么名称来保存
            NSString *fileName = [NSString stringWithFormat:@"%@.png", key];
            NSString *content = [NSString stringWithFormat:@"Content-Disposition: form-data; name=%@; filename=%@",key, fileName];
            [data appendData:[content dataUsingEncoding:NSUTF8StringEncoding]];
            [data appendData:KNewLine];
            
            //Content-Type 文件的数据类型
            [data appendData:[@"Content-Type: image/png" dataUsingEncoding:NSUTF8StringEncoding]];
            [data appendData:KNewLine];
            [data appendData:KNewLine];
            
            NSData *imageData = obj;
            [data appendData:imageData];
            [data appendData:KNewLine];
        } else {
            //02 非文件参数
            /*
             --分隔符
             Content-Disposition: form-data; name="username"
             空行
             xiaomage
             */
            [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [data appendData:KNewLine];
            //username 参数名称
            NSString *keyContent = [NSString stringWithFormat:@"Content-Disposition: form-data; name=%@",key];
            NSString *content = [NSString stringWithFormat:@"%@",obj];
            [data appendData:[keyContent dataUsingEncoding:NSUTF8StringEncoding]];
            [data appendData:KNewLine];
            [data appendData:KNewLine];
            [data appendData:[content dataUsingEncoding:NSUTF8StringEncoding]];
            [data appendData:KNewLine];
        }
        
    }];
    
    //03 结尾标识
    /*
     --分隔符--
     */
    [data appendData:[[NSString stringWithFormat:@"--%@--",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //拼接
    return data;
}

#pragma mark -- 拼接参数
- (NSString *)dealWithParam: (NSDictionary *)param {
    NSArray *allkeys = [param allKeys];
    NSMutableString *result = [NSMutableString string];
    
    for (NSString *key in allkeys) {
        NSString *string = [NSString stringWithFormat:@"%@=%@&", key, param[key]];
        [result appendString:string];
    }
    return result;
}

#pragma mark
- (NSString *)showErrorInfoWithStatusCode:(NSInteger)statusCode {
    
    NSString *message = nil;
    switch (statusCode) {
        case 401: {
            
        }
            break;
            
        case 500: {
            message = @"服务器异常！";
        }
            break;
            
        case -1001: {
            message = @"网络请求超时，请稍后重试！";
        }
            break;
            
        case -1002: {
            message = @"不支持的URL！";
        }
            break;
            
        case -1003: {
            message = @"未能找到指定的服务器！";
        }
            break;
            
        case -1004: {
            message = @"服务器连接失败！";
        }
            break;
            
        case -1005: {
            message = @"连接丢失，请稍后重试！";
        }
            break;
            
        case -1009: {
            message = @"互联网连接似乎是离线！";
        }
            break;
            
        case -1012: {
            message = @"操作无法完成！";
        }
            break;
            
        default: {
            message = @"网络请求发生未知错误，请稍后再试！";
        }
            break;
    }
    return message;
}

@end
