//
//  AreaRangeViewController.m
//  LocationService
//
//  Created by aJia on 2014/1/2.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import "AreaRangeViewController.h"
#import "RangHeader.h"
#import "CVUICalendar.h"
@interface AreaRangeViewController (){
    CVUICalendar *_sCalendar;
    CVUICalendar *_eCalendar;
}

@end

@implementation AreaRangeViewController

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
    [self.navBarView setNavBarTitle:@"电子围栏"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat topY=44;
	
    RangHeader *titleView=[[RangHeader alloc] initWithFrame:CGRectMake(0, topY, self.view.bounds.size.width, 30)];
    titleView.label.frame=CGRectMake(0, 5, titleView.frame.size.width, 20);
    titleView.label.text=@"名称:经开区";
    titleView.label.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:titleView];
    [titleView release];
    
    topY+=30+5;
    RangHeader *bgView=[[RangHeader alloc] initWithFrame:CGRectMake(0, topY, self.view.bounds.size.width, 30)];
    bgView.label.text=@"有限日期";
    [self.view addSubview:bgView];
    [bgView release];
    
    topY+=30+5;
    _sCalendar=[[CVUICalendar alloc] initWithFrame:CGRectMake(8, topY, 149, 35)];
    _sCalendar.popoverText.popoverTextField.placeholder=@"开始时间";
    [self.view addSubview:_sCalendar];
    

    _eCalendar=[[CVUICalendar alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-2*_sCalendar.frame.size.width-2*_sCalendar.frame.origin.x, topY, 149, 35)];
     _eCalendar.popoverText.popoverTextField.placeholder=@"结果时间";
    [self.view addSubview:_eCalendar];
    topY+=35+5;
    
    RangHeader *header1=[[RangHeader alloc] initWithFrame:CGRectMake(0, topY, self.view.bounds.size.width, 30)];
    header1.label.text=@"有限时间";
    [self.view addSubview:header1];
    [header1 release];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
