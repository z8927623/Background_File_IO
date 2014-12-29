//
//  BlockTest.m
//  Background_File_IO
//
//  Created by wildyao on 14/12/29.
//  Copyright (c) 2014年 Wild Yaoyao. All rights reserved.
//

#import "BlockTest.h"

@implementation BlockTest

- (void)executeBlock:(void (^)(int index))block
{
    for (int i = 0; i < 1000; i++) {
        block(i);
    }
}

@end
