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
#import "AlertHelper.h"
#import "AreaRangeViewController.h"
#import "UIImage+TPCategory.h"
#import "SupervisionPerson.h"
#import "AppHelper.h"
#import "AppUI.h"
@interface AreaRuleViewController ()<UITableViewDataSource,UITableViewDelegate>{
    CVUISelect *_ruleSelect;
    UITableView *_tableView;
}
- (void)buttonNextClick:(id)sender;
- (void)buttonFinishedClick:(id)sender;
- (void)loadingAreaCars;
- (void)addRuleCompleted:(void(^)(NSString *ruleId))completed;
- (void)handlerRuleResult:(ServiceResult*)result;
- (void)handlerTrajectoryResult:(ServiceResult*)result;
- (void)handlerShipResult:(ServiceResult*)result;
- (int)getRowFindbyId:(NSString*)carId;

@end

@implementation AreaRuleViewController
- (void)dealloc{
    [super dealloc];
    [_ruleSelect release];
    [_tableView release];
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
    [self.navBarView setNavBarTitle:@"电子围栏"];
    if (![self.navBarView viewWithTag:300]) {
        UIButton *btn=[AppUI createhighlightButtonWithTitle:@"2/3" frame:CGRectMake(self.view.bounds.size.width-90, (44-35)/2, 50, 35)];
        btn.tag=300;
        [self.navBarView addSubview:btn];
    }
    if (![self.navBarView viewWithTag:301]) {
        UIButton *btn=[AppUI createhighlightButtonWithTitle:@"列表" frame:CGRectMake(self.view.bounds.size.width-50, (44-35)/2, 50, 35)];
        btn.tag=301;
        [btn addTarget:self action:@selector(buttonListClick) forControlEvents:UIControlEventTouchUpInside];
        [self.navBarView addSubview:btn];
    }
    
    [self loadingAreaCars];//队列加载区域关联对象
}
//返回列表
- (void)buttonListClick{
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.ruleId=@"";
    self.operateType=1;
    CGFloat topY=44;
	
    RangHeader *titleView=[[RangHeader alloc] initWithFrame:CGRectMake(0, topY, self.view.bounds.size.width, 30)];
    titleView.label.frame=CGRectMake(0, 5, titleView.frame.size.width, 20);
    titleView.label.text=[NSString stringWithFormat:@"名称:%@",self.AreaName];
    titleView.label.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:titleView];
    [titleView release];
    
    topY+=30+5;
    NSString *title=@"规则";
    CGSize size=[title textSize:[UIFont fontWithName:DeviceFontName size:DeviceFontSize] withWidth:self.view.bounds.size.width];
    UILabel *labTitle=[[UILabel alloc] initWithFrame:CGRectMake(37, (45-size.height)/2+44+30, size.width, size.height)];
    labTitle.text=title;
    labTitle.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    labTitle.backgroundColor=[UIColor clearColor];
    [self.view addSubview:labTitle];
    
    _ruleSelect=[[CVUISelect alloc] initWithFrame:CGRectMake(labTitle.frame.size.width+labTitle.frame.origin.x+5, topY, 206, 35)];
    _ruleSelect.popoverText.popoverTextField.borderStyle=UITextBorderStyleRoundedRect;
    _ruleSelect.popoverText.popoverTextField.placeholder=@"请选择规则";
   
    UIImage *img=[UIImage imageNamed:@"DownAccessory.png"];
    UIImageView *imageView=[[[UIImageView alloc] initWithImage:img] autorelease];
    _ruleSelect.popoverText.popoverTextField.enabled=NO;
    _ruleSelect.popoverText.popoverTextField.rightView=imageView;
   _ruleSelect.popoverText.popoverTextField.rightViewMode=UITextFieldViewModeAlways;
    _ruleSelect.popoverText.popoverTextField.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    //设置数据源
    NSMutableArray *saveArr=[NSMutableArray array];
    [saveArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"限入",@"key",@"1",@"value", nil]];
    [saveArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"限出",@"key",@"2",@"value", nil]];
    [saveArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"限停",@"key",@"3",@"value", nil]];
    [_ruleSelect setDataSourceForArray:saveArr dataTextName:@"key" dataValueName:@"value"];
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
    //_tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    //_tableView.separatorColor=[UIColor clearColor];
    //_tableView.bounces=NO;
    [self.view addSubview:_tableView];
    
    
    LoginButtons *buttons=[[LoginButtons alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    UIButton *btnPrev=[AppUI createhighlightButtonWithTitle:@"上一步" frame:CGRectMake(0,0,self.view.bounds.size.width/3,44)];
    [btnPrev setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnPrev addTarget:self action:@selector(buttonPrevClick) forControlEvents:UIControlEventTouchUpInside];
    [buttons addSubview:btnPrev];
    
    buttons.cancel.frame=CGRectMake(self.view.bounds.size.width*2/3, 0, self.view.bounds.size.width/3, 44);
    buttons.submit.frame=CGRectMake(self.view.bounds.size.width/3, 0, self.view.bounds.size.width/3, 44);
    [buttons.cancel setTitle:@"下一步" forState:UIControlStateNormal];
    [buttons.cancel addTarget:self action:@selector(buttonNextClick:) forControlEvents:UIControlEventTouchUpInside];
    [buttons.submit setTitle:@"完成" forState:UIControlStateNormal];
    [buttons.submit addTarget:self action:@selector(buttonFinishedClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttons];
    [buttons release];
    
}
- (void)buttonPrevClick{
    [self.navigationController popViewControllerAnimated:YES];
}
//处理规则
- (void)handlerRuleResult:(ServiceResult*)result{
    if (result.hasSuccess) {
        NSDictionary *dic=[result json];
        if (dic!=nil) {
            NSArray *arr=[dic objectForKey:@"AreaLatLngList"];
            if (arr&&[arr count]>0) {
                NSString *ruleType=@"";
                NSDictionary *item=[arr objectAtIndex:0];
                if ([[item objectForKey:@"InLimit"] isEqualToString:@"True"]) {
                    ruleType=@"1";
                }
                if ([[item objectForKey:@"OutLimit"] isEqualToString:@"True"]) {
                    ruleType=@"2";
                }
                if ([[item objectForKey:@"StopLimit"] isEqualToString:@"True"]) {
                    ruleType=@"3";
                }
                self.ruleId=[item objectForKey:@"ruleID"];//取得规则guid
                self.operateType=2;//修改
                //设置选中项
                if ([ruleType length]>0) {
                    [_ruleSelect setIndex:[ruleType intValue]-1];
                }
            }
        }
    }
}
//处理关联对象
- (void)handlerTrajectoryResult:(ServiceResult*)result{
    if (result.hasSuccess) {
        NSDictionary *dic=[result json];
        NSArray *source=[dic objectForKey:@"Person"];
        self.sourceData=[NSMutableArray arrayWithArray:[AppHelper arrayWithSource:source className:@"SupervisionPerson"]];
        [_tableView reloadData];
        [_tableView setEditing:YES animated:YES];//设置可以编辑
    }

}
//修改时，设置选中项
- (void)handlerShipResult:(ServiceResult*)result{
    //NSLog(@"xml=%@",result.request.responseString);
    if (result.hasSuccess) {
        NSDictionary *dic=[result json];
        NSArray *source=[dic objectForKey:@"CarList"];
        
        NSArray *items=[AppHelper arrayWithSource:source className:@"AreaCar"];
        if (items&&[items count]>0) {
            for (AreaCar *item in items) {
                int row=[self getRowFindbyId:item.ID];
                if (row>=0&&self.sourceData&&row<[self.sourceData count]) {
                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
                    //设置checkbox选中
                    [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                    //保存选中的值
                    [self tableView:_tableView didSelectRowAtIndexPath:indexPath];
                }
            }
        }
    }
}
- (int)getRowFindbyId:(NSString*)carId{
    if (self.sourceData&&[self.sourceData count]>0) {
        NSString *match=[NSString stringWithFormat:@"SELF.ID =='%@'",carId];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:match];
        NSArray *results = [self.sourceData filteredArrayUsingPredicate:predicate];
        if (results&&[results count]>0) {
            SupervisionPerson *item=[results objectAtIndex:0];
            return [self.sourceData indexOfObject:item];
        }
    }
    return -1;
}
//加载区域关联对象
- (void)loadingAreaCars{
    //取得修改关联对象
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.methodName=@"GetAreaCar";
    args.soapParams=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:self.AreaId,@"areaID", nil], nil];
    //NSLog(@"soap=%@",args.soapMessage);
    ASIHTTPRequest *request1=[ServiceHelper commonSharedRequest:args];
    [request1 setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"car",@"name", nil]];
    [self.serviceHelper addQueue:request1];
    //取得关联对象
    Account *acc=[Account unarchiverAccount];
    ServiceArgs *args1=[[[ServiceArgs alloc] init] autorelease];
    args1.serviceURL=DataWebservice1;
    args1.serviceNameSpace=DataNameSpace1;
    args1.methodName=@"GetSuperviseInfo";
    args1.soapParams=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:acc.WorkNo,@"WorkNo", nil], nil];
    ASIHTTPRequest *request2=[ServiceHelper commonSharedRequest:args1];
    [request2 setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"users",@"name", nil]];
    [self.serviceHelper addQueue:request2];
    
    //取得修改规则
    NSMutableArray *params=[NSMutableArray array];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.AreaId,@"areaID", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"zh-CHS",@"language", nil]];
    
    ServiceArgs *args2=[[[ServiceArgs alloc] init] autorelease];
    args2.serviceURL=DataWebservice1;
    args2.serviceNameSpace=DataNameSpace1;
    args2.methodName=@"GetAreaRule";
    args2.soapParams=params;
    //NSLog(@"soap=%@",args2.soapMessage);
    ASIHTTPRequest *request3=[ServiceHelper commonSharedRequest:args2];
    [request3 setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"rule",@"name", nil]];
    [self.serviceHelper addQueue:request3];
    
    //执行队列请求
    [self.serviceHelper startQueue:nil failed:nil complete:^(NSArray *results) {
        ServiceResult *shipResult=nil;
        for (ServiceResult *result in results) {
            NSString *name=[result.userInfo objectForKey:@"name"];
            if ([name isEqualToString:@"rule"]) {//规则
                
                [self handlerRuleResult:result];
            }
            if ([name isEqualToString:@"users"]) {//关联对象
                [self handlerTrajectoryResult:result];
            }
            if ([name isEqualToString:@"car"]) {//修改时的关联对象
                shipResult=result;
            }
        }
        if (shipResult!=nil) {
            [self handlerShipResult:shipResult];
        }
    }];
}

//新增规则
- (void)addRuleCompleted:(void(^)(NSString *areaGuid))completed{
    
    if ([[_ruleSelect value] length]==0) {
        [AlertHelper initWithTitle:@"提示" message:@"请选择规则!"];
        return;
    }
    if ([self.shipUsers count]==0) {
        [AlertHelper initWithTitle:@"提示" message:@"请选择关联对象!"];
        return;
    }
    
    NSString *prefx=self.operateType==1?@"新增":@"修改";
    
    Account *acc=[Account unarchiverAccount];
    NSMutableArray *params=[NSMutableArray array];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.AreaId,@"AreaID", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.ruleId,@"RuleID", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[_ruleSelect value],@"ruleType", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[self.shipUsers.allKeys componentsJoinedByString:@","],@"CarPersonID", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:acc.WorkNo,@"Workno", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"CompanyID", nil]];
    
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.methodName=@"SaveAreaRuleAndCar";
    args.soapParams=params;
    //NSLog(@"soap=%@",args.soapMessage);
    [self showLoadingAnimatedWithTitle:[NSString stringWithFormat:@"正在%@规则,请稍后...",prefx]];
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        //NSLog(@"xml=%@",result.xmlString);
        BOOL boo=NO;
        if(result.hasSuccess)
        {
            NSDictionary *dic=[result json];
            if(dic&&![[dic objectForKey:@"Result"] isEqualToString:@"Fail"])
            {
                self.ruleId=[dic objectForKey:@"Result"];
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
    [self addRuleCompleted:^(NSString *areaId) {
        AreaRangeViewController *areaRange=[[AreaRangeViewController alloc] init];
        areaRange.AreaName=self.AreaName;
        areaRange.AreaId=areaId;
        areaRange.RuleId=self.ruleId;
        [self.navigationController pushViewController:areaRange animated:YES];
        [areaRange release];
    }];
}
//完成
- (void)buttonFinishedClick:(id)sender{
    [self addRuleCompleted:^(NSString *ruleId) {
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
    }];
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
    SupervisionPerson *entity=self.sourceData[indexPath.row];
    [cell.imageView setImageWithURL:[NSURL URLWithString:entity.Photo] placeholderImage:[UIImage imageNamed:@"bg02.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image) {
            if (image.size.width>90||image.size.height>104) {
                [cell.imageView setImage:[image imageByScalingToSize:CGSizeMake(90, 104)]];
            }else{
                [cell.imageView setImage:image];
            }
        }
    }];
    
    cell.textLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    cell.textLabel.text=entity.Name;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 104;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.shipUsers) {
        self.shipUsers=[NSMutableDictionary dictionary];
    }
    SupervisionPerson *entity=self.sourceData[indexPath.row];
    [self.shipUsers setValue:[NSString stringWithFormat:@"%d",indexPath.row] forKey:entity.ID];
   
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SupervisionPerson *entity=self.sourceData[indexPath.row];
    [self.shipUsers removeObjectForKey:entity.ID];
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
}
@end
