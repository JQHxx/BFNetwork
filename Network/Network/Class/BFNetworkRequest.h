//
//  BFNetworkConfig.h
//  Network
//
//  Created by OFweek01 on 2020/8/19.
//  Copyright © 2020 JQHxx. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BFNetworkRequestType){
    GET,
    POST,
    FORM
};

@interface BFNetworkRequest : NSObject

@property (nonatomic, copy) NSString *serverURL;
@property (nonatomic, copy) NSString *methodName;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) NSDictionary *header;
@property (nonatomic, assign) NSTimeInterval timeout;
@property (nonatomic, assign) BFNetworkRequestType requestType;
@property (nonatomic, assign) BOOL isPostJson;

@end

NS_ASSUME_NONNULL_END
