//
//  OnlineMapViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/27.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "OnlineMapViewController.h"
#import "LoginButtons.h"
#import "DownloadMapController.h"
@interface OnlineMapViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
}
- (void)buttonAddClick:(id)sender;
- (void)buttonPauseClick:(id)sender;
- (void)buttonDownloadClick:(id)sender;
- (void)buttonUpdateClick:(id)sender;
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
    if (![self.navBarView viewWithTag:301]) {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(self.view.bounds.size.width-50, (44-35)/2, 50, 35);
        btn.tag=301;
        [btn setTitle:@"添加" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(buttonAddClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
        btn.showsTouchWhenHighlighted = YES;  //指定按钮被按下时发光
        [btn setTitleColor:[UIColor colorFromHexRGB:@"4a7ebb"] forState:UIControlStateHighlighted];
        [self.navBarView addSubview:btn];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect r=self.view.bounds;
    r.size.height-=44*2;
    r.origin.y=44;
    _tableView=[[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    [self.view addSubview:_tableView];
    
    
    LoginButtons *buttons=[[LoginButtons alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    buttons.cancel.frame=CGRectMake(0, 0, self.view.bounds.size.width/3, 44);
    [buttons.cancel setTitle:@"全部暂停" forState:UIControlStateNormal];
    [buttons.cancel addTarget:self action:@selector(buttonPauseClick:) forControlEvents:UIControlEventTouchUpInside];
    buttons.submit.frame=CGRectMake(self.view.bounds.size.width/3, 0, self.view.bounds.size.width/3, 44);
    [buttons.submit setTitle:@"全部下载" forState:UIControlStateNormal];
    [buttons.submit addTarget:self action:@selector(buttonDownloadClick:) forControlEvents:UIControlEventTouchUpInside];
    UIButton  *downBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    downBtn.frame=CGRectMake(self.view.bounds.size.width*2/3, 0, self.view.bounds.size.width/3,44);
    [downBtn setTitle:@"全部更新" forState:UIControlStateNormal];
    [downBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    downBtn.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    downBtn.showsTouchWhenHighlighted = YES;  //指定按钮被按下时发光
    [downBtn setTitleColor:[UIColor colorFromHexRGB:@"4a7ebb"] forState:UIControlStateHighlighted];
    [downBtn addTarget:self action:@selector(buttonUpdateClick:) forControlEvents:UIControlEventTouchUpInside];
    [buttons addSubview:downBtn];
    
    [self.view addSubview:buttons];
    [buttons release];
    
    //获取各城市离线地图更新信息
    //_arraylocalDownLoadMapInfo = [[NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]] retain];
    
}
//下载完成
- (void)finishedDownloadWithRow:(UITableViewCell*)cell{
    
}
//下载地图
- (void)downloadMapWithEntity:(BMKOLSearchRecord*)entity{

}
//全部暂停
- (void)buttonPauseClick:(id)sender{

}
//全部下载
- (void)buttonDownloadClick:(id)sender{
    
}
//全部更新
- (void)buttonUpdateClick:(id)sender{
    
}
//添加地图
- (void)buttonAddClick:(id)sender{
    DownloadMapController *map=[[DownloadMapController alloc] init];
    map.controler=self;
    [self.navigationController pushViewController:map animated:YES];
    [map release];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark tableView datasource methods
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"已下载";
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [self.list count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"mapcell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
    }
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[[UIView alloc] init] autorelease];
    myView.backgroundColor = [UIColor colorFromHexRGB:@"f2f2f2"];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 90, 22)];
    titleLabel.textColor=[UIColor blackColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    titleLabel.text=@"已下载";
    [myView addSubview:titleLabel];
    [titleLabel release];
    return myView;
}
@end
