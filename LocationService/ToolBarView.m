//
//  ToolBarView.m
//  LocationService
//
//  Created by aJia on 2014/1/13.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import "ToolBarView.h"

@interface ToolBarView (){
   int _prevSelectIndex;
}
- (void)loadControls;
@end

@implementation ToolBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadControls];
        
    }
    return self;
}
- (void)loadControls{
    NSArray *heightBackground= @[@"ico01.png",@"ico02.png",@"ico03.png",@"ico04.png",@"ico05.png"];
    NSArray *backgroud= @[@"ico01f.png",@"ico02f.png",@"ico03f.png",@"ico04f.png",@"ico05f.png"];
    
   
    //默认第一项选中
    self.selectedIndex=0;
     _prevSelectIndex=0;
    for (int i=0; i<backgroud.count; i++) {
        NSString *backImage = backgroud[i];
        NSString *heightImage = heightBackground[i];
        UIImage *normal=[UIImage imageNamed:backImage];
        UIImage *hight=[UIImage imageNamed:heightImage];
        
        CGFloat leftX=i*normal.size.width;
        UIButton *button =[[UIButton alloc] initWithFrame:CGRectMake(leftX,0, normal.size.width, normal.size.height)];
        [button setBackgroundImage:normal forState:UIControlStateNormal];
        [button setBackgroundImage:hight forState:UIControlStateSelected];
        button.tag = 100+i;
        if (i==0) {
            button.selected=YES;
        }
        [button addTarget:self action:@selector(selectedTab:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
        [button release];
    }
}
//tab 按钮的点击事件
- (void)selectedTab:(UIButton *)button {
    
    //如果未选中监管目标则return
    if (self.controls&&[self.controls respondsToSelector:@selector(selectedTrajectoryIndex:)]) {
         int position=button.tag-100;
        BOOL boo=(BOOL)[self.controls performSelector:@selector(selectedTrajectoryIndex:) withObject:[NSNumber numberWithInt:position]];
        if (!boo) {
            return;
        }
    }

    button.selected=YES;
    if (_prevSelectIndex!=button.tag-100) {
        UIButton *btn=(UIButton*)[self viewWithTag:100+_prevSelectIndex];
        btn.selected=NO;
        _prevSelectIndex=button.tag-100;
    }
    self.selectedIndex = button.tag-100;
    
    if (self.controls&&[self.controls respondsToSelector:@selector(setSelectedTabIndex:)]) {
        [self.controls performSelector:@selector(setSelectedTabIndex:) withObject:[NSNumber numberWithInt:self.selectedIndex]];
    }

    
}
- (void)setSelectedItemIndex:(int)index{
    int pos=100+index;
    UIButton *btn=(UIButton*)[self viewWithTag:pos];
    [self selectedTab:btn];
}

@end
