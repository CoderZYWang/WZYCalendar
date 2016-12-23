//
//  WZYCalendarScrollView.h
//  WZYCalendarDemo
//
//  Created by 奔跑宝BPB on 2016/12/23.
//  Copyright © 2016年 wzy. All rights reserved.
//

#import <UIKit/UIKit.h>

// 定义回调Block
typedef void (^DidSelectDayHandler)(NSInteger, NSInteger, NSInteger);

@interface WZYCalendarScrollView : UIScrollView

@property (nonatomic, copy) DidSelectDayHandler didSelectDayHandler; // 日期点击回调

- (void)refreshToCurrentMonth; // 刷新 calendar 回到当前日期月份

@end
