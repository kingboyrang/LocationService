//
//  RegisterCheck.m
//  Wisdom
//
//  Created by aJia on 2013/10/31.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "RegisterCheck.h"
#import "NSString+TPCategory.h"
#import "UIColor+TPCategory.h"
@interface RegisterCheck ()
-(void)loadControls:(CGRect)frame;
-(void)buttonClickTap:(id)sender;
-(void)addButton:(CGFloat)leftx height:(CGFloat)h index:(NSInteger)tag;
@end

@implementation RegisterCheck
@synthesize hasRemember=_hasRemember;
-(void)dealloc{
    [super dealloc];
    [_lightLabel release],_lightLabel=nil;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _hasRemember=NO;
        self.backgroundColor=[UIColor clearColor];
        [self loadControls:frame];
    }
    return self;
}
-(void)loadControls:(CGRect)frame{
    CGFloat leftx=10;
    if (!_lightLabel) {
        NSString *title=@"记住密码,自动登录";
        CGSize size=[title textSize:[UIFont boldSystemFontOfSize:DeviceFontSize] withWidth:frame.size.width-leftx];
        _lightLabel=[[UILabel alloc] initWithFrame:CGRectMake(leftx,(frame.size.height-size.height)/2.0,size.width, size.height)];
        _lightLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
        _lightLabel.text=title;
        _lightLabel.backgroundColor=[UIColor clearColor];
        _lightLabel.textColor=[UIColor blackColor];
        
        leftx=_lightLabel.frame.size.width+5+_lightLabel.frame.origin.x;
        UISwitch *switchItem=[[UISwitch alloc] initWithFrame:CGRectMake(leftx, (frame.size.height-30)/2, 40, 30)];
        switchItem.on=YES;
        [switchItem addTarget:self action:@selector(buttonClickTap:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:switchItem];
        [switchItem release];
        
        
        NSString *str=@"注册>>";
        size=[str textSize:[UIFont boldSystemFontOfSize:DeviceFontSize] withWidth:frame.size.width];
        UILabel *labRegister=[[UILabel alloc] initWithFrame:CGRectMake(frame.size.width-size.width, (frame.size.height-size.height)/2.0, size.width, size.height)];
        labRegister.textColor=[UIColor colorFromHexRGB:@"5c1a8e"];
        labRegister.font=[UIFont boldSystemFontOfSize:DeviceFontSize];
        labRegister.text=str;
        labRegister.backgroundColor=[UIColor clearColor];
        [self addSubview:labRegister];
        
        _registerButton=[UIButton buttonWithType:UIButtonTypeCustom];
        _registerButton.frame=labRegister.frame;
        //_registerButton.alpha=0.0;
        [self addSubview:_registerButton];
        [labRegister release];
        
    }
    [self addSubview:_lightLabel];
    
}
-(void)addButton:(CGFloat)leftx height:(CGFloat)h index:(NSInteger)tag{
    UIImage *image=[UIImage imageNamed:@"checkbox.png"];
    UIImage *imageSelect=[UIImage imageNamed:@"checkbox-checked.png"];
    UIButton *btn1=[UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame=CGRectMake(leftx,(h-image.size.width)/2.0, image.size.width, image.size.height);
    btn1.tag=tag;
    [btn1 setImage:image forState:UIControlStateNormal];
    [btn1 setImage:imageSelect forState:UIControlStateSelected];
    [btn1 addTarget:self action:@selector(buttonClickTap:) forControlEvents:UIControlEventTouchUpInside];
    if (tag==101) {
        btn1.selected=YES;
    }
    [self addSubview:btn1];
}
-(void)buttonClickTap:(id)sender{
    UISwitch *btn=(UISwitch*)sender;
    _hasRemember=btn.on;
}
@end
