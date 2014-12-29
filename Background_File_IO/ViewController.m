//
//  ViewController.m
//  Background_File_IO
//
//  Created by wildyao on 14/12/29.
//  Copyright (c) 2014年 Wild Yaoyao. All rights reserved.
//

#import "ViewController.h"
#import "Reader.h"
#import "BlockTest.h"

@interface ViewController ()

@property (nonatomic, strong) Reader *reader;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSMutableString *string;

@property (nonatomic, copy) void (^testBlock)(int i);

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.string = [NSMutableString string];
    
    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button.frame = CGRectMake(0, 25, self.view.frame.size.width, 40);
    [self.button addTarget:self action:@selector(import:) forControlEvents:UIControlEventTouchUpInside];
    [self.button setTitle:@"Press Me" forState:UIControlStateNormal];
    [self.view addSubview:self.button];

    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, 64)];
    slider.continuous = YES;
    [slider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 150, self.view.frame.size.width, 300)];
    self.textView.backgroundColor = [UIColor grayColor];
    self.textView.editable = NO;
    [self.view addSubview:self.textView];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 460, self.view.frame.size.width, 100)];
    self.label.backgroundColor = [UIColor yellowColor];
    self.label.numberOfLines = 0;
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.label];
    
    // 定义block
    self.testBlock = ^(int i) {
        NSLog(@"i = %d", i);
    };
}

- (void)sliderMoved:(UISlider *)sender;
{
    self.label.text = [NSString stringWithFormat:@"%g", [sender value]];
}

- (void)import:(id)sender
{
//    for (int i = 0; i < 1000; i++) {
//        self.testBlock(i);
//    }
//    
//    BlockTest *test = [[BlockTest alloc] init];
//    // 定义block并将block传递给函数
//    [test executeBlock:^(int index) {
//        NSLog(@"index = %d", index);
//    }];
    
    
    // 1. 一次性直接读入，同步方式
    // 1.1
//    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"Clarissa Harlowe" withExtension:@"txt"];
//    NSData *data = [NSData dataWithContentsOfURL:fileURL];
//    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    self.textView.text = string;
    // 1.2
//    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"Clarissa Harlowe" ofType:@"txt"];
//    NSString *string = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:NULL];;
//    self.textView.text = string;


    // 2 一次性直接读入，异步
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"Clarissa Harlowe" withExtension:@"txt"];
//        NSData *data = [NSData dataWithContentsOfURL:fileURL];
//        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        
//        // 2.1
////        dispatch_async(dispatch_get_main_queue(), ^{
////            self.textView.text = string;
////        });
//        
//        // 2.2
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            self.textView.text = string;
//        }];
//    });
    
    
    // 3. 逐块读入
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"Clarissa Harlowe" withExtension:@"txt"];
    
    self.reader = [[Reader alloc] initWithFileAtURL:fileURL];
    
    [self.reader enumerateLinesWithBlock:^(NSUInteger i, NSString *line) { // each line and its content
//        if (i % 2000 == 0) {
//            NSLog(@"line: %lu", (unsigned long)i);
            [self.string appendFormat:@"line:%lu %@\n", i, line];
//        }
    } completionHandle:^(NSUInteger numberOfLines) {  // total lines
        
        NSLog(@"lines: %lu", (unsigned long)numberOfLines);

        // update UI in main thread
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.button setTitle:@"Done" forState:UIControlStateNormal];
            [self.button setEnabled:NO];
            self.textView.text = self.string;
        }];
    }];
}

@end
