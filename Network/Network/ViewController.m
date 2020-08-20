//
//  ViewController.m
//  Network
//
//  Created by midland on 2019/10/31.
//  Copyright © 2019 JQHxx. All rights reserved.
//

#import "ViewController.h"
#import "BFNetwork.h"

//// 基本地址
static NSString *const http_base_server = @"";
//// 文件上传基本地址
static NSString *const http_file_server = @"";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //[self testForm];
    //[self testGet];
    //[self testPost];
    //[self testPostJson];
}

- (void)testGet {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    BFNetworkRequest *request = [[BFNetworkRequest alloc]init];
    request.serverURL = @"http://www.weather.com.cn/data/sk/101010100.html";
    request.methodName = @"";
    request.requestType = GET;
    request.params = dict;
    [[BFNetwork shareNetwork] sendRequest:request success:^(id  _Nonnull responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(NSString * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (void)testPost {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"" forKey:@"account"];
    [dict setValue:@"123456" forKey:@"password"];
    BFNetworkRequest *request = [[BFNetworkRequest alloc]init];
    request.serverURL = http_base_server;
    request.methodName = @"/login/memberlogin";
    request.requestType = POST;
    request.params = dict;
    [[BFNetwork shareNetwork] sendRequest:request success:^(id  _Nonnull responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(NSString * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (void)testPostJson {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"0" forKey:@"isWap"];
    [dict setValue:@"59" forKey:@"roomId"];
    [dict setValue:@"" forKey:@"msgId"];
    [dict setValue:@(20) forKey:@"size"];
    BFNetworkRequest *request = [[BFNetworkRequest alloc]init];
    request.serverURL = http_base_server;
    request.methodName = @"/group/getmoremsg";
    request.requestType = POST;
    request.params = dict;
    request.isPostJson = YES;
    [[BFNetwork shareNetwork] sendRequest:request success:^(id  _Nonnull responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(NSString * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (void)testForm {
    NSData *data = UIImageJPEGRepresentation([UIImage imageNamed:@"live_graphic_del"], 1.0);
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"0" forKey:@"filetype"];
    [dict setValue:data forKey:@"file"];
    [dict setValue:@"msgpictext" forKey:@"module"];
    BFNetworkRequest *request = [[BFNetworkRequest alloc]init];
    request.serverURL = http_file_server;
    request.methodName = @"/file/uploadfile2";
    request.requestType = FORM;
    request.timeout = 60.;
    request.params = dict;
    [[BFNetwork shareNetwork] sendRequest:request success:^(id  _Nonnull responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(NSString * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}


@end
