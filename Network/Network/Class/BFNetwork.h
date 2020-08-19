//
//  BFNetwork.h
//  Network
//
//  Created by midland on 2019/10/31.
//  Copyright © 2019 JQHxx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BFNetworkRequest.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^BFSuccessBlock)(id responseObject);
typedef void (^BFFailureBlock)(NSString *error);

@interface BFNetwork : NSObject

+ (instancetype)shareNetwork;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (NSURLSessionTask *)sendRequest:(BFNetworkRequest *)request
                          success:(nullable BFSuccessBlock)success
                          failure:(nullable BFFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
