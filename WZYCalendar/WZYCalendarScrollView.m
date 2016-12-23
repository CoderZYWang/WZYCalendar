//
//  WZYCalendarScrollView.m
//  WZYCalendarDemo
//
//  Created by 奔跑宝BPB on 2016/12/23.
//  Copyright © 2016年 wzy. All rights reserved.
//

#import "WZYCalendarScrollView.h"

#import "WZYCalendarCell.h"
#import "WZYCalendarMonth.h"
#import "NSDate+WZYCalendar.h"

@interface WZYCalendarScrollView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionViewL;
@property (nonatomic, strong) UICollectionView *collectionViewM;
@property (nonatomic, strong) UICollectionView *collectionViewR;

// 当天（当前月当天）
@property (nonatomic, strong) NSDate *currentMonthDate;

@property (nonatomic, strong) NSMutableArray *monthArray;

@end

@implementation WZYCalendarScrollView

#define CURRENTHEXCOLOR(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0 green:((float)((hex & 0xFF00) >> 8)) / 255.0 blue:((float)(hex & 0xFF)) / 255.0 alpha:1]

static NSString *const kCellIdentifier = @"cell";


#pragma mark - Initialiaztion

- (instancetype)initWithFrame:(CGRect)frame {
    
    if ([super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.bounces = NO;
        self.delegate = self;
        
        self.contentSize = CGSizeMake(3 * self.bounds.size.width, self.bounds.size.height);
        [self setContentOffset:CGPointMake(self.bounds.size.width, 0.0) animated:NO];
        
        _currentMonthDate = [NSDate date];
        [self setupCollectionViews];
        
    }
    
    return self;
    
}

- (NSMutableArray *)monthArray {
    
    if (_monthArray == nil) {
        
        _monthArray = [NSMutableArray arrayWithCapacity:4];
        
        // 上一个月的当天
        NSDate *previousMonthDate = [_currentMonthDate previousMonthDate];
        // 下一个月的当天
        NSDate *nextMonthDate = [_currentMonthDate nextMonthDate];
        
        [_monthArray addObject:[[WZYCalendarMonth alloc] initWithDate:previousMonthDate]];
        [_monthArray addObject:[[WZYCalendarMonth alloc] initWithDate:_currentMonthDate]];
        [_monthArray addObject:[[WZYCalendarMonth alloc] initWithDate:nextMonthDate]];
        [_monthArray addObject:[self previousMonthDaysForPreviousDate:previousMonthDate]]; // 存储左边的月份的前一个月份的天数，用来填充左边月份的首部（这里获取的其实是当前月的上上个月）
        
        // 发通知，更改当前月份标题
        [self notifyToChangeCalendarHeader];
    }
    
    return _monthArray;
}

- (NSNumber *)previousMonthDaysForPreviousDate:(NSDate *)date {
    // 传入date，然后拿到date的上个月份的总天数
    return [[NSNumber alloc] initWithInteger:[[date previousMonthDate] totalDaysInMonth]];
}


- (void)setupCollectionViews {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(self.bounds.size.width / 7.0, self.bounds.size.width / 7.0 * 0.85);
    flowLayout.minimumLineSpacing = 0.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    
    CGFloat selfWidth = self.bounds.size.width;
    CGFloat selfHeight = self.bounds.size.height;
    
    // 设置三个 collectionView，一次性加载三个 collectionView 的数据
    _collectionViewL = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, selfWidth, selfHeight) collectionViewLayout:flowLayout];
    _collectionViewL.dataSource = self;
    _collectionViewL.delegate = self;
    _collectionViewL.backgroundColor = [UIColor clearColor];
    [_collectionViewL registerClass:[WZYCalendarCell class] forCellWithReuseIdentifier:kCellIdentifier];
    [self addSubview:_collectionViewL];
    
    _collectionViewM = [[UICollectionView alloc] initWithFrame:CGRectMake(selfWidth, 0.0, selfWidth, selfHeight) collectionViewLayout:flowLayout];
    _collectionViewM.dataSource = self;
    _collectionViewM.delegate = self;
    _collectionViewM.backgroundColor = [UIColor clearColor];
    [_collectionViewM registerClass:[WZYCalendarCell class] forCellWithReuseIdentifier:kCellIdentifier];
    [self addSubview:_collectionViewM];
    
    _collectionViewR = [[UICollectionView alloc] initWithFrame:CGRectMake(2 * selfWidth, 0.0, selfWidth, selfHeight) collectionViewLayout:flowLayout];
    _collectionViewR.dataSource = self;
    _collectionViewR.delegate = self;
    _collectionViewR.backgroundColor = [UIColor clearColor];
    [_collectionViewR registerClass:[WZYCalendarCell class] forCellWithReuseIdentifier:kCellIdentifier];
    [self addSubview:_collectionViewR];
    
}


#pragma mark -

/** 滚动日历主体后 拼接修改的顶部 年月条 显示数据 并发出通知进行修改 */
- (void)notifyToChangeCalendarHeader {
    
    WZYCalendarMonth *currentMonthInfo = self.monthArray[1];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [userInfo setObject:[[NSNumber alloc] initWithInteger:currentMonthInfo.year] forKey:@"year"];
    [userInfo setObject:[[NSNumber alloc] initWithInteger:currentMonthInfo.month] forKey:@"month"];
    
    NSNotification *notify = [[NSNotification alloc] initWithName:@"ChangeCalendarHeaderNotification" object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notify];
}

- (void)refreshToCurrentMonth {
    
    // 如果现在就在当前月份，则不执行操作
    WZYCalendarMonth *currentMonthInfo = self.monthArray[1];
    if ((currentMonthInfo.month == [[NSDate date] dateMonth]) && (currentMonthInfo.year == [[NSDate date] dateYear])) {
        return;
    }
    
    _currentMonthDate = [NSDate date];
    
    NSDate *previousMonthDate = [_currentMonthDate previousMonthDate];
    NSDate *nextMonthDate = [_currentMonthDate nextMonthDate];
    
    [self.monthArray removeAllObjects];
    [self.monthArray addObject:[[WZYCalendarMonth alloc] initWithDate:previousMonthDate]];
    [self.monthArray addObject:[[WZYCalendarMonth alloc] initWithDate:_currentMonthDate]];
    [self.monthArray addObject:[[WZYCalendarMonth alloc] initWithDate:nextMonthDate]];
    [self.monthArray addObject:[self previousMonthDaysForPreviousDate:previousMonthDate]];
    
    // 刷新数据
    [_collectionViewM reloadData];
    [_collectionViewL reloadData];
    [_collectionViewR reloadData];
    
}


#pragma mark - UICollectionDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 42; // 7 * 6
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WZYCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    if (collectionView == _collectionViewL) { // 上一个月展示数据
        
        WZYCalendarMonth *monthInfo = self.monthArray[0];
        NSInteger firstWeekday = monthInfo.firstWeekday; // 该月第一天是星期几
        NSInteger totalDays = monthInfo.totalDays; // 该月有几天
        
        // 当前月
        if (indexPath.row >= firstWeekday && indexPath.row < firstWeekday + totalDays) {
            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday + 1];
            cell.todayLabel.textColor = [UIColor colorWithWhite:0 alpha:0.87];
            
            // 标识今天
            if ((monthInfo.month == [[NSDate date] dateMonth]) && (monthInfo.year == [[NSDate date] dateYear])) {
                if (indexPath.row == [[NSDate date] dateDay] + firstWeekday - 1) {
                    cell.todayCircle.backgroundColor = CURRENTHEXCOLOR(0xFF5A39);
                    cell.todayLabel.textColor = [UIColor whiteColor];
                } else {
                    cell.todayCircle.backgroundColor = [UIColor clearColor];
                }
            } else {
                cell.todayCircle.backgroundColor = [UIColor clearColor];
            }
            
        }
        // 补上前后月的日期，淡色显示
        else if (indexPath.row < firstWeekday) {
            int totalDaysOflastMonth = [self.monthArray[3] intValue];
            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", totalDaysOflastMonth - (firstWeekday - indexPath.row) + 1];
            cell.todayLabel.textColor = CURRENTHEXCOLOR(0xADADAD);
            cell.todayCircle.backgroundColor = [UIColor clearColor];
        } else if (indexPath.row >= firstWeekday + totalDays) {
            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday - totalDays + 1];
            cell.todayLabel.textColor = CURRENTHEXCOLOR(0xADADAD);
            cell.todayCircle.backgroundColor = [UIColor clearColor];
        }
        
        cell.userInteractionEnabled = NO;
        
    } else if (collectionView == _collectionViewM) { // 当前月的展示数据
        
        WZYCalendarMonth *monthInfo = self.monthArray[1];
        
        // 当前日期所在月份第一天是周几
        NSInteger firstWeekday = monthInfo.firstWeekday;
        // 当前日期是所在月份的第几天
        NSInteger totalDays = monthInfo.totalDays;
        
        // 当前月
        if (indexPath.row >= firstWeekday && indexPath.row < firstWeekday + totalDays) {
            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday + 1];
            cell.todayLabel.textColor = [UIColor colorWithWhite:0 alpha:0.87];
            cell.userInteractionEnabled = YES;
            
            // 标识今天
            if ((monthInfo.month == [[NSDate date] dateMonth]) && (monthInfo.year == [[NSDate date] dateYear])) {
                if (indexPath.row == [[NSDate date] dateDay] + firstWeekday - 1) {
                    cell.todayCircle.backgroundColor = CURRENTHEXCOLOR(0xFF5A39);
                    cell.todayLabel.textColor = [UIColor whiteColor];
                } else {
                    cell.todayCircle.backgroundColor = [UIColor clearColor];
                }
            } else {
                cell.todayCircle.backgroundColor = [UIColor clearColor];
            }
            
        }
        // 补上前后月的日期，淡色显示
        else if (indexPath.row < firstWeekday) {
            WZYCalendarMonth *lastMonthInfo = self.monthArray[0];
            NSInteger totalDaysOflastMonth = lastMonthInfo.totalDays;
            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", totalDaysOflastMonth - (firstWeekday - indexPath.row) + 1];
            cell.todayLabel.textColor = CURRENTHEXCOLOR(0xADADAD);
            cell.todayCircle.backgroundColor = [UIColor clearColor];
            cell.userInteractionEnabled = NO;
        } else if (indexPath.row >= firstWeekday + totalDays) {
            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday - totalDays + 1];
            cell.todayLabel.textColor = CURRENTHEXCOLOR(0xADADAD);
            cell.todayCircle.backgroundColor = [UIColor clearColor];
            cell.userInteractionEnabled = NO;
        }
        
    } else if (collectionView == _collectionViewR) { // 下一个月的展示数据
        
        WZYCalendarMonth *monthInfo = self.monthArray[2];
        NSInteger firstWeekday = monthInfo.firstWeekday;
        NSInteger totalDays = monthInfo.totalDays;
        
        // 当前月
        if (indexPath.row >= firstWeekday && indexPath.row < firstWeekday + totalDays) {
            
            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday + 1];
            cell.todayLabel.textColor = [UIColor colorWithWhite:0 alpha:0.87];
            
            // 标识今天
            if ((monthInfo.month == [[NSDate date] dateMonth]) && (monthInfo.year == [[NSDate date] dateYear])) {
                if (indexPath.row == [[NSDate date] dateDay] + firstWeekday - 1) {
                    cell.todayCircle.backgroundColor = CURRENTHEXCOLOR(0xFF5A39);
                    cell.todayLabel.textColor = [UIColor whiteColor];
                } else {
                    cell.todayCircle.backgroundColor = [UIColor clearColor];
                }
            } else {
                cell.todayCircle.backgroundColor = [UIColor clearColor];
            }
            
            // 补上前后月的日期，淡色显示
        } else if (indexPath.row < firstWeekday) {
            WZYCalendarMonth *lastMonthInfo = self.monthArray[1];
            NSInteger totalDaysOflastMonth = lastMonthInfo.totalDays;
            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", totalDaysOflastMonth - (firstWeekday - indexPath.row) + 1];
            cell.todayLabel.textColor = CURRENTHEXCOLOR(0xADADAD);
            cell.todayCircle.backgroundColor = [UIColor clearColor];
        } else if (indexPath.row >= firstWeekday + totalDays) {
            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday - totalDays + 1];
            cell.todayLabel.textColor = CURRENTHEXCOLOR(0xADADAD);
            cell.todayCircle.backgroundColor = [UIColor clearColor];
        }
        
        cell.userInteractionEnabled = NO;
        
    }
    
    return cell;
    
}


#pragma mark - UICollectionViewDeleagate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.didSelectDayHandler != nil) {
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:_currentMonthDate];
        NSDate *currentDate = [calendar dateFromComponents:components];
        
        WZYCalendarCell *cell = (WZYCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        NSInteger year = [currentDate dateYear];
        NSInteger month = [currentDate dateMonth];
        NSInteger day = [cell.todayLabel.text integerValue];
        
        self.didSelectDayHandler(year, month, day); // 执行回调（将点击的日期cell上面的信息回调出去）
    }
    
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView != self) {
        return;
    }
    
    /**
     注意 ： 当前月份当前天 == 现在这一天     当前显示月份 == 当前界面上显示的那个月份
     
     假设 当天为 2016年12月22日 那么当前显示的日历为 11月 | 12月 | 1月
     在上面这个假设的基础上我们进行滑动操作
     
     原本的monthArray = [11月monthInfo， 12月monthInfo， 1月monthInfo， 10月份天数];
     说明一下：为什么要传入10月份的天数，因为左侧显示部分会带有10月份后面几天，而1月份后面显示的会有2月份的前几天。由于每个月前几天是确定的，而后几天不确定，所以说数组中要加上这么一个参数。
     */
    
    // 向右滑动
    if (scrollView.contentOffset.x < self.bounds.size.width) {
        
        _currentMonthDate = [_currentMonthDate previousMonthDate]; // currentMonthDate 11月15日（向右滑动之后，原本显示在左侧的上个月就变成了当前显示的月份，原本的_currentMonthDate是当前月份当前天，但是向右滑动之后就变成了左侧月份的15号这一天）
        NSDate *previousDate = [_currentMonthDate previousMonthDate]; // previousDate 10月15日（又进行了一次取前一月份15日的操作，在上面一句的基础上）
        
        // 取数组中的值（该数组还是滑动之前的）
        WZYCalendarMonth *currentMothInfo = self.monthArray[0]; // currentMothInfo 11月
        WZYCalendarMonth *nextMonthInfo = self.monthArray[1]; // nextMonthInfo 12月
        WZYCalendarMonth *olderNextMonthInfo = self.monthArray[2]; // olderNextMonthInfo 1月
        
        // 复用 WZYCalendarMonth 对象
        olderNextMonthInfo.totalDays = [previousDate totalDaysInMonth]; //
        olderNextMonthInfo.firstWeekday = [previousDate firstWeekDayInMonth]; //
        olderNextMonthInfo.year = [previousDate dateYear]; //
        olderNextMonthInfo.month = [previousDate dateMonth]; //
        WZYCalendarMonth *previousMonthInfo = olderNextMonthInfo; // previousMonthInfo == olderNextMonthInfo == 10月份信息
        
        NSNumber *prePreviousMonthDays = [self previousMonthDaysForPreviousDate:[_currentMonthDate previousMonthDate]]; // prePreviousMonthDays 拿到9月份的天数 （后面的传值是10月15日）
        
        [self.monthArray removeAllObjects];
        
        
        [self.monthArray addObject:previousMonthInfo];
        [self.monthArray addObject:currentMothInfo];
        [self.monthArray addObject:nextMonthInfo];
        [self.monthArray addObject:prePreviousMonthDays];
        // 新的 monthArray = [10月monthInfo， 11月monthInfo， 12月monthInfo， 9月份天数];
    }
    // 向左滑动
    else if (scrollView.contentOffset.x > self.bounds.size.width) {
        
        _currentMonthDate = [_currentMonthDate nextMonthDate];
        NSDate *nextDate = [_currentMonthDate nextMonthDate];
        
        // 数组中最右边的月份现在作为中间的月份，中间的作为左边的月份，新的右边的需要重新获取
        WZYCalendarMonth *previousMonthInfo = self.monthArray[1];
        WZYCalendarMonth *currentMothInfo = self.monthArray[2];
        
        
        WZYCalendarMonth *olderPreviousMonthInfo = self.monthArray[0];
        
        NSNumber *prePreviousMonthDays = [[NSNumber alloc] initWithInteger:olderPreviousMonthInfo.totalDays]; // 先保存 olderPreviousMonthInfo 的月天数
        
        // 复用 WZYCalendarMonth 对象
        olderPreviousMonthInfo.totalDays = [nextDate totalDaysInMonth];
        olderPreviousMonthInfo.firstWeekday = [nextDate firstWeekDayInMonth];
        olderPreviousMonthInfo.year = [nextDate dateYear];
        olderPreviousMonthInfo.month = [nextDate dateMonth];
        WZYCalendarMonth *nextMonthInfo = olderPreviousMonthInfo;
        
        
        [self.monthArray removeAllObjects];
        [self.monthArray addObject:previousMonthInfo];
        [self.monthArray addObject:currentMothInfo];
        [self.monthArray addObject:nextMonthInfo];
        [self.monthArray addObject:prePreviousMonthDays];
        
    }
    
    [_collectionViewM reloadData]; // 中间的 collectionView 先刷新数据
    [scrollView setContentOffset:CGPointMake(self.bounds.size.width, 0.0) animated:NO]; // 然后变换位置
    [_collectionViewL reloadData]; // 最后两边的 collectionView 也刷新数据
    [_collectionViewR reloadData];
    
    // 发通知，更改当前月份标题
    [self notifyToChangeCalendarHeader];
    
}

@end
