//
//  TKLoginButtonCell.m
//  LocationService
//
//  Created by aJia on 2013/12/17.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "TKLoginButtonCell.h"
#import "UIColor+TPCategory.h"
@implementation TKLoginButtonCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if(!(self=[super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
	
	

    UIImage *leftImage=[UIImage imageNamed:@"bgbutton01.png"];
    UIEdgeInsets leftInsets = UIEdgeInsetsMake(5,10, 5, 10);
    leftImage=[leftImage resizableImageWithCapInsets:leftInsets resizingMode:UIImageResizingModeStretch];
    
    _button=[UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame=CGRectMake(10, 10, DeviceWidth-20, 40);
    [_button setBackgroundImage:leftImage forState:UIControlStateNormal];
    [_button setTitle:@"登录" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     _button.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
      [self.contentView addSubview:_button];
    
    
   
        /***
    self.textLabel.text=@"登录";
    self.textLabel.textColor=[UIColor whiteColor];
    self.textLabel.font=[UIFont boldSystemFontOfSize:DeviceFontSize];
    self.textLabel.textAlignment=NSTextAlignmentCenter;
    self.backgroundColor=[UIColor colorFromHexRGB:@"0057ae"];
    ***/
	
	return self;
}

- (id) initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	return [self initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:reuseIdentifier];
}
/***
- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect r=_button.frame;
    r.origin.x=(self.frame.size.width-r.size.width)/2.0;
    r.origin.y=(self.frame.size.height-r.size.height)/2;
    _button.frame=r;
    
}
***/
@end
