//
//  WZYCalendarCell.h
//  WZYCalendarDemo
//
//  Created by 奔跑宝BPB on 2016/12/23.
//  Copyright © 2016年 wzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WZYCalendarCell : UICollectionViewCell

@property (nonatomic, strong) UIView *todayCircle; //!< 标示'今天'
@property (nonatomic, strong) UILabel *todayLabel; //!< 标示日期（几号）
@property (nonatomic, strong) UIView *pointView; //!< 标示该天具备提醒

@end
