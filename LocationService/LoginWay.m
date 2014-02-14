//
//  LoginWay.m
//  LocationService
//
//  Created by aJia on 2013/12/17.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "LoginWay.h"
#import "UIColor+TPCategory.h"

@interface LoginWay (){
    UILabel *_lineLabel;
}
- (void)changeLoginWay:(id)sender;
@end

@implementation LoginWay
- (void)dealloc
{
    [super dealloc];
    [_lineLabel release];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image=[UIImage imageNamed:@"logintop.jpg"];
        CGRect r=self.bounds;
        r.size=image.size;
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:r];
        [imageView setImage:image];
        [self addSubview:imageView];
        [imageView release];
        
        r.origin.y=image.size.height-2;
        r.size.width=image.size.width/2;
        r.size.height=2;
        _lineLabel=[[UILabel alloc] initWithFrame:r];
        _lineLabel.backgroundColor=[UIColor colorFromHexRGB:@"4a7ebb"];
        [self addSubview:_lineLabel];
        
        r=self.bounds;
        r.size=image.size;
        r.size.width=image.size.width/2;
        UIButton *btn1=[UIButton buttonWithType:UIButtonTypeCustom];
        btn1.tag=100;
        btn1.frame=r;
         btn1.showsTouchWhenHighlighted = YES;  //指定按钮被按下时发光
        btn1.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
        [btn1 setTitle:@"普通登录" forState:UIControlStateNormal];
        [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn1 setTitleColor:[UIColor colorFromHexRGB:@"4a7ebb"] forState:UIControlStateHighlighted];
        [btn1 addTarget:self action:@selector(changeLoginWay:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btn1];
        
        r.origin.x=r.size.width;
        UIButton *btn2=[UIButton buttonWithType:UIButtonTypeCustom];
        btn2.tag=101;
        btn2.frame=r;
        btn2.showsTouchWhenHighlighted = YES;  //指定按钮被按下时发光
        btn2.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
        [btn2 setTitle:@"手机动态密码登录" forState:UIControlStateNormal];
        [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn2 setTitleColor:[UIColor colorFromHexRGB:@"4a7ebb"] forState:UIControlStateHighlighted];
        [btn2 addTarget:self action:@selector(changeLoginWay:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btn2];

        
        
    }
    return self;
}
- (void)changeLoginWay:(id)sender{
    UIButton *btn=(UIButton*)sender;
    CGRect r=_lineLabel.frame;
    r.origin.x=btn.tag==100?0:_lineLabel.frame.size.width;
    [UIView animateWithDuration:0.5f animations:^{
        _lineLabel.frame=r;
        int index=btn.tag-100;
        if (self.controlers&&[self.controlers respondsToSelector:@selector(selectedMenuItemIndex:)]) {
            [self.controlers performSelector:@selector(selectedMenuItemIndex:) withObject:[NSNumber numberWithInt:index]];
        }
    }];
}
- (void)setSelectedItemIndex:(int)index{
    int pos=100+index;
    UIButton *btn=(UIButton*)[self viewWithTag:pos];
    [self changeLoginWay:btn];
}
- (void)setWaySelectedItemIndex:(int)index{
    int pos=100+index;
    UIButton *btn=(UIButton*)[self viewWithTag:pos];
    CGRect r=_lineLabel.frame;
    r.origin.x=btn.tag==100?0:_lineLabel.frame.size.width;
    [UIView animateWithDuration:0.5f animations:^{
        _lineLabel.frame=r;
    }];
}
@end
