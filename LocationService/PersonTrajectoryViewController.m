//
//  PersonTrajectoryViewController.m
//  LocationService
//
//  Created by aJia on 2014/1/5.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import "PersonTrajectoryViewController.h"
#import "Account.h"
#import "NSDate+TPCategory.h"
#import "FXLabel.h"
#import "AppHelper.h"
#import "TrajectoryHistory.h"
#import "TKTrajectoryCell.h"
#import "SingleMapShowViewController.h"
#import "ShowTrajectoryViewController.h"
@interface PersonTrajectoryViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
}
- (void)loadingHistory;
@end

@implementation PersonTrajectoryViewController
- (void)dealloc{
    [super dealloc];
    [_tableView release],_tableView=nil;
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.Entity&&self.Entity.Name&&[self.Entity.Name length]>0) {
        [self.navBarView setNavBarTitle:[NSString stringWithFormat:@"%@--足迹",self.Entity.Name]];
        
        FXLabel *label=(FXLabel*)[self.navBarView viewWithTag:200];
        CGRect r=label.frame;
        r.origin.x=33+10;
        label.frame=r;
    }
    if ([self.view.subviews containsObject:self.navBarView]) {
        if (![self.navBarView viewWithTag:300]) {
            UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame=CGRectMake(self.view.bounds.size.width-90, (44-35)/2, 50, 35);
            btn.tag=300;
            [btn setTitle:@"地图" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(buttonMapClick) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
            btn.showsTouchWhenHighlighted = YES;  //指定按钮被按下时发光
            [btn setTitleColor:[UIColor colorFromHexRGB:@"4a7ebb"] forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(buttonMapLinesClick) forControlEvents:UIControlEventTouchUpInside];
            [self.navBarView addSubview:btn];
        }
        if (![self.navBarView viewWithTag:301]) {
            
            UIImage *image=[UIImage imageNamed:@"bottomico.png"];
            
            UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame=CGRectMake(self.view.bounds.size.width-image.size.width-5, (44-image.size.height)/2, image.size.width, image.size.height);
            btn.tag=301;
            [btn setImage:image forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"topico.png"] forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(buttonSwitchClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.navBarView addSubview:btn];
        }
    }
    
    if (self.Entity&&self.Entity.ID&&[self.Entity.ID length]>0) {
        [self loadingHistory];
    }else{
        self.cells=[NSArray array];
        [_tableView reloadData];
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //接收通知
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTrajectoryNotifice:) name:@"trajectTarget" object:nil];
    
    CGRect r=self.view.bounds;
    r.origin.y=44;
    r.size.height-=44*2;
    _tableView=[[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.bounces=NO;
    [self.view addSubview:_tableView];
    
    _trajectorySearch=[[TrajectorySearch alloc] initWithFrame:CGRectMake(0, 44-79, self.view.bounds.size.width, 79)];
    [_trajectorySearch.button addTarget:self action:@selector(buttonSearchClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_trajectorySearch];
    [self.view sendSubviewToBack:_trajectorySearch];
}
//接收通知
- (void)receiveTrajectoryNotifice:(NSNotification*)notifice{
   NSDictionary *dic=[notifice userInfo];
   SupervisionPerson *entity=[dic objectForKey:@"Entity"];
   self.Entity=entity;
}
//显示地图路线
- (void)buttonMapLinesClick{
   if(self.cells&&[self.cells count]>0)
   {
       ShowTrajectoryViewController *show=[[ShowTrajectoryViewController alloc] init];
       show.list=self.cells;
       [self.navigationController pushViewController:show animated:YES];
       [show release];
   }
}
//查询
- (void)buttonSearchClick{
    [self loadingHistory];
}
//查询
- (void)buttonSwitchClick:(id)sender{
    UIButton *btn=(UIButton*)sender;
    if (btn.selected) {//隐藏
        CGRect r=self.trajectorySearch.frame;
        r.origin.y=44-r.size.height;
        
        CGRect r1=_tableView.frame;
        r1.origin.y=44;
        r1.size.height=self.view.bounds.size.height-r1.origin.y-TabHeight;
        
        [UIView animateWithDuration:0.5f animations:^{
            self.trajectorySearch.frame=r;
            _tableView.frame=r1;
            btn.selected=NO;
            [self.view sendSubviewToBack:self.trajectorySearch];
        }];
    }else{//显示
        [self.view sendSubviewToBack:_tableView];
        
        CGRect r=self.trajectorySearch.frame;
        r.origin.y=44;
        
        CGRect r1=_tableView.frame;
        r1.origin.y=44+r.size.height;
        r1.size.height=self.view.bounds.size.height-r1.origin.y-TabHeight;
        
        [UIView animateWithDuration:0.5f animations:^{
            self.trajectorySearch.frame=r;
            _tableView.frame=r1;
            btn.selected=YES;
            
        }];
    }
}
- (void)loadingHistory{

    Account *acc=[Account unarchiverAccount];
    NSMutableArray *params=[NSMutableArray array];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:acc.WorkNo,@"workno", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.Entity.ID,@"id", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.trajectorySearch.startCalendar.popoverText.popoverTextField.text,@"stime", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.trajectorySearch.endCalendar.popoverText.popoverTextField.text,@"etime", nil]];
    
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.methodName=@"ObjectHistoryInfo";
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.soapParams=params;
    
    [self showLoadingAnimatedWithTitle:@"正在加载,请稍后..."];
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        
        BOOL boo=NO;
        if (result.hasSuccess) {
            XmlNode *node=[result methodNode];
            NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[node.InnerText dataUsingEncoding:NSUTF8StringEncoding] options:1 error:nil];
            if ([dic.allKeys containsObject:@"Person"]) {
                boo=YES;
                [self hideLoadingViewAnimated:^(AnimateLoadView *hideView) {
                    NSArray *source=[dic objectForKey:@"Person"];
                    self.cells=[AppHelper arrayWithSource:source className:@"TrajectoryHistory"];
                    [_tableView reloadData];
                }];
            }
        }
        if (!boo) {
            [self hideLoadingFailedWithTitle:@"加载失败!" completed:nil];
        }
        
    } failed:^(NSError *error, NSDictionary *userInfo) {
        //NSLog(@"error=%@",error.debugDescription);
        [self hideLoadingFailedWithTitle:@"加载失败!" completed:nil];
    }];

    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.cells.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier=@"TrajectoryCell";
    TKTrajectoryCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[TKTrajectoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        
    }
    TrajectoryHistory *entity=self.cells[indexPath.row];
    cell.label.text=entity.pctime;
    cell.address.text=entity.address;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TrajectoryHistory *entity=self.cells[indexPath.row];
    CGFloat w=self.view.bounds.size.width/2-5;
    CGSize size=[entity.address textSize:[UIFont fontWithName:DeviceFontName size:DeviceFontSize] withWidth:w];
    if (size.height+10>44) {
        return size.height+10+2;
    }
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *bgView=[[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)] autorelease];
    bgView.backgroundColor=[UIColor colorFromHexRGB:@"d5e1f0"];
    
    NSString *lab1Title=@"时间";
    CGSize size=[lab1Title textSize:[UIFont fontWithName:DeviceFontName size:DeviceFontSize] withWidth:self.view.bounds.size.width];
    UILabel *lab1=[[UILabel alloc] initWithFrame:CGRectMake(20,(bgView.frame.size.height-size.height)/2, size.width,size.height)];
    lab1.text=lab1Title;
    lab1.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    lab1.backgroundColor=[UIColor clearColor];
    [bgView addSubview:lab1];
    [lab1 release];
    
    
    NSString *lab2Title=@"位置";
    size=[lab2Title textSize:[UIFont fontWithName:DeviceFontName size:DeviceFontSize] withWidth:self.view.bounds.size.width];
    UILabel *lab2=[[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-20,(bgView.frame.size.height-size.height)/2, size.width,size.height)];
    lab2.text=lab2Title;
    lab2.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    lab2.backgroundColor=[UIColor clearColor];
    [bgView addSubview:lab2];
    [lab2 release];
    
    
    return bgView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TrajectoryHistory *entity=self.cells[indexPath.row];
    SingleMapShowViewController *map=[[SingleMapShowViewController alloc] init];
    map.Entity=entity;
    map.PersonName=self.Entity.Name;
    [self.navigationController pushViewController:map animated:YES];
    [map release];
}
@end
