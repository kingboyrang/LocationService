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
    total=5;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	UIImage *image=[UIImage imageNamed:@"logintop.jpg"];
    CGRect r=self.view.bounds;
    r.size=image.size;
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:r];
    [imageView setImage:image];
    [self.view addSubview:imageView];
    [imageView release];
    
    FXLabel *fx=[AppUI showLabelTitle:@"注册成功" frame:CGRectMake(0, 0, image.size.width, image.size.height)];
    r=fx.frame;
    r.origin.x=(self.view.bounds.size.width-r.size.width)/2.0;
    r.origin.y=(image.size.height-r.size.height)/2.0;
    fx.frame=r;
    [self.view addSubview:fx];
    
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
    btn.backgroundColor=[UIColor blackColor];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    [btn addTarget:self action:@selector(buttonCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
- (void)timerFireMethod:(NSTimer*)theTimer{
    total--;
    if (total==0) {
        [theTimer invalidate];
        [Account registerLoginWithAccount:self.Entity];
        MainViewController *main=[[MainViewController alloc] init];
        [self presentViewController:main animated:YES completion:nil];
        [main release];
    }else{
       _labelShowInfo.text=[NSString stringWithFormat:@"自动登录,%d秒后跳转到主画面...",total];
    }
}
-(void)buttonCancelClick{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionReveal];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[self.view layer] addAnimation:animation forKey:@"dissMissToView"];
    //self.modalTransitionStyle=UI;
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
