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
#import "LoginButtons.h"
#import "TKAreaWeekCell.h"
#import "TKAreaRangeCell.h"
#import "Account.h"
#import "AlertHelper.h"
#define  dicWeeks [NSDictionary dictionaryWithObjectsAndKeys:@"一",@"1",@"二",@"2",@"三",@"3",@"四",@"4",@"五",@"5",@"六",@"6",@"日",@"7", nil]
@interface AreaRangeViewController ()<UITableViewDataSource,UITableViewDelegate>{
    CVUICalendar *_sCalendar;
    CVUICalendar *_eCalendar;
    UITableView *_tableView;
}
- (int)getCellRow:(TKAreaRangeCell*)cell;
- (NSString*)RuleDataXml;
- (NSDictionary*)getRuleTimeXml;
@end

@implementation AreaRangeViewController
- (void)dealloc{
    [super dealloc];
    [_sCalendar release];
    [_eCalendar release];
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
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat topY=44;
	
    RangHeader *titleView=[[RangHeader alloc] initWithFrame:CGRectMake(0, topY, self.view.bounds.size.width, 30)];
    titleView.label.frame=CGRectMake(0, 5, titleView.frame.size.width, 20);
    titleView.label.text=[NSString stringWithFormat:@"名称:%@",self.AreaName];
    titleView.label.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:titleView];
    [titleView release];
    
    topY+=30+5;
    RangHeader *bgView=[[RangHeader alloc] initWithFrame:CGRectMake(0, topY, self.view.bounds.size.width, 30)];
    bgView.label.text=@"有限日期";
    [self.view addSubview:bgView];
    [bgView release];
    
    topY+=30+5;
    CGFloat lefxt=(self.view.bounds.size.width-149*2)/3;
    _sCalendar=[[CVUICalendar alloc] initWithFrame:CGRectMake(lefxt, topY, 149, 35)];
    _sCalendar.popoverText.popoverTextField.placeholder=@"开始时间";
    _sCalendar.popoverText.popoverTextField.borderStyle=UITextBorderStyleRoundedRect;
    [self.view addSubview:_sCalendar];
    

    _eCalendar=[[CVUICalendar alloc] initWithFrame:CGRectMake(_sCalendar.frame.size.width+_sCalendar.frame.origin.x+lefxt, topY, 149, 35)];
     _eCalendar.popoverText.popoverTextField.placeholder=@"结果时间";
    _eCalendar.popoverText.popoverTextField.borderStyle=UITextBorderStyleRoundedRect;
    [self.view addSubview:_eCalendar];
    topY+=35+5;
    
    RangHeader *header1=[[RangHeader alloc] initWithFrame:CGRectMake(0, topY, self.view.bounds.size.width, 30)];
    header1.label.text=@"有限时间";
    [self.view addSubview:header1];
    [header1 release];
    
    topY+=30;
    
    
    _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, topY, self.view.bounds.size.width,self.view.bounds.size.height-topY-44) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.bounces=NO;
    [self.view addSubview:_tableView];
    
    LoginButtons *buttons=[[LoginButtons alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    [buttons.cancel setTitle:@"上一步" forState:UIControlStateNormal];
    [buttons.submit setTitle:@"完成" forState:UIControlStateNormal];
    [buttons.cancel addTarget:self action:@selector(buttonPrevClick) forControlEvents:UIControlEventTouchUpInside];
    [buttons.submit addTarget:self action:@selector(buttonSubmitClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttons];
    [buttons release];
    
    self.cells=[NSMutableArray array];
    self.cellChilds=[NSMutableDictionary dictionary];
    for (int i=0; i<7; i++) {
        TKAreaWeekCell *cell=[[TKAreaWeekCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.label.text=[NSString stringWithFormat:@"星期%@",[dicWeeks objectForKey:[NSString stringWithFormat:@"%d",i+1]]];
        cell.index=i;
        [self.cells addObject:cell];
        [cell release];
        
        TKAreaRangeCell *cell1=[[TKAreaRangeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell1.deleteButton.hidden=YES;
        cell1.index=i;
        [cell1.button addTarget:self action:@selector(buttonAddRowClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.cellChilds setValue:[NSMutableArray arrayWithObjects:cell1, nil] forKey:[NSString stringWithFormat:@"%d",i]];
        [cell1 release];
    }
    
}
- (int)getCellRow:(TKAreaRangeCell*)cell{
    NSIndexPath *indexPath=[_tableView indexPathForCell:cell];
    int row=indexPath.row-1;
    id v=self.cells[row];
    int total=0;
    
    while (![v isKindOfClass:[TKAreaWeekCell class]]) {
        row--;
        v=self.cells[row];
        total++;
    }
    return total;
}
- (NSDictionary*)getRuleTimeXml{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    for (int i=0; i<self.cells.count; i++) {
        if ([self.cells[i] isKindOfClass:[TKAreaWeekCell class]]) {
            TKAreaWeekCell *cell=self.cells[i];
            [dic setValue:cell.hasSelected?@"1":@"0" forKey:[NSString stringWithFormat:@"%d",cell.index]];
        }
    }
    return dic;
}
- (NSString*)RuleDataXml{
    NSMutableString *xml=[NSMutableString stringWithFormat:@"<string>%@</string>",self.AreaId];
    [xml appendFormat:@"<string>%@</string>",_sCalendar.popoverText.popoverTextField.text];
    [xml appendFormat:@"<string>%@</string>",_eCalendar.popoverText.popoverTextField.text];
    
    NSDictionary *dic=[self getRuleTimeXml];
    
    [xml appendFormat:@"<string>%@</string>",[dic objectForKey:@"6"]];//星期天
    [xml appendFormat:@"<string>%@</string>",[dic objectForKey:@"0"]];//星期一
    [xml appendFormat:@"<string>%@</string>",[dic objectForKey:@"1"]];//星期二
    [xml appendFormat:@"<string>%@</string>",[dic objectForKey:@"2"]];//星期三
    [xml appendFormat:@"<string>%@</string>",[dic objectForKey:@"3"]];//星期四
    [xml appendFormat:@"<string>%@</string>",[dic objectForKey:@"4"]];//星期五
    [xml appendFormat:@"<string>%@</string>",[dic objectForKey:@"5"]];//星期六
    
    [xml appendFormat:@"<string>%@</string>",self.RuleId];
    return xml;
    
}
//新增行
- (void)buttonAddRowClick:(id)sender{
    UIButton *btn=(UIButton*)sender;
    id v=[btn superview];
    while (![v isKindOfClass:[TKAreaRangeCell class]]) {
        v=[v superview];
    }
    TKAreaRangeCell *cell=(TKAreaRangeCell*)v;
    NSIndexPath *indexPath=[_tableView indexPathForCell:cell];

    NSString *key=[NSString stringWithFormat:@"%d",cell.index];
    NSMutableArray *source=[self.cellChilds objectForKey:key];
    
    TKAreaRangeCell *cell1=[[TKAreaRangeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell1.button.hidden=YES;
    cell1.index=cell.index;
    [cell1.deleteButton addTarget:self action:@selector(buttonDeleteRowClick:) forControlEvents:UIControlEventTouchUpInside];
    [source addObject:cell1];
    [cell1 release];
    
    TKAreaWeekCell *weekCell=self.cells[indexPath.row-1];
     indexPath=[_tableView indexPathForCell:weekCell];
    if (weekCell.isOpen) {//打开状态
        [self.cells insertObject:[source lastObject] atIndex:indexPath.row+source.count];
        NSIndexPath *insertPath=[NSIndexPath indexPathForRow:indexPath.row+source.count inSection:0];
        [_tableView beginUpdates];
        [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:insertPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
    }
}
//删除行
- (void)buttonDeleteRowClick:(id)sender{
    UIButton *btn=(UIButton*)sender;
    id v=[btn superview];
    while (![v isKindOfClass:[TKAreaRangeCell class]]) {
        v=[v superview];
    }
    TKAreaRangeCell *cell=(TKAreaRangeCell*)v;
    NSIndexPath *indexPath=[_tableView indexPathForCell:cell];
    
    NSString *key=[NSString stringWithFormat:@"%d",cell.index];
    NSMutableArray *source=[self.cellChilds objectForKey:key];
    [source removeObjectAtIndex:[self getCellRow:cell]];
    //删除
    [self.cells removeObjectAtIndex:indexPath.row];
    [_tableView beginUpdates];
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    [_tableView endUpdates];
}
//上一步
- (void)buttonPrevClick{
    [self.navigationController popViewControllerAnimated:YES];
}
//完成
- (void)buttonSubmitClick:(id)sender{
    
    if ([_sCalendar.popoverText.popoverTextField.text length]==0) {
        [AlertHelper initWithTitle:@"提示" message:@"请选择有限日期开始时间!"];
        return;
    }
    if ([_eCalendar.popoverText.popoverTextField.text length]==0) {
        [AlertHelper initWithTitle:@"提示" message:@"请选择有限日期结速时间!"];
        return;
    }
    
    Account *acc=[Account unarchiverAccount];
    NSMutableArray *params=[NSMutableArray array];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[self RuleDataXml],@"RuleData", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"EnableDay", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:acc.WorkNo,@"Workno", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"CompanyID", nil]];
    
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.methodName=@"SaveRuleDateAndTime";
    args.soapParams=params;
    [self showLoadingAnimatedWithTitle:@"正在执行,请稍后..."];
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        BOOL boo=NO;
        NSDictionary *dic=[result json];
        if(dic!=nil)
        {
            if([[dic objectForKey:@"Result"] isEqualToString:@"Success"])
            {
                boo=YES;
                [self hideLoadingViewAnimated:^(AnimateLoadView *hideView) {
                     [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
                }];
            }
        }
        if (!boo) {
            [self hideLoadingFailedWithTitle:@"完成失败!" completed:nil];
        }
    } failed:^(NSError *error, NSDictionary *userInfo) {
        [self hideLoadingFailedWithTitle:@"完成失败!" completed:nil];
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - table source & delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.cells count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=self.cells[indexPath.row];
    if (![cell isKindOfClass:[TKAreaWeekCell class]]) {
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TKAreaWeekCell *cell=self.cells[indexPath.row];
    NSString *key=[NSString stringWithFormat:@"%d",cell.index];
    NSArray *source=[self.cellChilds objectForKey:key];
    if (cell.isOpen) {//隐藏
        [cell setOpen:NO];
        NSMutableArray *indexPaths=[NSMutableArray array];
        for (int i=0; i<source.count; i++) {
            [self.cells removeObjectAtIndex:indexPath.row+i+1];
            [indexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row+i+1 inSection:0]];
        }
        [_tableView beginUpdates];
        [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        [_tableView endUpdates];
    }else{//显示
        [cell setOpen:YES];
        NSMutableArray *indexPaths=[NSMutableArray array];
        for (int i=0; i<source.count; i++) {
            [self.cells insertObject:[source objectAtIndex:i] atIndex:indexPath.row+i+1];
            [indexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row+i+1 inSection:0]];
        }
        [_tableView beginUpdates];
        [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        [_tableView endUpdates];
    }
}
@end
