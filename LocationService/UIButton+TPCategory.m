//
//  UIButton+TPCategory.m
//  LocationService
//
//  Created by aJia on 2013/12/18.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "UIButton+TPCategory.h"

@implementation UIButton (TPCategory)
+ (id)backButtonTarget:(id)sender action:(SEL)action forControlEvents:(UIControlEvents)controlEvents{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image=[UIImage imageNamed:@"leftico.png"];
    btn.frame=CGRectMake(0, 0, image.size.width, image.size.height);
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    [btn addTarget:sender action:action forControlEvents:controlEvents];
    return btn;
}
@end
