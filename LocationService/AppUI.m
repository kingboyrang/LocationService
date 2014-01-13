//
//  AppUI.m
//  Wisdom
//
//  Created by aJia on 2013/10/29.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "AppUI.h"
#import "NSString+TPCategory.h"
@implementation AppUI
+(UILabel*)labelTitle:(NSString*)title frame:(CGRect)rect{
    CGSize size=[title textSize:[UIFont boldSystemFontOfSize:16] withWidth:rect.size.width];
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, size.width,size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.font=[UIFont boldSystemFontOfSize:16];
    label.text=title;
    label.textColor=[UIColor blackColor];
    
    return [label autorelease];
}
+(FXLabel*)showLabelTitle:(NSString*)title frame:(CGRect)rect{
    CGSize size=[title textSize:[UIFont fontWithName:@"Helvetica-Bold" size:16] withWidth:rect.size.width];
    FXLabel *secondLabel = [[FXLabel alloc] init];
    secondLabel.frame = CGRectMake(rect.origin.x,rect.origin.y, size.width, size.height);
    secondLabel.backgroundColor = [UIColor clearColor];
    secondLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    secondLabel.text = title;
    secondLabel.textAlignment=NSTextAlignmentCenter;
    secondLabel.textColor = [UIColor blackColor];
    secondLabel.shadowColor =[UIColor colorWithWhite:0.0f alpha:0.5f];
    secondLabel.shadowOffset = CGSizeMake(0.0f, 5.0f);
    secondLabel.shadowBlur = 5.0f;
    return [secondLabel autorelease];
}
+(FXLabel*)barButtonItemTitle:(NSString*)title frame:(CGRect)rect{
    CGSize size=[title textSize:[UIFont fontWithName:@"Helvetica-Bold" size:16] withWidth:rect.size.width];
    FXLabel *secondLabel = [[FXLabel alloc] init];
    secondLabel.frame = CGRectMake(rect.origin.x,rect.origin.y, size.width, size.height);
    secondLabel.backgroundColor = [UIColor clearColor];
    secondLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    secondLabel.text = title;
    secondLabel.textAlignment=NSTextAlignmentCenter;
    secondLabel.textColor = [UIColor whiteColor];
    secondLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    secondLabel.shadowOffset = CGSizeMake(0.0f, 0.0f);
    secondLabel.shadowBlur = 5.0f;
    return [secondLabel autorelease];
}
+(UIButton*)createhighlightButtonWithTitle:(NSString*)title frame:(CGRect)frame{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=frame;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    btn.showsTouchWhenHighlighted = YES;  //指定按钮被按下时发光
    [btn setTitleColor:[UIColor colorFromHexRGB:@"4a7ebb"] forState:UIControlStateHighlighted];
    return btn;
}
@end
