//
//  ViewController.m
//  WJAsyncExample
//
//  Created by SJG on 2018/6/3.
//  Copyright © 2018年 wangjun. All rights reserved.
//

#import "ViewController.h"
#import "WJAsync.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions
// 异步任务串行执行示例
- (IBAction)seriesClick:(id)sender {
    
    // 1. 构建模拟任务
    WJAsyncTask task0 = ^(WJAsyncTaskCallback callback) {
        NSLog(@"异步任务 task0 开始执行");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"异步任务 task0 执行完毕");
            NSString *result = @"异步任务 task0 执行结果";
            NSError *err = nil;
//            err = [NSError errorWithDomain:@"WJAsync.domain" code:-1 userInfo:@{}];
            return callback(err, result);
        });
    };
    WJAsyncTask task1 = ^(WJAsyncTaskCallback callback) {
        NSLog(@"异步任务 task1 开始执行");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"异步任务 task1 执行完毕");
            NSArray *result = @[@"异步任务 task1 执行结果"];
            NSError *err = nil;
//            err = [NSError errorWithDomain:@"WJAsync.domain" code:-1 userInfo:@{}];
            return callback(err, result);
        });
    };
    WJAsyncTask task2 = ^(WJAsyncTaskCallback callback) {
        NSLog(@"异步任务 task2 开始执行");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"异步任务 task2 执行完毕");
            NSDictionary *result = @{@"task2" : @"异步任务 task1 执行结果"};
            NSError *err = nil;
//            err = [NSError errorWithDomain:@"WJAsync.domain" code:-1 userInfo:@{}];
            return callback(err, result);
        });
    };
    
    // 2. 串行执行任务
    NSArray *tasks = @[task0, task1, task2];
    [WJAsync series:tasks complete:^(NSError *error, NSArray *results) {
        if (error) {
            NSLog(@"series error: %@", error);
        }
        NSLog(@"series: results: %@", results);
    }];
    
}

// 异步任务流式执行示例
- (IBAction)waterfallClick:(id)sender {
    WJAsyncWaterfallTask task0 = ^(id data, WJAsyncTaskCallback callback) {
        NSLog(@"异步任务 task0 开始执行");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"异步任务 task0 执行完毕");
            NSError *err = nil;
//            err = [NSError errorWithDomain:@"WJAsync.domain" code:-1 userInfo:@{}];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            NSString *result = @"异步任务 task0 执行结果";
            [dict setObject:result forKey:@"task0"];
            return callback(err, dict);
        });
    };
    
    WJAsyncWaterfallTask task1 = ^(id data, WJAsyncTaskCallback callback) {
        NSLog(@"异步任务 task1 开始执行");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"异步任务 task1 执行完毕");
            NSError *err = nil;
//            err = [NSError errorWithDomain:@"WJAsync.domain" code:-1 userInfo:@{}];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict addEntriesFromDictionary:data];
            NSString *result = @"异步任务 task1 执行结果";
            [dict setObject:@[result] forKey:@"task1"];
            return callback(err, dict);
        });
    };
    WJAsyncWaterfallTask task2 = ^(id data, WJAsyncTaskCallback callback) {
        NSLog(@"异步任务 task2 开始执行");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"异步任务 task2 执行完毕");
            NSError *err = nil;
//            err = [NSError errorWithDomain:@"WJAsync.domain" code:-1 userInfo:@{}];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict addEntriesFromDictionary:data];
            NSString *result = @"异步任务 task2 执行结果";
            [dict setObject:@{@"task2" : result} forKey:@"task2"];
            return callback(err, dict);
        });
    };
    
    NSArray *tasks = @[task0, task1, task2];
    [WJAsync waterfall:tasks complete:^(NSError *error, id data) {
        if (error) {
            NSLog(@"waterfall error: %@", error);
        }
        NSLog(@"waterfall: data: %@", data);
    }];
}

// 异步任务并行执行示例
- (IBAction)parallelClick:(id)sender {
    // 1. 构建模拟任务
    WJAsyncTask task0 = ^(WJAsyncTaskCallback callback) {
        NSLog(@"异步任务 task0 开始执行");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"异步任务 task0 执行完毕");
            NSString *result = @"异步任务 task0 执行结果";
            NSError *err = nil;
            //            err = [NSError errorWithDomain:@"WJAsync.domain" code:-1 userInfo:@{}];
            return callback(err, result);
        });
    };
    WJAsyncTask task1 = ^(WJAsyncTaskCallback callback) {
        NSLog(@"异步任务 task1 开始执行");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"异步任务 task1 执行完毕");
            NSArray *result = @[@"异步任务 task1 执行结果"];
            NSError *err = nil;
            //            err = [NSError errorWithDomain:@"WJAsync.domain" code:-1 userInfo:@{}];
            return callback(err, result);
        });
    };
    WJAsyncTask task2 = ^(WJAsyncTaskCallback callback) {
        NSLog(@"异步任务 task2 开始执行");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"异步任务 task2 执行完毕");
            NSDictionary *result = @{@"task2" : @"异步任务 task1 执行结果"};
            NSError *err = nil;
            //            err = [NSError errorWithDomain:@"WJAsync.domain" code:-1 userInfo:@{}];
            return callback(err, result);
        });
    };
    // 2. 并发执行
    NSArray *tasks = @[task0, task1, task2];
    [WJAsync parallel:tasks complete:^(NSArray *errors, NSArray *results) {
        NSLog(@"parallel errors: %@", errors);
        NSLog(@"parallel: results: %@", results);
    }];
}


@end
