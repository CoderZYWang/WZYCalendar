//
//  WZYCalendarCell.m
//  WZYCalendarDemo
//
//  Created by 奔跑宝BPB on 2016/12/23.
//  Copyright © 2016年 wzy. All rights reserved.
//

#import "WZYCalendarCell.h"

@implementation WZYCalendarCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        // 标识当天的背景圈圈
        [self addSubview:self.todayCircle];
        // 当天的日期数字
        [self addSubview:self.todayLabel];
        // 提醒标记点
        //        [self addSubview:self.pointView];
        
    }
    
    return self;
}

- (UIView *)todayCircle {
    if (_todayCircle == nil) {
        _todayCircle = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.8 * self.bounds.size.height, 0.8 * self.bounds.size.height)];
        _todayCircle.center = CGPointMake(0.5 * self.bounds.size.width, 0.5 * self.bounds.size.height);
        _todayCircle.layer.cornerRadius = 0.5 * _todayCircle.frame.size.width;
    }
    return _todayCircle;
}

- (UILabel *)todayLabel {
    if (_todayLabel == nil) {
        _todayLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _todayLabel.textAlignment = NSTextAlignmentCenter;
        _todayLabel.font = [UIFont fontWithName:@"PingFang SC" size:15];
        _todayLabel.backgroundColor = [UIColor clearColor];
    }
    return _todayLabel;
}

- (UIView *)pointView {
    if (_pointView == nil) {
        _pointView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 4 - 2, 2, 4, 4)];
        _pointView.layer.cornerRadius = 2;
        _pointView.backgroundColor = [UIColor redColor];
    }
    return _pointView;
}

@end
