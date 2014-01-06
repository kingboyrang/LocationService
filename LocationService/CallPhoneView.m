//
//  CallPhoneView.m
//  LocationService
//
//  Created by aJia on 2014/1/5.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import "CallPhoneView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CallPhoneView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.borderColor=[UIColor colorFromHexRGB:@"4f81bd"].CGColor;
        self.layer.borderWidth=2.0;
        self.layer.cornerRadius=5.0;
        
        self.backgroundColor=[UIColor whiteColor];
        
        _labPhone=[[UILabel alloc] initWithFrame:CGRectMake(5, 5, frame.size.width-10, 20)];
        _labPhone.textColor=[UIColor blackColor];
        _labPhone.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
        _labPhone.backgroundColor=[UIColor clearColor];
        _labPhone.textAlignment=NSTextAlignmentCenter;
        [self addSubview:_labPhone];
        
        CGFloat topY=20+10;
        CGFloat leftX=(frame.size.width-(16*2+2*2+100))/2;
        
        UILabel *lab1=[[UILabel alloc] initWithFrame:CGRectMake(leftX, topY,16, 40)];
        lab1.textColor=[UIColor blackColor];
        lab1.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
        lab1.backgroundColor=[UIColor clearColor];
        lab1.text=@"亲情";
        [self addSubview:lab1];
        [lab1 release];
        
        leftX+=16+2;
        _switchPhone=[[SimpleSwitch alloc] initWithFrame:CGRectMake(leftX, (40-25)/2+topY, 100, 25)];
        _switchPhone.titleOn = @"亲情";
        _switchPhone.titleOff = @"监听";
        _switchPhone.on = YES;
        _switchPhone.knobColor = [UIColor colorFromHexRGB:@"bfd5ff"];
        _switchPhone.fillColor = [UIColor colorFromHexRGB:@"3c6eb1"];
        [_switchPhone addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_switchPhone];
        
        leftX+=100+2;
        UILabel *lab2=[[UILabel alloc] initWithFrame:CGRectMake(leftX, topY,16, 40)];
        lab2.textColor=[UIColor blackColor];
        lab2.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
        lab2.backgroundColor=[UIColor clearColor];
        lab2.text=@"监听";
        [self addSubview:lab2];
        [lab2 release];
        
        topY+=40+5;
        
        _button=[UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame=CGRectMake(0, topY, frame.size.width, 44);
        [_button setTitle:@"拨打" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _button.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
        _button.showsTouchWhenHighlighted = YES;  //指定按钮被按下时发光
        [_button setTitleColor:[UIColor colorFromHexRGB:@"4a7ebb"] forState:UIControlStateHighlighted];
        [_button addTarget:self action:@selector(buttonCallClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
        
        CGRect r=self.frame;
        r.size.height=topY+44;
        self.frame=r;
        
    }
    return self;
}
- (void)setDataWithShipPhone:(NSString*)phone trajectoryTel:(NSString*)tel{
    self.shipPhone=phone;
    self.trajectoryPhone=tel;
    
    if (_switchPhone.on) {
        _labPhone.text=phone;
    }else{
       _labPhone.text=tel;
    }
}
-(void)valueChanged:(id)sender
{
    if (_switchPhone.on) {
        _labPhone.text=self.shipPhone;
    }else{
        _labPhone.text=self.trajectoryPhone;
    }
}
//拨打电话
- (void)buttonCallClick{
    if(self.controlers&&[self.controlers respondsToSelector:@selector(callWithPhone:)])
    {
        [self.controlers performSelector:@selector(callWithPhone:) withObject:self.labPhone.text];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
