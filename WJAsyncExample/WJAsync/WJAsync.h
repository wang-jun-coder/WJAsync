//
//  WJAsyncManager.h
//  technologySurvey
//
//  Created by SJG on 2018/1/11.
//  Copyright © 2018年 SJG. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WJAsyncTaskCallback)(NSError *error, id data);

typedef void(^WJAsyncTask)(WJAsyncTaskCallback callback);
typedef void(^WJAsyncWaterfallTask)(id data, WJAsyncTaskCallback callback);

typedef void(^WJAsyncSeriesComplete)(NSError *error, NSArray *results);
typedef void(^WJAsyncWaterfallComplete)(NSError *error, id data);
typedef void(^WJAsyncParallelComplete)(NSArray *errors, NSArray *results);

@interface WJAsync : NSObject




/**
 串行执行给定的异步任务数组, 执行完毕回调 complete

 @param tasks  任务数组
 @param complete 执行完成回调
 
 注意: 中途任务失败串行任务停止
 */
+ (void)series:(NSArray <WJAsyncTask>*)tasks complete:(WJAsyncSeriesComplete)complete;


/**
 流式串行执行给定的任务数组

 @param tasks 异步任务数组
 @param complete 执行完毕回调函数
 */
+ (void)waterfall:(NSArray <WJAsyncWaterfallTask>*)tasks complete:(WJAsyncWaterfallComplete)complete;


/**
 并行执行异步任务数组, 执行完毕回调 complete

 @param tasks  任务数据
 @param complete 执行完毕回调
 
 注意: 中途任务失败串行任务不会停止
 */
+ (void)parallel:(NSArray <WJAsyncTask>*)tasks complete:(WJAsyncParallelComplete)complete;


@end
