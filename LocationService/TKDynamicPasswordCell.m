//
//  TKDynamicPasswordCell.m
//  LocationService
//
//  Created by aJia on 2013/12/17.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "TKDynamicPasswordCell.h"
#import "NSString+TPCategory.h"
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
- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect r=CGRectInset(self.contentView.bounds, 10, 4);
    r.size.width=self.frame.size.width-r.origin.x*2-_button.frame.size.width-80;
	_textField.frame =r;
    
    r=_button.frame;
    r.origin.x=_textField.frame.size.width+_textField.frame.origin.x+5;
    r.origin.y=(self.frame.size.height-r.size.height)/2;
    _button.frame=r;
    
}

@end
