//
//  BlockTest.h
//  Background_File_IO
//
//  Created by wildyao on 14/12/29.
//  Copyright (c) 2014年 Wild Yaoyao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlockTest : NSObject

- (void)executeBlock:(void (^)(int i))block;

@end
