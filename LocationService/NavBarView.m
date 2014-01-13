//
//  NavBarView.m
//  LocationService
//
//  Created by aJia on 2013/12/23.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "NavBarView.h"
#import "AppUI.h"
#import "UIButton+TPCategory.h"
@implementation NavBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image=[UIImage imageNamed:@"logintop.jpg"];
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        [imageView setImage:image];
        [self addSubview:imageView];
        [imageView release];
    }
    return self;
}
- (void)setNavBarTitle:(NSString*)title{
    if ([[self viewWithTag:200] isKindOfClass:[UILabel class]]) {
        UILabel *label=(UILabel*)[self viewWithTag:200];
        //CGSize size=[title textSize:[UIFont fontWithName:@"Helvetica-Bold" size:16] withWidth:self.bounds.size.width];
        CGSize size=[title textSize:[UIFont boldSystemFontOfSize:16] withWidth:self.bounds.size.width];
        CGRect r=label.frame;
        r.size=size;
        label.frame=r;
        label.text=title;
        return;
    }
    UILabel *fx=[AppUI labelTitle:title frame:self.bounds];
    fx.tag=200;
    CGRect r=fx.frame;
    r.origin.x=(self.bounds.size.width-r.size.width)/2.0;
    r.origin.y=(self.bounds.size.height-r.size.height)/2.0;
    fx.frame=r;
    [self addSubview:fx];
}
- (void)setBackButtonWithTarget:(id)target action:(SEL)action{
    if (![self viewWithTag:201]) {
        UIButton *btn=[UIButton backButtonTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        btn.tag=201;
        CGRect r=btn.frame;
        r.origin.x=5;
        r.origin.y=(self.bounds.size.height-r.size.height)/2;
        btn.frame=r;
        [self addSubview:btn];
    }
   
}
- (void)setMonitorButtonWithTarget:(id)target action:(SEL)action{
    if (![self viewWithTag:204]) {
        UIImage *image=[UIImage imageNamed:@"ico14.png"];
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag=204;
        btn.frame=CGRectMake(self.bounds.size.width-5-image.size.width, (self.bounds.size.height-image.size.height)/2.0, image.size.width, image.size.height);
        [btn setBackgroundImage:image forState:UIControlStateNormal];
        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
   
    
}
- (void)setTargetButtonWithTarget:(id)target action:(SEL)action{
    if (![self viewWithTag:203]) {
        UIImage *image=[UIImage imageNamed:@"ico13.png"];
        CGFloat leftX=self.bounds.size.width-(40+5+image.size.width);
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag=203;
        btn.frame=CGRectMake(leftX, (self.bounds.size.height-image.size.height)/2.0, image.size.width, image.size.height);
        [btn setBackgroundImage:image forState:UIControlStateNormal];
        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
}
- (void)setCompassButtonWithTarget:(id)target action:(SEL)action{
    if (![self viewWithTag:202]) {
        UIImage *image=[UIImage imageNamed:@"ico12.png"];
        CGFloat leftX=self.bounds.size.width-(40+5+35+5+image.size.width);
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag=202;
        btn.frame=CGRectMake(leftX, (self.bounds.size.height-image.size.height)/2.0, image.size.width, image.size.height);
        [btn setBackgroundImage:image forState:UIControlStateNormal];
        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
}
- (void)removeSubviews{
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[UIImageView class]]) {continue;}
        [v removeFromSuperview];
    }
}
@end
