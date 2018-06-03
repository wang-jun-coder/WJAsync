//
//  WJAsyncManager.m
//  technologySurvey
//
//  Created by SJG on 2018/1/11.
//  Copyright © 2018年 SJG. All rights reserved.
//

#import "WJAsync.h"

@implementation WJAsync

/**
 串行执行给定的异步任务数组, 执行完毕回调 complete
 
 注意:
    1. 任务数组中的单个任务顺序执行, 如其中一个出错, 则立即调用 complete 回调, 报告错误
    2. 任务数组中的单个任务执行完成的标记为调用任务的回调参数(无论成功/失败), 如不调用, 则认为此任务尚未完成
    3. 任务数组中单个任务的回调 block 有两个参数 分别为 error 和 data, 若 error 存在则认为此任务执行失败
 
 @param tasks  任务数组
 @param complete 回调
 */
+ (void)series:(NSArray<WJAsyncTask> *)tasks complete:(WJAsyncSeriesComplete)complete {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSMutableArray *results = [NSMutableArray array];
        __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        __block BOOL continueRun = true;
        WJAsyncTaskCallback asyncCallback = ^(NSError *error, id data) {
            continueRun = error ? false : true;
            dispatch_semaphore_signal(sem);
            if(error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (complete) complete(error, results);
                });
                return ;
            }
            data = data ? data : [NSNull null];
            [results addObject:data];
        };
        for (NSInteger i=0; i<tasks.count; i++) {
            WJAsyncTask t = tasks[i];
            t(asyncCallback);
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            if (!continueRun) break;
        }
        if (complete && continueRun) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, results);
            });
        }
    });
}

/**
 流式串行执行给定的任务数组
 
 @param tasks 异步任务数组
 @param complete 执行完毕回调函数
 */
+ (void)waterfall:(NSArray <WJAsyncWaterfallTask>*)tasks complete:(WJAsyncWaterfallComplete)complete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        __block id waterfallData = nil;
        __block BOOL continueRun = true;
        WJAsyncTaskCallback asyncCallback = ^(NSError *error, id data) {
            continueRun = error ? false : true;
            if(error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (complete) complete(error, waterfallData);
                });
                return ;
            }
            waterfallData = data;
            dispatch_semaphore_signal(sem);
        };
        for (NSInteger i=0; i<tasks.count; i++) {
            WJAsyncWaterfallTask t = tasks[i];
            t(waterfallData, asyncCallback);
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            if (!continueRun) break;
        }
        if (complete && continueRun) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, waterfallData);
            });
        }
    });
}

/**
 并行执行异步任务数组, 执行完毕回调 complete
 
 @param tasks  任务数据
 @param complete 执行完毕回调
 */
+ (void)parallel:(NSArray <WJAsyncTask>*)tasks complete:(WJAsyncParallelComplete)complete {
    __block NSMutableArray *results = [NSMutableArray arrayWithCapacity:tasks.count];
    __block NSMutableArray * errors = [NSMutableArray arrayWithCapacity:tasks.count];
    dispatch_group_t group = dispatch_group_create();
    for (NSInteger i=0; i<tasks.count; i++) {
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [results addObject:[NSNull null]];
            [errors addObject:[NSNull null]];
            WJAsyncTaskCallback asyncCallback = ^(NSError *err, id data) {
                if(data)[results replaceObjectAtIndex:i withObject:data];
                if(err)[errors replaceObjectAtIndex:i withObject:err];
                dispatch_group_leave(group);
            };
            dispatch_group_enter(group);
            tasks[i](asyncCallback);
        });
    }
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(complete) complete(errors, results);
        });
    });
}
@end
