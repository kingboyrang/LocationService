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
@end
