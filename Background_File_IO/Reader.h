//
//  Reader.h
//  Background_File_IO
//
//  Created by wildyao on 14/12/29.
//  Copyright (c) 2014年 Wild Yaoyao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Reader : NSObject

- (id)initWithFileAtURL:(NSURL *)fileURL;

- (void)enumerateLinesWithBlock:(void (^)(NSUInteger lineNumber, NSString *line))block
               completionHandle:(void (^)(NSUInteger numberOfLines))completion;

@end
