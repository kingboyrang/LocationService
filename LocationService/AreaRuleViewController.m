//
//  AreaRuleViewController.m
//  LocationService
//
//  Created by aJia on 2014/1/2.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import "AreaRuleViewController.h"
#import "RangHeader.h"
#import "CVUISelect.h"
#import "LoginButtons.h"
#import "AreaCar.h"
#import "AppHelper.h"
#import "UIImageView+WebCache.h"
#import "Account.h"
#import "AreaRangeViewController.h"
@interface AreaRuleViewController ()<UITableViewDataSource,UITableViewDelegate>{
    CVUISelect *_ruleSelect;
    UITableView *_tableView;
}
- (void)buttonNextClick:(id)sender;
- (void)buttonFinishedClick:(id)sender;
- (void)loadingAreaCars;
- (void)loadingRules;
- (void)addRuleCompleted:(void(^)(NSString *ruleId))completed;
@end

@implementation AreaRuleViewController

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
    NSString *title=@"规则";
    CGSize size=[title textSize:[UIFont fontWithName:DeviceFontName size:DeviceFontSize] withWidth:self.view.bounds.size.width];
    UILabel *labTitle=[[UILabel alloc] initWithFrame:CGRectMake(37, topY+45/2-5, size.width, size.height)];
    labTitle.text=title;
    labTitle.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    labTitle.backgroundColor=[UIColor clearColor];
    [self.view addSubview:labTitle];
    
    _ruleSelect=[[CVUISelect alloc] initWithFrame:CGRectMake(labTitle.frame.size.width+labTitle.frame.origin.x+5, topY, 206, 35)];
    _ruleSelect.popoverText.popoverTextField.placeholder=@"请选择规则";
   
    [self.view addSubview:_ruleSelect];
    
    topY+=35+5;
    RangHeader *header1=[[RangHeader alloc] initWithFrame:CGRectMake(0, topY, self.view.bounds.size.width, 30)];
    header1.label.text=@"关联对象";
    [self.view addSubview:header1];
    [header1 release];
    topY+=30;
    
    CGRect r=self.view.bounds;
    r.origin.y=topY;
    r.size.height-=topY+44;
    
    _tableView=[[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor=[UIColor clearColor];
    _tableView.bounces=NO;
    [self.view addSubview:_tableView];
    
    
    LoginButtons *buttons=[[LoginButtons alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    [buttons.cancel setTitle:@"下一步" forState:UIControlStateNormal];
    [buttons.cancel addTarget:self action:@selector(buttonNextClick:) forControlEvents:UIControlEventTouchUpInside];
    [buttons.submit setTitle:@"完成" forState:UIControlStateNormal];
    [buttons.submit addTarget:self action:@selector(buttonFinishedClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttons];
    [buttons release];
    
    [self loadingRules];//加载区域规则
    [self loadingAreaCars];//加载区域关联对象
    
}
//加载区域规则
- (void)loadingRules{
    NSMutableArray *params=[NSMutableArray array];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"AreaID", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"zh-CHS",@"language", nil]];

    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.methodName=@"GetAreaRule";
    args.soapParams=params;
    
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        if (result.hasSuccess) {
            NSDictionary *dic=[result json];
            if (dic!=nil) {
                NSArray *arr=[dic objectForKey:@"AreaLatLngList"];
                if (arr&&[arr count]>0) {
                    
                    NSMutableArray *saveArr=[NSMutableArray array];
                    NSDictionary *item=[saveArr objectAtIndex:0];
                    if ([[item objectForKey:@"InLimit"] isEqualToString:@"True"]) {
                        [saveArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"限入",@"key",@"1",@"value", nil]];
                    }
                    if ([[item objectForKey:@"OutLimit"] isEqualToString:@"True"]) {
                        [saveArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"限出",@"key",@"2",@"value", nil]];
                    }
                    if ([[item objectForKey:@"StopLimit"] isEqualToString:@"True"]) {
                        [saveArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"限停",@"key",@"3",@"value", nil]];
                    }
                    [_ruleSelect setDataSourceForArray:saveArr dataTextName:@"key" dataValueName:@"value"];
                }
            }
        }
        
    } failed:^(NSError *error, NSDictionary *userInfo) {
        
    }];
    
}
//加载区域关联对象
- (void)loadingAreaCars{

    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.methodName=@"GetAreaCar";
    args.soapParams=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"areaID", nil], nil];
    
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        if (result.hasSuccess) {
            NSDictionary *dic=[result json];
            if (dic!=nil) {
                NSArray *source=[dic objectForKey:@"CarList"];
                self.sourceData=[AppHelper arrayWithSource:source className:@"AreaCar"];
                [_tableView reloadData];
                [_tableView setEditing:YES animated:YES];//设置可以编辑
            }
        }
    } failed:^(NSError *error, NSDictionary *userInfo) {
        
    }];
}
//新增规则
- (void)addRuleCompleted:(void(^)(NSString *ruleId))completed{
    NSString *prefx=self.operateType==1?@"新增":@"修改";
    
    Account *acc=[Account unarchiverAccount];
    NSMutableArray *params=[NSMutableArray array];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.AreaId,@"AreaID", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"RuleID", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[_ruleSelect value],@"ruleType", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[self.shipUsers.allKeys componentsJoinedByString:@","],@"CarPersonID", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:acc.WorkNo,@"Workno", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"CompanyID", nil]];
    
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.methodName=@"SaveAreaRuleAndCar";
    args.soapParams=params;
    [self showLoadingAnimatedWithTitle:[NSString stringWithFormat:@"正在%@规则,请稍后...",prefx]];
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        BOOL boo=NO;
        if(result.hasSuccess)
        {
            NSDictionary *dic=[result json];
            if(dic&&[[dic objectForKey:@"Result"] isEqualToString:@"Success"])
            {
                boo=YES;
                [self hideLoadingViewAnimated:^(AnimateLoadView *hideView) {
                    if (completed) {
                        completed(self.AreaId);
                    }
                }];
            }
        }
        if (!boo) {
           [self hideLoadingFailedWithTitle:[NSString stringWithFormat:@"%@规则失败!",prefx] completed:nil];
        }
    } failed:^(NSError *error, NSDictionary *userInfo) {
        [self hideLoadingFailedWithTitle:[NSString stringWithFormat:@"%@规则失败!",prefx] completed:nil];
    }];
}
//下一步
- (void)buttonNextClick:(id)sender{
    if(self.operateType==1)//新增
    {
        [self addRuleCompleted:^(NSString *ruleId) {
            AreaRangeViewController *areaRange=[[AreaRangeViewController alloc] init];
            [self.navigationController pushViewController:areaRange animated:YES];
            [areaRange release];
        }];
    }
}
//完成
- (void)buttonFinishedClick:(id)sender{
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.sourceData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"carCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        
    }
    AreaCar *entity=self.sourceData[indexPath.row];
    [cell.imageView setImageWithURL:[NSURL URLWithString:entity.Phot] placeholderImage:[UIImage imageNamed:@"bg02.png"]];
    cell.textLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    cell.textLabel.text=entity.Name;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.shipUsers) {
        self.shipUsers=[NSMutableDictionary dictionary];
    }
    AreaCar *entity=self.sourceData[indexPath.row];
    [self.shipUsers setValue:[NSString stringWithFormat:@"%d",indexPath.row] forKey:entity.ID];
   
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AreaCar *entity=self.sourceData[indexPath.row];
    [self.shipUsers removeObjectForKey:entity.ID];
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
}
@end
