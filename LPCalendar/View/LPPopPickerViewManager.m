//
//  LPPopPickerViewManager.m
//  LPCalendar
//
//  Created by 李萍 on 2018/5/16.
//  Copyright © 2018年 李萍. All rights reserved.
//

#import "LPPopPickerViewManager.h"

#define kScreen_Height [UIScreen mainScreen].bounds.size.height
#define kScreen_Width [UIScreen mainScreen].bounds.size.width

#define bottomViewHeight 300

@interface LPPopPickerViewManager ()
{
    __weak LPPopPickerView *_popPickerView;
}

@end

static LPPopPickerViewManager *_popPickerViewManager;
@implementation LPPopPickerViewManager

+ (instancetype)sharedLPPopPickerViewManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _popPickerViewManager = [LPPopPickerViewManager new];
    });
    
    return _popPickerViewManager;
}

- (void)showDetailTime:(NSString *)string
{
    if (_popPickerView) {
        _popPickerView = nil;
    }
    
    LPPopPickerView *popPickerView = [LPPopPickerView initWithDetailTime:string];
    _popPickerView = popPickerView;
    
    popPickerView.frame = [UIScreen mainScreen].bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:popPickerView];
    popPickerView.transTimeAction = ^(NSInteger year, NSInteger month) {
        if (self.managerTransTimeAction) {
            self.managerTransTimeAction(year, month);
        }
    };
    
    //背景蒙层的动画：alpha值从0.0变化到0.5
    [popPickerView.bgView setAlpha:0.0];
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear animations:^{
                            [popPickerView.bgView setAlpha:0.5];
                        } completion:^(BOOL finished) { }];
    
    //分享面板的动画：从底部向上滚动弹出来
    [popPickerView.contentView setFrame:CGRectMake(0, kScreen_Height, kScreen_Width, bottomViewHeight)];
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear animations:^{
                            [popPickerView.contentView setFrame:CGRectMake(0, kScreen_Height-bottomViewHeight, kScreen_Width, bottomViewHeight)];
                        } completion:^(BOOL finished) {}];
}

@end

/////

@interface LPPopPickerView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UILabel *titleLb;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSMutableArray *yearArray;
@property (nonatomic, strong) NSMutableArray *monthArray;

@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger month;

@end

@implementation LPPopPickerView

+ (instancetype)initWithDetailTime:(NSString *)string
{
    LPPopPickerView *popPickerView = [[LPPopPickerView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    popPickerView.backgroundColor = [UIColor clearColor];
    
    [popPickerView layoutPopPickerView:string];
    
    return popPickerView;
}

- (void)layoutPopPickerView:(NSString *)string
{
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    _bgView.backgroundColor = [UIColor clearColor];
    [self addSubview:_bgView];
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height-bottomViewHeight, kScreen_Width, bottomViewHeight)];
    _contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_contentView];
    
    UIButton *cancleBtn = [UIButton new];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancleBtn addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:cancleBtn];
    [cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(10);
        make.top.equalTo(self.contentView.mas_top).offset(10);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
    
    UIButton *sureBtn = [UIButton new];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:sureBtn];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.top.equalTo(self.contentView.mas_top).offset(10);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
    
    UILabel *titleLb = [UILabel new];
    titleLb.text = string;
    titleLb.font = [UIFont systemFontOfSize:18];
    titleLb.textColor = [UIColor blackColor];
    [_contentView addSubview:titleLb];
    [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(sureBtn.mas_centerY);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    self.titleLb = titleLb;
    
    self.pickerView = [UIPickerView new];
    [_contentView addSubview:self.pickerView];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(50);
        make.top.equalTo(titleLb.mas_bottom).offset(10);
        make.right.equalTo(self.contentView.mas_right).offset(-50);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-50);
    }];
}

#pragma mark - action

- (void)cancleAction
{
    if (self.superview) {
        [self removeFromSuperview];
    }
}

- (void)sureAction
{
    if (self.transTimeAction) {
        self.transTimeAction(self.year, self.month);
    }
    
    if (self.superview) {
        [self removeFromSuperview];
    }
}


#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return self.yearArray.count;
    } else if (component == 1) {
        return 12;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {

        return self.yearArray[row];
    } else if (component == 1) {
        
        return self.monthArray[row];
    }
    return @"";
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        //
        NSString *yearStr = self.yearArray[row];
        yearStr = [yearStr componentsSeparatedByString:@"年"][0];
        
        self.year = [yearStr integerValue];
        self.month = 1;
        [self.pickerView selectRow:0 inComponent:1 animated:YES];
    } else if (component == 1) {

        NSString *monthStr = self.monthArray[row];
        monthStr = [monthStr componentsSeparatedByString:@"月"][0];
        
        self.month = [monthStr integerValue];
    }
    
    self.titleLb.text = [NSString stringWithFormat:@"%ld年%ld月", self.year, self.month];
}

#pragma mark - init
- (NSMutableArray *)yearArray
{
    if (_yearArray == nil) {
        _yearArray = [NSMutableArray array];
        for (int year = 2000; year < 2050; year++) {
            NSString *str = [NSString stringWithFormat:@"%d年", year];
            [_yearArray addObject:str];
        }
    }
    return _yearArray;
}

- (NSMutableArray *)monthArray
{
    if (_monthArray == nil) {
        _monthArray = [NSMutableArray array];
        for (int month = 1; month <= 12; month++) {
            NSString *str = [NSString stringWithFormat:@"%02d月", month];
            [_monthArray addObject:str];
        }
    }
    return _monthArray;
}

@end
