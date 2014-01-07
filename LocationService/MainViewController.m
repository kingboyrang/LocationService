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
#import "Account.h"
#import "ServiceHelper.h"
#import "SupervisionPerson.h"
#import "PersonTrajectoryViewController.h"
//获取设备的物理高度

@interface MainViewController ()
- (void)updateSelectedStatus:(int)selectTag lastIndex:(int)prevIndex;
- (void)_resizeView:(BOOL)show;
- (void)loadingReadCountWithId:(NSString*)personId;
- (void)updateInfoUI:(int)total;
@end

@implementation MainViewController
-(void)dealloc{
    [super dealloc];
    [_tabbarView release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
         [self.tabBar setHidden:YES];
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTrajectoryNotifice:) name:@"trajectTarget" object:nil];
   
    [self _initViewController];//初始化子控制器
    [self _initTabbarView];//创建自定义tabBar
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)receiveTrajectoryNotifice:(NSNotification*)notifice{
    NSDictionary *dic=[notifice userInfo];
    SupervisionPerson *entity=[dic objectForKey:@"Entity"];
    [self loadingReadCountWithId:entity.ID];//加载未读信息总数
}
- (void)loadingReadCountWithId:(NSString*)personId{
    Account *acc=[Account unarchiverAccount];
    NSMutableArray *params=[NSMutableArray array];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:acc.WorkNo,@"workno", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:personId,@"personid", nil]];
    
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.methodName=@"GetNotReadCounts";
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.soapParams=params;
    
    [ServiceHelper asynService:args success:^(ServiceResult *result) {
        BOOL boo=NO;
        if (result.hasSuccess) {
            NSDictionary *dic=[result json];
            int total=[[dic objectForKey:@"Result"] intValue];
            if (total>0) {
                boo=YES;
                [self updateInfoUI:total];
            }
        }
        if (!boo) {
            [self updateInfoUI:0];
        }
        
    } failed:^(NSError *error, NSDictionary *userInfo) {
        [self updateInfoUI:0];
    }];
}
- (void)updateInfoUI:(int)total{
   
    if (total==0) {
        if ([[_tabbarView viewWithTag:900] isKindOfClass:[UIButton class]]) {
            UIButton *btn=(UIButton*)[_tabbarView viewWithTag:900];
            [btn removeFromSuperview];
            return;
        }
    }
    
    NSString *title=[NSString stringWithFormat:@"%d",total];
    CGSize size=[title textSize:[UIFont fontWithName:DeviceFontName size:DeviceFontSize] withWidth:DeviceWidth];
    CGRect r=CGRectZero;
    r.origin.y=0;
    r.size=size;
    r.origin.x=DeviceWidth*4/5-size.width;
    
    if ([[_tabbarView viewWithTag:900] isKindOfClass:[UIButton class]]) {
        UIButton *btn=(UIButton*)[_tabbarView viewWithTag:900];
        btn.frame=r;
        [btn setTitle:title forState:UIControlStateNormal];
        return;
    }

   
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame=r;
    btn.tag=900;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor colorFromHexRGB:@"4f81bd"]];
    btn.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    [_tabbarView addSubview:btn];
    
}
#pragma mark - UI
//初始化子控制器
- (void)_initViewController {
    
    IndexViewController *viewController1=[[[IndexViewController alloc] init] autorelease];
    BasicNavigationController *nav1=[[[BasicNavigationController alloc] initWithRootViewController:viewController1] autorelease];
    nav1.delegate=self;

   PersonTrajectoryViewController *viewController2=[[[PersonTrajectoryViewController alloc] init] autorelease];
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
    _tabbarView.backgroundColor=[UIColor colorFromHexRGB:@"f6f6f6"];
    _tabbarView.autoresizesSubviews=YES;
    _tabbarView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_tabbarView];
    
    /***
    UIImage *image=[UIImage imageNamed:@"logintop.jpg"];
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [imageView setImage:image];
    [_tabbarView addSubview:imageView];
     ***/

    
    
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
