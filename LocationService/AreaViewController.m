//
//  AreaViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/27.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "AreaViewController.h"
#import "Account.h"
#import "AreaCrawl.h"
#import "AppHelper.h"
#import "LoginButtons.h"
@interface AreaViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
    LoginButtons *_toolBar;
}
- (void)loadingArea;
- (void)buttonAddClick;
- (void)buttonEditClick:(id)sender;
- (AreaCrawl*)FindById:(NSString*)guid;
@end

@implementation AreaViewController

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
    
    if ([self.view.subviews containsObject:self.navBarView]) {
        if (![self.navBarView viewWithTag:300]) {
            UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame=CGRectMake(self.view.bounds.size.width-90, (44-35)/2, 50, 35);
            btn.tag=300;
            [btn setTitle:@"添加" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(buttonAddClick) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
            btn.showsTouchWhenHighlighted = YES;  //指定按钮被按下时发光
            [btn setTitleColor:[UIColor colorFromHexRGB:@"4a7ebb"] forState:UIControlStateHighlighted];
            [self.navBarView addSubview:btn];
        }
        if (![self.navBarView viewWithTag:301]) {
            UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame=CGRectMake(self.view.bounds.size.width-50, (44-35)/2, 50, 35);
            btn.tag=301;
            [btn setTitle:@"编辑" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(buttonEditClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
            btn.showsTouchWhenHighlighted = YES;  //指定按钮被按下时发光
            [btn setTitleColor:[UIColor colorFromHexRGB:@"4a7ebb"] forState:UIControlStateHighlighted];
            [self.navBarView addSubview:btn];
        }
    }

}
- (void)viewDidLoad
{
    [super viewDidLoad];
	CGRect r=self.view.bounds;
    r.origin.y=44;
    r.size.height-=44*2;

    _tableView=[[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor=[UIColor clearColor];
    _tableView.bounces=NO;
    [self.view addSubview:_tableView];
    
    _toolBar=[[LoginButtons alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, self.view.bounds.size.width, 44)];
    [_toolBar.submit setTitle:@"删除(0)" forState:UIControlStateNormal];
    [_toolBar.cancel setTitle:@"清空" forState:UIControlStateNormal];
    [_toolBar.cancel addTarget:self action:@selector(buttonCancelRemoveClick) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar.submit addTarget:self action:@selector(buttonSubmitRemoveClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_toolBar];
    
    [self loadingArea];
}
- (void)loadingArea{
    if (!self.hasNetWork) {
        [self showErrorNetWorkNotice:nil];
        return;
    }
    Account *acc=[Account unarchiverAccount];
    NSMutableArray *params=[NSMutableArray arrayWithCapacity:6];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:acc.WorkNo,@"workno", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"areaID", nil]];
    
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.methodName=@"GetAreaData";
    args.soapParams=params;
    
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        if (result.hasSuccess) {
            NSDictionary *dic=(NSDictionary*)[result json];
            NSArray *source=[dic objectForKey:@"AreaList"];
            self.list=[NSMutableArray arrayWithArray:[AppHelper arrayWithSource:source className:@"AreaCrawl"]];
            [_tableView reloadData];
        }
    } failed:^(NSError *error, NSDictionary *userInfo) {
        
    }];
}
- (AreaCrawl*)FindById:(NSString*)guid{
    if (self.list&&[self.list count]>0) {
        NSString *match=[NSString stringWithFormat:@"SELF.SysID =='%@'",guid];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:match];
        NSArray *results = [self.list filteredArrayUsingPredicate:predicate];
        if (results&&[results count]>0) {
            AreaCrawl *item=[results objectAtIndex:0];
            return item;
        }
    }
    return nil;
}
//清空
- (void)buttonCancelRemoveClick{

}//删除
- (void)buttonSubmitRemoveClick{
    if (self.removeList&&[self.removeList count]>0) {
        
        NSMutableArray *delSource=[NSMutableArray array];
        for (NSString *sysid in self.removeList.allKeys) {
            AreaCrawl *entity=[self FindById:sysid];
            if (entity!=nil) {
                [delSource addObject:entity];
            }
        }
        
        [self showLoadingAnimatedWithTitle:@"正在删除,请稍后..."];
        ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
        args.serviceURL=DataWebservice1;
        args.serviceNameSpace=DataNameSpace1;
        args.methodName=@"DelArea";
        args.soapParams=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:[self.removeList.allKeys componentsJoinedByString:@","],@"areaID", nil], nil];
        [self.serviceHelper asynService:args success:^(ServiceResult *result) {
            BOOL boo=NO;
            if (result.hasSuccess) {
                NSDictionary *dic=(NSDictionary*)[result json];
                if (dic!=nil&&[[dic objectForKey:@"Result"] isEqualToString:@"1"]) {
                    boo=YES;
                    [self hideLoadingViewAnimated:^(AnimateLoadView *hideView) {
                        [self.list removeObjectsInArray:delSource];
                        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithArray:[self.removeList allValues]] withRowAnimation:UITableViewRowAnimationFade];
                        [self.removeList removeAllObjects];
                    }];
                }
            }
            if (!boo) {
                [self hideLoadingFailedWithTitle:@"删除失败!" completed:nil];
            }
        } failed:^(NSError *error, NSDictionary *userInfo) {
            [self hideLoadingFailedWithTitle:@"删除失败!" completed:nil];
        }];
    }
}
//新增
- (void)buttonAddClick{

}
//编辑
- (void)buttonEditClick:(id)sender{
    UIButton *btn=(UIButton*)sender;
    [_tableView setEditing:!_tableView.editing animated:YES];
    if(_tableView.editing){
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        CGRect r=_toolBar.frame;
        r.origin.y=self.view.bounds.size.height-44;
        
        CGRect r1=_tableView.frame;
        r1.size.height=self.view.bounds.size.height-44*2;
        
        [UIView animateWithDuration:0.5f animations:^(){
            _toolBar.frame=r;
            _tableView.frame=r1;
        }];
    }
	else {
        [btn setTitle:@"编辑" forState:UIControlStateNormal];
        CGRect r=_toolBar.frame;
        r.origin.y=self.view.bounds.size.height+44;
        
        CGRect r1=_tableView.frame;
        r1.size.height=self.view.bounds.size.height-44;
        
        [UIView animateWithDuration:0.5f animations:^(){
            _toolBar.frame=r;
            _tableView.frame=r1;
        }];
	}
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.list.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier=@"SupervisionCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
        cell.textLabel.textColor=[UIColor blackColor];
    }
    AreaCrawl *area=self.list[indexPath.row];
    cell.textLabel.text=area.AreaPerson;
    return cell;
}
@end
