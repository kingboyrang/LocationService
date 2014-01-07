//
//  TKTrajectoryPaoCell.m
//  LocationService
//
//  Created by aJia on 2014/1/5.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import "TKTrajectoryPaoCell.h"

@implementation TKTrajectoryPaoCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(!(self=[super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    _showLabel1 = [[UILabel alloc] initWithFrame:CGRectZero];
	_showLabel1.backgroundColor = [UIColor clearColor];
    _showLabel1.textColor = [UIColor grayColor];
	_showLabel1.highlightedTextColor = [UIColor whiteColor];
    _showLabel1.font = [UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    _showLabel1.numberOfLines = 0;
    _showLabel1.lineBreakMode=NSLineBreakByWordWrapping;
	[self.contentView addSubview:_showLabel1];
    
    _label2 = [[UILabel alloc] initWithFrame:CGRectZero];
	_label2.backgroundColor = [UIColor clearColor];
    _label2.textColor = [UIColor blackColor];
	_label2.highlightedTextColor = [UIColor whiteColor];
    _label2.font = [UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    _label2.numberOfLines = 0;
    _label2.lineBreakMode=NSLineBreakByWordWrapping;
	[self.contentView addSubview:_label2];
    
    
    _showLabel2 = [[UILabel alloc] initWithFrame:CGRectZero];
	_showLabel2.backgroundColor = [UIColor clearColor];
    _showLabel2.textColor = [UIColor grayColor];
	_showLabel2.highlightedTextColor = [UIColor whiteColor];
    _showLabel2.font = [UIFont fontWithName:DeviceFontName size:DeviceFontSize];//32*20
    _showLabel2.numberOfLines = 0;
    _showLabel2.lineBreakMode=NSLineBreakByWordWrapping;
	[self.contentView addSubview:_showLabel2];
    
    
    
    return self;
}
- (id) initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	return self;
}


- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect r=self.label.frame;
    r.origin.x=self.frame.size.width/2+self.label.frame.origin.x;
    _label2.frame=r;
    
    r.origin.x=self.label.frame.origin.x+self.label.frame.size.width+2;
    r.size.width=_label2.frame.origin.x-2-r.origin.x;
    CGSize size=[_showLabel1.text textSize:[UIFont fontWithName:DeviceFontName size:DeviceFontSize] withWidth:r.size.width];
    r.size.height=size.height;
    _showLabel1.frame=r;
    
    r.origin.x=_label2.frame.origin.x+_label2.frame.size.width+2;
    r.size.width=self.frame.size.width-5-r.origin.x;
    size=[_showLabel2.text textSize:[UIFont fontWithName:DeviceFontName size:DeviceFontSize] withWidth:r.size.width];
    r.size.height=size.height;
    _showLabel2.frame=r;
    //_showLabel.frame=r;
}
@end