//
//  RegisterSuccessViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/19.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "RegisterSuccessViewController.h"
#import "AppUI.h"
#import <QuartzCore/QuartzCore.h>
#import "MainViewController.h"
#import "IndexViewController.h"
#import "BasicNavigationController.h"
@interface RegisterSuccessViewController (){
    UILabel *_labelShowInfo;
    int total;
}
- (void)timerFireMethod:(NSTimer*)theTimer;
@end

@implementation RegisterSuccessViewController
- (void)dealloc{
    [super dealloc];
    [_labelShowInfo release];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navBarView setNavBarTitle:@"注册成功"];
    total=5;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.showBackButton=NO;
    
    NSString *memo=@"自动登录,5秒后跳转到主画面...";
    CGSize size=[memo textSize:[UIFont fontWithName:DeviceFontName size:DeviceFontSize] withWidth:self.view.bounds.size.width-20];
    _labelShowInfo=[[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-size.width)/2.0,(DeviceRealHeight-44*2-size.height)/2, size.width, size.height)];
    _labelShowInfo.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    _labelShowInfo.backgroundColor=[UIColor clearColor];
    _labelShowInfo.numberOfLines=0;
    _labelShowInfo.lineBreakMode=NSLineBreakByWordWrapping;
    _labelShowInfo.text=memo;
    [self.view addSubview:_labelShowInfo];
    
    
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, DeviceRealHeight-44, self.view.bounds.size.width, 44);
    btn.backgroundColor=[UIColor colorFromHexRGB:@"131313"];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    [btn addTarget:self action:@selector(buttonCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
//5秒后登陆
- (void)timerFireMethod:(NSTimer*)theTimer{
    total--;
    if (total==0) {
        [theTimer invalidate];
        [Account registerLoginWithAccount:self.Entity];
        IndexViewController *indexController=[[[IndexViewController alloc] init] autorelease];
        BasicNavigationController *nav=[[[BasicNavigationController alloc] initWithRootViewController:indexController] autorelease];
#ifdef __IPHONE_7_0
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
            UIWindow *window=[[UIApplication sharedApplication] keyWindow];
            window.rootViewController=nav;
        }
#else
        [self presentViewController:nav animated:YES completion:nil];
#endif
        
    }else{
       _labelShowInfo.text=[NSString stringWithFormat:@"自动登录,%d秒后跳转到主画面...",total];
    }
}
//取消
-(void)buttonCancelClick{
    [Account closed];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
