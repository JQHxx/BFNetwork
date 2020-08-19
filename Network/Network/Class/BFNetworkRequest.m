//
//  BFNetworkConfig.m
//  Network
//
//  Created by OFweek01 on 2020/8/19.
//  Copyright © 2020 JQHxx. All rights reserved.
//

#import "BFNetworkRequest.h"

@implementation BFNetworkRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.methodName = @"";
        self.timeout = 15.0;
        self.requestType = GET;
    }
    return self;
}

@end
