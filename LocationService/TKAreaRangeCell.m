//
//  TKAreaRangeCell.m
//  LocationService
//
//  Created by aJia on 2014/1/6.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import "TKAreaRangeCell.h"

@implementation TKAreaRangeCell
- (void)dealloc{
    [super dealloc];
    [_labLine release];
}
- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if(!(self=[super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    _startField=[[UITextField alloc] initWithFrame:CGRectZero];
    _startField.borderStyle=UITextBorderStyleRoundedRect;
    _startField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    _startField.delegate=self;
    [self.contentView addSubview:_startField];
    
    NSString *title=@"~";
    CGSize size=[title textSize:[UIFont fontWithName:DeviceFontName size:DeviceFontSize] withWidth:self.bounds.size.width];
    _labLine=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    _labLine.backgroundColor=[UIColor clearColor];
    _labLine.text=title;
    _labLine.textColor=[UIColor blackColor];
    _labLine.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    [self.contentView addSubview:_labLine];
    
    _endField=[[UITextField alloc] initWithFrame:CGRectZero];
    _endField.borderStyle=UITextBorderStyleRoundedRect;
    _endField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    _endField.delegate=self;
    [self.contentView addSubview:_endField];
    
    //_addButton=[UIButton buttonWithType:UIButtonTypeContactAdd];
    //_addButton.frame=CGRectMake(0, 0, 29, 29);
    //[self.contentView addSubview:_addButton];
    
    _button=[UIButton buttonWithType:UIButtonTypeContactAdd];
    _button.frame=CGRectMake(0, 0, 29, 29);
    [self.contentView addSubview:_button];
    
    _deleteButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _deleteButton.frame=CGRectMake(0, 0, 29, 29);
    [_deleteButton setImage:[UIImage imageNamed:@"error.png"] forState:UIControlStateNormal];
    [self.contentView addSubview:_deleteButton];
    
    self.contentView.backgroundColor=[UIColor colorFromHexRGB:@"fceada"];
	return self;
}

- (id) initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	return [self initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:reuseIdentifier];
}
#pragma mark - field delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    _startField.frame=CGRectMake(20, (self.frame.size.height-35)/2, 111, 35);
    
    CGRect r=_labLine.frame;
    r.origin.x=_startField.frame.origin.x+_startField.frame.size.width+5;
    r.origin.y=(self.frame.size.height-r.size.height)/2;
    _labLine.frame=r;
    
    r=_startField.frame;
    r.origin.x=_labLine.frame.origin.x+_labLine.frame.size.width+5;
    _endField.frame=r;
    
    r=_button.frame;
    r.origin.x=_endField.frame.origin.x+_endField.frame.size.width+10;
    r.origin.y=(self.frame.size.height-r.size.height)/2;
    _button.frame=r;
    
    _deleteButton.frame=r;
    /***
    r=_deleteButton.frame;
    r.origin.x=_button.frame.origin.x+_button.frame.size.width+5;
    r.origin.y=_button.frame.origin.y;
    _deleteButton.frame=r;
     ***/
    
}
@end
