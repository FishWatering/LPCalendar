//
//  ViewController.m
//  LPCalendar
//
//  Created by 李萍 on 2018/5/11.
//  Copyright © 2018年 李萍. All rights reserved.
//

#import "ViewController.h"

#import "LPPopPickerViewManager.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"日历";
    self.view.backgroundColor = [UIColor cyanColor];
    
    
    
    UIButton *button = [UIButton new];
    [button setTitle:@"btn" forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(20);
        make.top.equalTo(self.view.mas_top).offset(120);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.height.equalTo(@(30));
    }];
}

- (void)buttonAction
{
    LPPopPickerViewManager *manager = [LPPopPickerViewManager sharedLPPopPickerViewManager];
    [manager showDetailTime:@"2018.05.16"];
    manager.managerTransTimeAction = ^(NSInteger year, NSInteger month) {
        NSLog(@"sure year = %ld month = %ld", year, month);
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
