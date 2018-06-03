# WJAsync
基于 GCD 和 Block 实现的一款 OC 版异步任务管理器


## series 

`series` 方法用于串行执行一组异步任务, 任务之间没有耦合关系, 若该组任务中有一个执行失败, 则 `series` 方法直接进入回调, 并携带失败信息. 该组任务的执行结果在执行完毕的回调中以数组形式传递, 结果所在数组的索引与任务所在数组的索引一一对应.

使用示例如下: 

```objective-c
    // 1. 构建模拟任务
    WJAsyncTask task0 = ^(WJAsyncTaskCallback callback) {
        NSLog(@"异步任务 task0 开始执行");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"异步任务 task0 执行完毕");
            NSString *result = @"异步任务 task0 执行结果";
            NSError *err = nil;
			//err = [NSError errorWithDomain:@"WJAsync.domain" code:-1 userInfo:@{}];
            return callback(err, result);
        });
    };
    WJAsyncTask task1 = ^(WJAsyncTaskCallback callback) {
        NSLog(@"异步任务 task1 开始执行");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"异步任务 task1 执行完毕");
            NSArray *result = @[@"异步任务 task1 执行结果"];
            NSError *err = nil;
			//err = [NSError errorWithDomain:@"WJAsync.domain" code:-1 userInfo:@{}];
            return callback(err, result);
        });
    };
    WJAsyncTask task2 = ^(WJAsyncTaskCallback callback) {
        NSLog(@"异步任务 task2 开始执行");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"异步任务 task2 执行完毕");
            NSDictionary *result = @{@"task2" : @"异步任务 task1 执行结果"};
            NSError *err = nil;
			//err = [NSError errorWithDomain:@"WJAsync.domain" code:-1 userInfo:@{}];
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
```

## waterfall

`waterfall` 方法用于串行执行一组异步任务, 与 `series` 方法不同, 该组任务具有耦合性, 下一个任务可以拿到上一个任务的执行结果, 执行完毕的回调中只能拿到最后一个任务的执行结果, 与 `series` 方法相同的是任务数组中的任意一个方法执行失败都会导致该组任务执行结束.

使用示例如下: 

``` objective-c
    // 1. 构建模拟任务
	WJAsyncWaterfallTask task0 = ^(id data, WJAsyncTaskCallback callback) {
        NSLog(@"异步任务 task0 开始执行");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"异步任务 task0 执行完毕");
            NSError *err = nil;
			//err = [NSError errorWithDomain:@"WJAsync.domain" code:-1 userInfo:@{}];
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
			//err = [NSError errorWithDomain:@"WJAsync.domain" code:-1 userInfo:@{}];
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
			//err = [NSError errorWithDomain:@"WJAsync.domain" code:-1 userInfo:@{}];
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
```

## parallel 
`parallel` 用于并行执行一组异步任务, 与 `series` 和 `waterfall` 最大的不同就是任务数组内的单个任务失败并不会阻碍任务的继续执行. 执行结束的回调中错误和结果分别使用数组来进行传递.

使用示例如下:

``` objective-c
    // 1. 构建模拟任务
    WJAsyncTask task0 = ^(WJAsyncTaskCallback callback) {
        NSLog(@"异步任务 task0 开始执行");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"异步任务 task0 执行完毕");
            NSString *result = @"异步任务 task0 执行结果";
            NSError *err = nil;
			//err = [NSError errorWithDomain:@"WJAsync.domain" code:-1 userInfo:@{}];
            return callback(err, result);
        });
    };
    WJAsyncTask task1 = ^(WJAsyncTaskCallback callback) {
        NSLog(@"异步任务 task1 开始执行");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"异步任务 task1 执行完毕");
            NSArray *result = @[@"异步任务 task1 执行结果"];
            NSError *err = nil;
			//err = [NSError errorWithDomain:@"WJAsync.domain" code:-1 userInfo:@{}];
            return callback(err, result);
        });
    };
    WJAsyncTask task2 = ^(WJAsyncTaskCallback callback) {
        NSLog(@"异步任务 task2 开始执行");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"异步任务 task2 执行完毕");
            NSDictionary *result = @{@"task2" : @"异步任务 task1 执行结果"};
            NSError *err = nil;
			//err = [NSError errorWithDomain:@"WJAsync.domain" code:-1 userInfo:@{}];
            return callback(err, result);
        });
    };
    // 2. 并发执行
    NSArray *tasks = @[task0, task1, task2];
    [WJAsync parallel:tasks complete:^(NSArray *errors, NSArray *results) {
        NSLog(@"parallel errors: %@", errors);
        NSLog(@"parallel: results: %@", results);
    }]; 
```

