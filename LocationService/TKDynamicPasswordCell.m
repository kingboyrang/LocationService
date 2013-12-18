//
//  TKDynamicPasswordCell.m
//  LocationService
//
//  Created by aJia on 2013/12/17.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "TKDynamicPasswordCell.h"
#import "NSString+TPCategory.h"
#import "NSDate+TPCategory.h"
@interface TKDynamicPasswordCell (){
    int second;
}
- (void)timerFireMethod:(NSTimer*)theTimer;
@end

@implementation TKDynamicPasswordCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if(!(self=[super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
	
	_textField = [[UITextField alloc] initWithFrame:CGRectZero];
    _textField.borderStyle=UITextBorderStyleRoundedRect;
	_textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _textField.delegate=self;
    _textField.secureTextEntry=YES;
	[self.contentView addSubview:_textField];
    
    UIImage *leftImage=[UIImage imageNamed:@"bgbutton01.png"];
    UIEdgeInsets leftInsets = UIEdgeInsetsMake(5,10, 5, 10);
    leftImage=[leftImage resizableImageWithCapInsets:leftInsets resizingMode:UIImageResizingModeStretch];

    _button=[UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame=CGRectMake(0, 0, 80, 35);
    [_button setBackgroundImage:leftImage forState:UIControlStateNormal];
    [_button setTitle:@"免费获取" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _button.titleLabel.font=[UIFont boldSystemFontOfSize:DeviceFontSize];
    [self.contentView addSubview:_button];
    
    _label=[[UILabel alloc] initWithFrame:CGRectZero];
    _label.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    _label.textColor=[UIColor redColor];
    _label.backgroundColor=[UIColor clearColor];
    [self.contentView addSubview:_label];
    
    
	
	return self;
}

- (id) initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	return [self initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:reuseIdentifier];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)hasValue{
    NSString *title=[_textField.text Trim];
    if ([title length]>0) {
        return YES;
    }
    return NO;
}
- (void)startTimerWithTime:(NSString*)time{
    
   
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *fromdate=[format dateFromString:time];
    NSTimeZone *fromzone = [NSTimeZone systemTimeZone];
    NSInteger frominterval = [fromzone secondsFromGMTForDate: fromdate];
    _minDate = [fromdate  dateByAddingTimeInterval: frominterval];
    [format release];
    
    _maxDate=[_minDate dateByAddingMinutes:3];
    
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    NSLog(@"enddate=%@",localeDate);
    
    NSTimeInterval s=[_maxDate timeIntervalSinceDate:localeDate];
    
    //两个日期之间相隔多少秒
     second=(int)s;
     _label.text=[NSString stringWithFormat:@"%d秒",second];
    _button.enabled=NO;
     [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
}
- (void)timerFireMethod:(NSTimer*)theTimer
{
    second--;
    if (second==0) {
        [theTimer invalidate];
       _label.text=@"已超时!";
        _button.enabled=YES;
        _hasVeryFailed=YES;
    }else{
       _hasVeryFailed=NO;
       _label.text=[NSString stringWithFormat:@"%d秒",second];
    }
}
- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect r=CGRectInset(self.contentView.bounds, 10, 4);
    r.size.width=self.frame.size.width-r.origin.x*2-_button.frame.size.width-80;
	_textField.frame =r;
    
    r=_button.frame;
    r.origin.x=_textField.frame.size.width+_textField.frame.origin.x+5;
    r.origin.y=(self.frame.size.height-r.size.height)/2;
    _button.frame=r;
    
    r.origin.x+=r.size.width+5;
    r.size.width=self.frame.size.width-r.origin.x-10;
    r.size.height=20;
    r.origin.y=(self.frame.size.height-r.size.height)/2.0;
    _label.frame=r;
    
}

@end
