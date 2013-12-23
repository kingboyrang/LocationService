//
//  MainViewController.m
//  active
//
//  Created by 徐 军 on 13-8-20.
//  Copyright (c) 2013年 chenjin. All rights reserved.
//

#import "MainViewController.h"
#import "UIColor+TPCategory.h"
#import "UIImage+TPCategory.h"
#import "BasicNavigationController.h"
#import "IndexViewController.h"
#import "MoreViewController.h"
//获取设备的物理高度

@interface MainViewController ()
- (void)updateSelectedStatus:(int)selectTag lastIndex:(int)prevIndex;
- (void)_resizeView:(BOOL)show;
@end

@implementation MainViewController
-(void)dealloc{
    [super dealloc];
    [_tabbarView release];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
         [self.tabBar setHidden:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    [self _initViewController];//初始化子控制器
    [self _initTabbarView];//创建自定义tabBar
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UI
//初始化子控制器
- (void)_initViewController {
    
    IndexViewController *viewController1=[[[IndexViewController alloc] init] autorelease];
    BasicNavigationController *nav1=[[[BasicNavigationController alloc] initWithRootViewController:viewController1] autorelease];
    nav1.delegate=self;

   UIViewController *viewController2=[[[UIViewController alloc] init] autorelease];
     viewController2.view.backgroundColor=[UIColor whiteColor];
    BasicNavigationController *nav2=[[[BasicNavigationController alloc] initWithRootViewController:viewController2] autorelease];
    nav2.delegate=self;
    
   UIViewController *viewController3=[[[UIViewController alloc] init] autorelease];
     viewController3.view.backgroundColor=[UIColor whiteColor];
     BasicNavigationController *nav3=[[[BasicNavigationController alloc] initWithRootViewController:viewController3] autorelease];
     nav3.delegate=self;
    
    UIViewController *viewController4=[[[UIViewController alloc] init] autorelease];
    viewController4.view.backgroundColor=[UIColor whiteColor];
    BasicNavigationController *nav4=[[[BasicNavigationController alloc] initWithRootViewController:viewController4] autorelease];
    nav4.delegate=self;
    
    MoreViewController *viewController5=[[[MoreViewController alloc] init] autorelease];
    BasicNavigationController *nav5=[[[BasicNavigationController alloc] initWithRootViewController:viewController5] autorelease];
    nav5.delegate=self;
    
    self.viewControllers = [NSArray arrayWithObjects:nav1,nav2,nav3,nav4,nav5, nil];
}

//创建自定义tabBar
- (void)_initTabbarView {
    _tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, DeviceHeight-TabHeight, DeviceWidth, TabHeight)];
    _tabbarView.backgroundColor=[UIColor redColor];
    _tabbarView.autoresizesSubviews=YES;
    _tabbarView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_tabbarView];
    NSArray *backgroud = @[@"ico01.png",@"ico02.png",@"ico03.png",@"ico04.png",@"ico05.png"];
    NSArray *heightBackground= @[@"ico01f.png",@"ico02f.png",@"ico03f.png",@"ico04f.png",@"ico05f.png"];
    
       //总数
    _barButtonItemCount=[backgroud count];
    //
    _prevSelectIndex=0;
    
    for (int i=0; i<backgroud.count; i++) {
        NSString *backImage = backgroud[i];
        NSString *heightImage = heightBackground[i];
        UIImage *normal=[UIImage imageNamed:backImage];
        UIImage *hight=[UIImage imageNamed:heightImage];
        
        CGFloat leftX=i*normal.size.width;
        UIButton *button =[[UIButton alloc] initWithFrame:CGRectMake(leftX,TabHeight-normal.size.height, normal.size.width, normal.size.height)];
        [button setBackgroundImage:normal forState:UIControlStateNormal];
        [button setBackgroundImage:hight forState:UIControlStateSelected];
        button.tag = 100+i;
        if (i==0) {
            button.selected=YES;
        }
        [button addTarget:self action:@selector(selectedTab:) forControlEvents:UIControlEventTouchUpInside];
        
       [_tabbarView addSubview:button];
        [button release];
    }
    
}

#pragma mark - actions
//tab 按钮的点击事件
- (void)selectedTab:(UIButton *)button {

    button.selected=YES;
    if (_prevSelectIndex!=button.tag-100) {
        UIButton *btn=(UIButton*)[_tabbarView viewWithTag:100+_prevSelectIndex];
        btn.selected=NO;
        _prevSelectIndex=button.tag-100;
    }
    self.selectedIndex = button.tag-100;
    
}
- (void)setSelectedItemIndex:(int)index{
    int pos=100+index;
    UIButton *btn=(UIButton*)[_tabbarView viewWithTag:pos];
    [self selectedTab:btn];
}
- (void)showTabbar:(BOOL)show{
    CGRect r=_tabbarView.frame;
    if (show) {
        r.origin.x=0;
    }else{
       r.origin.x=-DeviceWidth;
    }
    [UIView animateWithDuration:0.35 animations:^{
        _tabbarView.frame=r;
        
    }];
    [self _resizeView:show];
    
}
- (void)_resizeView:(BOOL)show {
    for (UIView *subView in self.view.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UITransitionView")]) {
            CGRect r=subView.frame;
            r.size.height = DeviceHeight;
            
            subView.frame=r;
            /***
            CGRect r=subView.frame;
            if (show) {
                r.size.height = DeviceHeight-TabHeight;
            }else {
                r.size.height = DeviceHeight;
            }
            subView.frame=r;
            //break;
             ***/
        }
    }
}
#pragma mark - UINavigationController delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.hidesBottomBarWhenPushed=YES;
    //导航控制器子控制器的个数
    int count = navigationController.viewControllers.count;
    if (count == 1) {
        [self showTabbar:YES];
    }else if (count== 2) {
        [self showTabbar:NO];
    }
    
    if ( viewController == [navigationController.viewControllers objectAtIndex:0]) {
        [navigationController setNavigationBarHidden:YES animated:animated];
    } else if ( [navigationController isNavigationBarHidden] ) {
       // [navigationController setNavigationBarHidden:NO animated:animated];
    }

}

#pragma mark 私有方法
-(void)updateSelectedStatus:(int)selectTag lastIndex:(int)prevIndex{
    UIButton *btn=(UIButton*)[_tabbarView viewWithTag:100+prevIndex];
    btn.selected=NO;
    _prevSelectIndex=selectTag;
}
@end
