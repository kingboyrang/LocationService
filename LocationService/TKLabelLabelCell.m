//
//  TKLabelLabelCell.m
//  LocationService
//
//  Created by aJia on 2014/1/5.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import "TKLabelLabelCell.h"

@implementation TKLabelLabelCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(!(self=[super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    _showLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_showLabel.backgroundColor = [UIColor clearColor];
    _showLabel.textColor = [UIColor grayColor];
	_showLabel.highlightedTextColor = [UIColor whiteColor];
    _showLabel.font = [UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    _showLabel.numberOfLines = 0;
    _showLabel.lineBreakMode=NSLineBreakByWordWrapping;
	[self.contentView addSubview:_showLabel];
    
    
    return self;
}
- (id) initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	return self;
}


- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect r=self.label.frame;
    r.origin.y=5;
    self.label.frame=r;
    
    r.origin.x=self.label.frame.origin.x+self.label.frame.size.width+2;
    r.size.width=self.frame.size.width-5-r.origin.x;
    CGSize size=[_showLabel.text textSize:[UIFont fontWithName:DeviceFontName size:DeviceFontSize] withWidth:r.size.width];
    r.size=size;
    _showLabel.frame=r;
}
@end
