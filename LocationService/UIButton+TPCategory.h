//
//  UIButton+TPCategory.h
//  LocationService
//
//  Created by aJia on 2013/12/18.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (TPCategory)
+ (id)backButtonTarget:(id)sender action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
@end
