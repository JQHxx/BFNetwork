//
//  BFNetwork.h
//  Network
//
//  Created by midland on 2019/10/31.
//  Copyright © 2019 JQHxx. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SuccessBlock)(id responseObject);
typedef void (^FailureBlock)(NSString *error);


@interface BFNetwork : NSObject

//原生GET网络请求
+ (void)getWithURL:(NSString *)url
            params:(NSDictionary *)params
           success:(SuccessBlock)success
           failure:(FailureBlock)failure;

+ (void)postWithURL:(NSString *)url
             params:(NSDictionary *)params
            success:(SuccessBlock)success
            failure:(FailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
