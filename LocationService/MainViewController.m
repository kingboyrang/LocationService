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
#import "CallTrajectoryViewController.h"
#import "TrajectoryMessageController.h"
#import "UIImage+TPCategory.h"
#import <QuartzCore/QuartzCore.h>
//获取设备的物理高度

@interface MainViewController ()
- (void)updateSelectedStatus:(int)selectTag lastIndex:(int)prevIndex;
- (void)_resizeView:(BOOL)show;
- (void)loadingReadCountWithId:(NSString*)personId;
- (void)updateInfoUI:(int)total;
- (void)showRecordMessage:(BOOL)show;//显示记录总数
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
   
    if(self.Entity&&self.Entity.ID&&[self.Entity.ID length]>0)
    {
        [self loadingReadCountWithId:self.Entity.ID];//加载未读信息总数
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTrajectoryNotifice:) name:@"trajectTarget" object:nil];
   
    [self _initViewController];//初始化子控制器
    [self _initTabbarView];//创建自定义tabBar
    
    _recordView=[[RecordView alloc] initWithFrame:CGRectMake(DeviceWidth*4/5-DeviceWidth/10, DeviceHeight-27-20, 27, 27)];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)receiveTrajectoryNotifice:(NSNotification*)notifice{
    NSDictionary *dic=[notifice userInfo];
    id v=[dic objectForKey:@"Entity"];
    if ([v isKindOfClass:[SupervisionPerson class]]) {
        self.Entity=[dic objectForKey:@"Entity"];
    }else{
        self.Entity=nil;
    }
    if (self.Entity&&self.Entity.ID&&[self.Entity.ID length]>0) {
        [self loadingReadCountWithId:self.Entity.ID];//加载未读信息总数
    }else{
        [self updateInfoUI:0];
    }
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
   
    [_recordView setRecordCount:total];
    if (_recordView.hasValue) {
       
        if (![self.view.subviews containsObject:_recordView]) {
            CGRect r=_recordView.frame;
            CGFloat w=DeviceWidth/5;
            if (r.size.width>w/2) {
                r.origin.x=DeviceWidth/3+(w-r.size.width)/2+5;
            }else{
                r.origin.x=DeviceWidth*4/5-DeviceWidth/10;
            }
            _recordView.frame=r;
            [self.view addSubview:_recordView];
        }
    }else{
        if ([self.view.subviews containsObject:_recordView]) {
            [_recordView removeFromSuperview];
        }
    }
    
}
- (void)showRecordMessage:(BOOL)show{
    if (show) {
        if (_recordView.hasValue) {
            if (![self.view.subviews containsObject:_recordView]) {
                [self.view addSubview:_recordView];
            }
        }
    }else{
        if ([self.view.subviews containsObject:_recordView]) {
            [_recordView removeFromSuperview];
        }
    }
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
    
    CallTrajectoryViewController *viewController3=[[[CallTrajectoryViewController alloc] init] autorelease];
     BasicNavigationController *nav3=[[[BasicNavigationController alloc] initWithRootViewController:viewController3] autorelease];
     nav3.delegate=self;
    
    TrajectoryMessageController *viewController4=[[[TrajectoryMessageController alloc] init] autorelease];
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
    
    NSArray *heightBackground= @[@"ico01.png",@"ico02.png",@"ico03.png",@"ico04.png",@"ico05.png"];
    NSArray *backgroud= @[@"ico01f.png",@"ico02f.png",@"ico03f.png",@"ico04f.png",@"ico05f.png"];
    
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

    //1,2,3  未选中监管目标，则不可以点击
    int position=button.tag-100;
    if (position>=1&&position<4) {
        BasicNavigationController *nav=[self.viewControllers objectAtIndex:position];
        id viewControl=[nav.viewControllers objectAtIndex:0];
        if (position==1) {
            PersonTrajectoryViewController *trajectory=(PersonTrajectoryViewController*)viewControl;
            if (!trajectory.canShowTrajectory) {
                return;
            }
        }
        if (position==2) {
            CallTrajectoryViewController *trajectory=(CallTrajectoryViewController*)viewControl;
            if (!trajectory.canShowCall) {
                return;
            }
        }
        if (position==3) {
            TrajectoryMessageController *trajectory=(TrajectoryMessageController*)viewControl;
            if (!trajectory.canShowMessage) {
                return;
            }
        }
    }
    
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
        [self showRecordMessage:YES];//显示记录总数
    }else if (count== 2) {
        [self showTabbar:NO];
    }
    if (count>1) {
        [self showRecordMessage:NO];
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
