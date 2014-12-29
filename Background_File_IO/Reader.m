//
//  Reader.m
//  Background_File_IO
//
//  Created by wildyao on 14/12/29.
//  Copyright (c) 2014年 Wild Yaoyao. All rights reserved.
//

#import "Reader.h"
#import "NSData+EnumerateComponents.h"

@interface Reader () <NSStreamDelegate>

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, copy) NSData *delimiter;
@property (nonatomic, strong) NSMutableData *remainder;    // 待处理数据
@property (nonatomic, copy) void (^callback)(NSUInteger lineNumber, NSString *line);
@property (nonatomic, copy) void (^completion)(NSUInteger numberOfLines);
@property (nonatomic) NSUInteger lineNumber;
@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation Reader

- (id)initWithFileAtURL:(NSURL *)fileURL
{
    if (![fileURL isFileURL]) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.fileURL = fileURL;
        self.delimiter = [@"\n" dataUsingEncoding:NSUTF8StringEncoding];
        self.lineNumber = 0;
    }
    return self;
}

- (void)enumerateLinesWithBlock:(void (^)(NSUInteger lineNumber, NSString *line))block
               completionHandle:(void (^)(NSUInteger numberOfLines))completion
{
    if (self.queue == nil) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
    }
    
    self.callback = block;
    self.completion = completion;
    
    self.inputStream = [NSInputStream inputStreamWithURL:self.fileURL];
    self.inputStream.delegate = self;
    // main runloop来分发事件
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
}


#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            
            break;
        case NSStreamEventEndEncountered:   // 到达尾部
        {
            [self emitLineWithData:self.remainder];
            self.remainder = nil;
            [self.inputStream close];
            self.inputStream = nil;
            
             __weak typeof(self) weakSelf = self;
            [self.queue addOperationWithBlock:^{
                weakSelf.completion(weakSelf.lineNumber+1);
            }];
        }
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"error");   // TODO
            break;
        case NSStreamEventHasBytesAvailable:    // 处理数据
        {
            NSMutableData *buffer = [NSMutableData dataWithLength:4*1024];
            // inputStream读取4*1024kb的数据，并将数据填入buffer
            NSUInteger length = [self.inputStream read:[buffer mutableBytes] maxLength:[buffer length]];
            if (length > 0) {
                [buffer setLength:length];

                __weak id weakSelf = self;
                // handle data in background thread
                [self.queue addOperationWithBlock:^{
                    // 处理每次读取的4*1024kb数据块
                    [weakSelf processDataChunk:buffer];
                }];
            }
        }
            break;
        default:
            break;
    }
}

// 处理每次读取的4*1024kb数据块
- (void)processDataChunk:(NSMutableData *)buffer
{
    if (self.remainder != nil) {   // 没处理完，累加
        [self.remainder appendData:buffer];
    } else {
        self.remainder = buffer;   // 先前数据已处理完
    }
    
    // 将数据块分行处理
    [self.remainder obj_enumerateComponentsSeparatedBy:self.delimiter usingBlock:^(NSData *component, BOOL last) {
        if (!last) {
            // 将每行读取的data转换成string
            [self emitLineWithData:component];
        } else if (component.length > 0) {  //
            self.remainder  = [component mutableCopy];
        } else {
            // 处理完，清空
            self.remainder = nil;
        }
    }];
}

- (void)emitLineWithData:(NSData *)data   // data每行读取的数据
{
    // calculate total lines
    NSUInteger lineNumber = self.lineNumber;
    self.lineNumber = lineNumber+1;
    
    if (data.length > 0) {
        // 转化成string
        NSString *line = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.callback(lineNumber, line);
    }
}

@end
