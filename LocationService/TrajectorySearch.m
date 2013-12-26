//
//  TrajectorySearch.m
//  LocationService
//
//  Created by aJia on 2013/12/26.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "TrajectorySearch.h"
#import "NSDate+TPCategory.h"
@interface TrajectorySearch (){
    CGFloat leftX;
   
}

@end

@implementation TrajectorySearch
- (void)dealloc{
    [super dealloc];
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.backgroundColor=[UIColor colorFromHexRGB:@"e5e1e1"];
        
        NSString *title=@"时间";
        CGSize size=[title textSize:[UIFont fontWithName:DeviceFontName size:DeviceFontSize] withWidth:frame.size.width];
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(5, (frame.size.height-size.height)/2,size.width, size.height)];
        label.text=title;
        label.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
        label.backgroundColor=[UIColor clearColor];
        label.textColor=[UIColor blackColor];
        leftX=label.frame.origin.x+size.width+5;
        [self addSubview:label];
        [label release];
        
        NSDate *time=[NSDate date];
        
        _startCalendar = [[CVUICalendar alloc] initWithFrame:CGRectZero];
        _startCalendar.popoverText.popoverTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _startCalendar.popoverText.popoverTextField.borderStyle=UITextBorderStyleRoundedRect;
        _startCalendar.popoverText.popoverTextField.backgroundColor = [UIColor whiteColor];
        _startCalendar.popoverText.popoverTextField.font = [UIFont fontWithName:DeviceFontName size:DeviceFontSize];
        _startCalendar.popoverText.popoverTextField.placeholder=@"开始时间";
        [_startCalendar.dateForFormat setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        _startCalendar.datePicker.maximumDate=[NSDate date];
        _startCalendar.popoverText.popoverTextField.text=[[time dateByAddingDays:-2] stringWithFormat:@"yyyy/MM/dd HH:mm:ss"];
        [self addSubview:_startCalendar];
        
        
        _endCalendar = [[CVUICalendar alloc] initWithFrame:CGRectZero];
        _endCalendar.popoverText.popoverTextField.borderStyle=UITextBorderStyleRoundedRect;
        _endCalendar.popoverText.popoverTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _endCalendar.popoverText.popoverTextField.backgroundColor = [UIColor whiteColor];
        _endCalendar.popoverText.popoverTextField.font = [UIFont fontWithName:DeviceFontName size:DeviceFontSize];
         _endCalendar.popoverText.popoverTextField.placeholder=@"结束时间";
        _endCalendar.datePicker.maximumDate=[NSDate date];
        [_endCalendar.dateForFormat setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        _endCalendar.popoverText.popoverTextField.text=[time stringWithFormat:@"yyyy/MM/dd HH:mm:ss"];
        [self addSubview:_endCalendar];
        
        UIImage *leftImage=[UIImage imageNamed:@"bgbutton01.png"];
        UIEdgeInsets leftInsets = UIEdgeInsetsMake(5,10, 5, 10);
        leftImage=[leftImage resizableImageWithCapInsets:leftInsets resizingMode:UIImageResizingModeStretch];
        
        _button=[UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame=CGRectMake(frame.size.width-85, (frame.size.height-40)/2, 80, 40);
        [_button setBackgroundImage:leftImage forState:UIControlStateNormal];
        [_button setTitle:@"搜索" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _button.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
        [self addSubview:_button];
        
        
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat total=_button.frame.origin.x-leftX-5;
    _startCalendar.frame=CGRectMake(leftX, (self.frame.size.height-35-5-35)/2, total, 35);
   
    
   CGRect r=_startCalendar.frame;
    r.origin.y+=r.size.height+5;
    _endCalendar.frame=r;
}
@end
