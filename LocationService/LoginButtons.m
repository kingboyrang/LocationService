//
//  LoginButtons.m
//  LocationService
//
//  Created by aJia on 2013/12/19.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "LoginButtons.h"
#import "UIColor+TPCategory.h"
@implementation LoginButtons

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor colorFromHexRGB:@"131313"];
        
        _cancel=[UIButton buttonWithType:UIButtonTypeCustom];
        _cancel.frame=CGRectMake(0, 0, frame.size.width/2, frame.size.height);
        [_cancel setTitle:@"取消" forState:UIControlStateNormal];
        [_cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancel.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
         _cancel.showsTouchWhenHighlighted = YES;  //指定按钮被按下时发光
        [_cancel setTitleColor:[UIColor colorFromHexRGB:@"4a7ebb"] forState:UIControlStateHighlighted];
        [self addSubview:_cancel];
        
        _submit=[UIButton buttonWithType:UIButtonTypeCustom];
        _submit.frame=CGRectMake(frame.size.width/2, 0, frame.size.width/2, frame.size.height);
        [_submit setTitle:@"确认" forState:UIControlStateNormal];
        [_submit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _submit.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
        _submit.showsTouchWhenHighlighted = YES;  //指定按钮被按下时发光
        [_submit setTitleColor:[UIColor colorFromHexRGB:@"4a7ebb"] forState:UIControlStateHighlighted];
        [self addSubview:_submit];
    }
    return self;
}
@end
