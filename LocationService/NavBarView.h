//
//  NavBarView.h
//  LocationService
//
//  Created by aJia on 2013/12/23.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavBarView : UIView
- (void)setNavBarTitle:(NSString*)title;//标题
- (void)setBackButtonWithTarget:(id)target action:(SEL)action;//返回按钮
- (void)setMonitorButtonWithTarget:(id)target action:(SEL)action;//监控
- (void)setTargetButtonWithTarget:(id)target action:(SEL)action;//人物
- (void)setCompassButtonWithTarget:(id)target action:(SEL)action;//指南针
- (void)removeSubviews;
@end
