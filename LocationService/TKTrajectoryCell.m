//
//  TKTrajectoryCell.m
//  LocationService
//
//  Created by aJia on 2013/12/26.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "TKTrajectoryCell.h"

@implementation TKTrajectoryCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(!(self=[super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    _address = [[UILabel alloc] initWithFrame:CGRectZero];
	_address.backgroundColor = [UIColor clearColor];
    _address.textAlignment = NSTextAlignmentRight;
    _address.textColor = [UIColor blackColor];
	_address.highlightedTextColor = [UIColor whiteColor];
    _address.font = [UIFont fontWithName:DeviceFontName size:14];
    _address.numberOfLines=0;
    _address.lineBreakMode=NSLineBreakByWordWrapping;
	
	[self.contentView addSubview:_address];
    
    
    return self;
}
- (id) initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    CGRect rect=self.label.frame;
    rect.origin.x=0;
    self.label.frame=rect;
    
    NSString *txt=_address.text;
    CGFloat w=self.frame.size.width/2-5;
    CGRect r = CGRectInset(self.contentView.bounds, 10,10);
    r.origin.x=self.frame.size.width/2;
    if ([txt length]>0) {
        CGSize size=[txt textSize:[UIFont fontWithName:DeviceFontName size:14] withWidth:w];
        r.size=size;
        _address.frame=r;
    }else{
        r.size.width=w;
        r.size.height=self.label.frame.size.height;
        _address.frame=r;
    }
}
@end
