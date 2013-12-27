//
//  OnlineMapViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/27.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "OnlineMapViewController.h"

@interface OnlineMapViewController ()

@end

@implementation OnlineMapViewController

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
    [self.navBarView setNavBarTitle:@"离线地图"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setTitle:@"show" forState:UIControlStateNormal];
    btn.frame=CGRectMake(10, 54, 300, 35);
    [btn addTarget:self action:@selector(buttonShowClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
	
}
- (void)buttonShowClick{
    [self showSuccessViewAnimated:^(AnimateErrorView *successView) {
       successView.labelTitle.text=@"更新成功啦!";
    }];
    [self performSelector:@selector(hideSuccessViewAnimated:) withObject:nil afterDelay:3.0f];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
