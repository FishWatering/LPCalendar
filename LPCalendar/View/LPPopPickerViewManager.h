//
//  LPPopPickerViewManager.h
//  LPCalendar
//
//  Created by 李萍 on 2018/5/16.
//  Copyright © 2018年 李萍. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LPPopPickerViewManager : NSObject

+ (instancetype)sharedLPPopPickerViewManager;
- (void)showDetailTime:(NSString *)string;
@property (nonatomic, copy) void (^managerTransTimeAction)(NSInteger year, NSInteger month);

@end

/////
@interface LPPopPickerView : UIView

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *contentView;

+ (instancetype)initWithDetailTime:(NSString *)string;
@property (nonatomic, copy) void (^transTimeAction)(NSInteger year, NSInteger month);

@end
