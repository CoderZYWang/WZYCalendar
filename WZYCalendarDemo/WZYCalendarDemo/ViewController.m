//
//  ViewController.m
//  WZYCalendarDemo
//
//  Created by 奔跑宝BPB on 2016/12/23.
//  Copyright © 2016年 wzy. All rights reserved.
//

#import "ViewController.h"

#import "PushController.h"
#import "WZYCalendar.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"WZYCalendar";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupCalendar]; // 初始化日历对象
}

- (void)setupCalendar {
    
    CGFloat width = self.view.bounds.size.width - 20.0;
    CGPoint origin = CGPointMake(10.0, 64.0 + 80.0);
    
    // 传入Calendar的origin和width。自动计算控件高度
    WZYCalendarView *calendar = [[WZYCalendarView alloc] initWithFrameOrigin:origin width:width];
    
    NSLog(@"height --- %lf", calendar.frame.size.height);
    
    // 点击某一天的回调
    calendar.didSelectDayHandler = ^(NSInteger year, NSInteger month, NSInteger day) {
        
        PushController *pvc = [[PushController alloc] init];
        pvc.titles = [NSString stringWithFormat:@"%ld年%ld月%ld日", year, month, day];
        [self.navigationController pushViewController:pvc animated:YES];
        
    };
    
    [self.view addSubview:calendar];
    
}

@end
