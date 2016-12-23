//
//  WZYCalendarView.m
//  WZYCalendarDemo
//
//  Created by 奔跑宝BPB on 2016/12/23.
//  Copyright © 2016年 wzy. All rights reserved.
//

#import "WZYCalendarView.h"
#import "WZYCalendarScrollView.h"
#import "NSDate+WZYCalendar.h"

@interface WZYCalendarView()

/** 顶部条 年-月 && 今 */
@property (nonatomic, strong) UIView *topYearMonthView;
/** 顶部条 “2016年 12月” button */
@property (nonatomic, strong) UIButton *calendarHeaderButton;
/** 顶部条 “今” button */
@property (nonatomic, strong) UIButton *todayButton;
/** 星期条 */
@property (nonatomic, strong) UIView *weekHeaderView;
/** 日历主体 */
@property (nonatomic, strong) WZYCalendarScrollView *calendarScrollView;

@end

#define HEXCOLOR(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0 green:((float)((hex & 0xFF00) >> 8)) / 255.0 blue:((float)(hex & 0xFF)) / 255.0 alpha:1]

@implementation WZYCalendarView


#pragma mark - Initialization

- (instancetype)initWithFrameOrigin:(CGPoint)origin width:(CGFloat)width {
    
    // 根据宽度计算 calender 主体部分的高度
    CGFloat weekLineHight = 0.85 * (width / 7.0); //  一行的高度
    CGFloat monthHeight = 6 * weekLineHight; // 主体部分整体高度
    
    // 星期头部栏高度
    CGFloat weekHeaderHeight = weekLineHight;
    
    // calendar 头部栏高度
    CGFloat calendarHeaderHeight = weekLineHight;
    
    // 最后得到整个 calender 控件的高度
    _calendarHeight = calendarHeaderHeight + weekHeaderHeight + monthHeight;
    
    if (self = [super initWithFrame:CGRectMake(origin.x, origin.y, width, _calendarHeight)]) {
        
        self.layer.masksToBounds = YES;
        // 整体边框颜色
        self.layer.borderColor = HEXCOLOR(0xEEEEEE).CGColor;
        self.layer.borderWidth = 2.0 / [UIScreen mainScreen].scale;
        self.layer.cornerRadius = 8.0;
        
        // 顶部 2016年12月按钮 单击跳转到当前月份
        _topYearMonthView = [self setupCalendarHeaderWithFrame:CGRectMake(0.0, 0.0, width, calendarHeaderHeight)];
        // 顶部 日 一 二 三 四 五 六 label星期条
        _weekHeaderView = [self setupWeekHeadViewWithFrame:CGRectMake(0.0, calendarHeaderHeight, width, weekHeaderHeight)];
        // 底部月历滚动scroll
        _calendarScrollView = [self setupCalendarScrollViewWithFrame:CGRectMake(0.0, calendarHeaderHeight + weekHeaderHeight, width, monthHeight)];
        
        [self addSubview:_topYearMonthView];
        [self addSubview:_weekHeaderView];
        [self addSubview:_calendarScrollView];
        
        // 注册 Notification 监听
        [self addNotificationObserver];
        
    }
    
    return self;
    
}

- (void)dealloc {
    // 移除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/** 设置顶部条，显示 年-月 的 */
- (UIView *)setupCalendarHeaderWithFrame:(CGRect)frame {
    
    UIView *backView = [[UIView alloc] initWithFrame:frame];
    backView.backgroundColor = HEXCOLOR(0xF6F6F6);
    
    UIButton *yearMonthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _calendarHeaderButton = yearMonthButton;
    yearMonthButton.frame = CGRectMake(0, 0, 120, frame.size.height);
    yearMonthButton.backgroundColor = [UIColor clearColor];
    [yearMonthButton setTitleColor:HEXCOLOR(0xFF5A39) forState:UIControlStateNormal];
    [yearMonthButton.titleLabel setFont:[UIFont fontWithName:@"PingFang SC" size:16]];
    [backView addSubview:yearMonthButton];
    
    UIButton *todayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    todayButton.frame = CGRectMake(frame.size.width - frame.size.height, 7, frame.size.height - 14, frame.size.height - 14);
    [todayButton setTitle:@"今" forState:UIControlStateNormal];
    [todayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    todayButton.backgroundColor = HEXCOLOR(0xFF5A39);
    todayButton.layer.cornerRadius = todayButton.frame.size.width * 0.5;
    [todayButton addTarget:self action:@selector(refreshToCurrentMonthAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:todayButton];
    
    return backView;
}

/** 设置星期条，显示 日 一 二 ... 五 六 */
- (UIView *)setupWeekHeadViewWithFrame:(CGRect)frame {
    
    CGFloat height = frame.size.height;
    CGFloat width = frame.size.width / 7.0;
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    //    view.backgroundColor = HEXCOLOR(0xF6F6F6);
    view.backgroundColor = [UIColor whiteColor];
    
    NSArray *weekArray = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
    for (int i = 0; i < 7; ++i) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * width, 0.0, width, height)];
        label.backgroundColor = [UIColor clearColor];
        label.text = weekArray[i];
        if ([label.text isEqualToString:@"日"] || [label.text isEqualToString:@"六"]) {
            label.textColor = HEXCOLOR(0xADADAD);
        } else {
            label.textColor = [UIColor colorWithWhite:0 alpha:0.87];
        }
        
        label.font = [UIFont fontWithName:@"PingFang SC" size:13.5];
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        
    }
    
    return view;
    
}

/** 设置底部滚动日历 */
- (WZYCalendarScrollView *)setupCalendarScrollViewWithFrame:(CGRect)frame {
    // 构造方法
    WZYCalendarScrollView *scrollView = [[WZYCalendarScrollView alloc] initWithFrame:frame];
    return scrollView;
}

/** 重写block回调方法 */
- (void)setDidSelectDayHandler:(DidSelectDayHandler)didSelectDayHandler {
    _didSelectDayHandler = didSelectDayHandler;
    if (_calendarScrollView != nil) {
        _calendarScrollView.didSelectDayHandler = _didSelectDayHandler; // 传递 block（将日历中日期点击之后得到的对应数据返回给CalendarView）
        // 由于_calendarScrollView 的 block 是由外层的 CalendarView 传给他的，所以说当这个 block 有回调之后，外面的 CalendarView 的 block 也就有了回调结果。所以说控制器就可以拿到了。这是属于指针之间的传递。
    }
}

/** 添加通知的接收 */
- (void)addNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCalendarHeaderAction:) name:@"ChangeCalendarHeaderNotification" object:nil];
}


#pragma mark - Actions
/** 改变 顶部年月栏 的日期显示 && 滚动到当前月份 */
- (void)refreshToCurrentMonthAction:(UIButton *)sender {
    
    // 设置显示日期
    NSInteger year = [[NSDate date] dateYear];
    NSInteger month = [[NSDate date] dateMonth];
    
    NSString *title = [NSString stringWithFormat:@"%d年 %d月", (int)year, (int)month];
    [_calendarHeaderButton setTitle:title forState:UIControlStateNormal];
    
    // 进行滑动
    [_calendarScrollView refreshToCurrentMonth];
    
}

// 接收通知传递回来的数据（包装在sender.userInfo里面）
- (void)changeCalendarHeaderAction:(NSNotification *)sender {
    
    NSDictionary *dic = sender.userInfo;
    
    NSNumber *year = dic[@"year"];
    NSNumber *month = dic[@"month"];
    
    NSString *title = [NSString stringWithFormat:@"%@年 %@月", year, month];
    
    [_calendarHeaderButton setTitle:title forState:UIControlStateNormal];
}

@end

