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
#import "AreaTimeSpan.h"
#import "AppHelper.h"
#import "NSDate+TPCategory.h"
#define  dicWeeks [NSDictionary dictionaryWithObjectsAndKeys:@"一",@"1",@"二",@"2",@"三",@"3",@"四",@"4",@"五",@"5",@"六",@"6",@"日",@"7", nil]
@interface AreaRangeViewController ()<UITableViewDataSource,UITableViewDelegate>{
    CVUICalendar *_sCalendar;
    CVUICalendar *_eCalendar;
    UITableView *_tableView;
}
- (int)getCellRow:(TKAreaRangeCell*)cell;
- (NSString*)RuleDataXml;
- (NSDictionary*)getRuleTimeXml;
- (NSString*)enableDayTimeXml;
- (BOOL)existsLimitedTime;
- (void)queueLoading;
- (void)handlerLimitWithArray:(NSArray*)source week:(NSString*)key;
- (void)setSelectedCellWithWeek:(int)week;
- (void)updateOrderCellRow;
- (void)closedOpenCellRow:(NSMutableDictionary*)dic;
@end

@implementation AreaRangeViewController
- (void)dealloc{
    [super dealloc];
    [_sCalendar.popoverText.popoverTextField removeObserver:self forKeyPath:@"text"];
    [_eCalendar.popoverText.popoverTextField removeObserver:self forKeyPath:@"text"];
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
    
    [self queueLoading];//修改时，加载资料
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
    NSDate *date=[NSDate date];
    _sCalendar=[[CVUICalendar alloc] initWithFrame:CGRectMake(lefxt, topY, 149, 35)];
    _sCalendar.popoverText.popoverTextField.placeholder=@"开始时间";
    _sCalendar.popoverText.popoverTextField.text=[NSDate stringFromDate:date withFormat:@"yyyy-MM-dd"];
    _sCalendar.popoverView.popoverTitle=@"开始时间";
    _sCalendar.popoverView.clearButtonTitle=@"取消";
    _sCalendar.isClearEmpty=NO;
    //添加事件监听事件
    [_sCalendar.popoverText.popoverTextField addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self.view addSubview:_sCalendar];
    

    NSDate *date1=[date dateByAddingDays:6];
    _eCalendar=[[CVUICalendar alloc] initWithFrame:CGRectMake(_sCalendar.frame.size.width+_sCalendar.frame.origin.x+lefxt, topY, 149, 35)];
     _eCalendar.popoverText.popoverTextField.placeholder=@"结束时间";
    _eCalendar.popoverText.popoverTextField.text=[NSDate stringFromDate:date1 withFormat:@"yyyy-MM-dd"];
    _eCalendar.popoverView.popoverTitle=@"结束时间";
    _eCalendar.popoverView.clearButtonTitle=@"取消";
    _eCalendar.isClearEmpty=NO;
    //添加属性事件监听
    [_eCalendar.popoverText.popoverTextField addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
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
    int weekDay=1;
    for (int i=0; i<7; i++) {
        if (i==0) {
            weekDay=[date dayOfWeek];
        }else{
            weekDay=[[date dateByAddingDays:i] dayOfWeek];
        }
        TKAreaWeekCell *cell=[[TKAreaWeekCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.label.text=[NSString stringWithFormat:@"星期%@",[dicWeeks objectForKey:[NSString stringWithFormat:@"%d",weekDay]]];
        cell.index=weekDay-1;//星期几
        cell.Sort=i;
        [cell setSelectedWeek:NO];
        [self.cells addObject:cell];
        [cell release];
        
        TKAreaRangeCell *cell1=[[TKAreaRangeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell1.deleteButton.hidden=YES;
        cell1.index=weekDay-1;//星期几
        [cell1.button addTarget:self action:@selector(buttonAddRowClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.cellChilds setValue:[NSMutableArray arrayWithObjects:cell1, nil] forKey:[NSString stringWithFormat:@"%d",weekDay-1]];
        [cell1 release];
    }
}
- (void)closedOpenCellRow:(NSMutableDictionary*)dic{
    int total=self.cells.count;
    for (int i=0; i<total; i++) {
        id v=self.cells[i];
        if ([v isKindOfClass:[TKAreaWeekCell class]]) {
            TKAreaWeekCell *cell=(TKAreaWeekCell*)v;
            cell.Sort=[[dic objectForKey:[NSString stringWithFormat:@"%d",cell.index]] intValue];
            if (cell.isOpen) {
                NSIndexPath *indexPath=[_tableView indexPathForCell:cell];
                [self tableView:_tableView didSelectRowAtIndexPath:indexPath];
                total=self.cells.count;
                
            }
        }
    }
}
//更新顺序
- (void)updateOrderCellRow{
   
    //起始时间
    NSDate *sdate=[NSDate dateFromString:_sCalendar.popoverText.popoverTextField.text withFormat:@"yyyy-MM-dd"];
    int weekDay=[sdate dayOfWeek]-1;
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setValue:@"0" forKey:[NSString stringWithFormat:@"%d",weekDay]];
    for (int a=1; a<7; a++) {
        weekDay=[[sdate dateByAddingDays:a] dayOfWeek]-1;
        [dic setValue:[NSString stringWithFormat:@"%d",a] forKey:[NSString stringWithFormat:@"%d",weekDay]];
    }
    [self closedOpenCellRow:dic];
    
    if (self.cells&&[self.cells count]>0) {
        NSComparator cmptr = ^(id obj1, id obj2){
            TKAreaWeekCell *field1=(TKAreaWeekCell*)obj1;
            TKAreaWeekCell *field2=(TKAreaWeekCell*)obj2;
            if (field1.Sort>field2.Sort) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if (field1.Sort<field2.Sort) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        };
        //第一种排序
        self.cells=[NSMutableArray arrayWithArray:[self.cells sortedArrayUsingComparator:cmptr]];
        [_tableView reloadData];
        
        
        // NSSortDescriptor *_sorter  = [[NSSortDescriptor alloc] initWithKey:@"Sort" ascending:YES];
        // NSArray *sortArr=[self.Fields sortedArrayUsingDescriptors:[NSArray arrayWithObjects:_sorter, nil]];
        // return sortArr;
    }

}
//事件改变事件
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
   
    if (![[change objectForKey:@"new"] isEqualToString:[change objectForKey:@"old"]]) {//处理改变事件
        id v=[object superview];
        while (![v isKindOfClass:[CVUICalendar class]]) {
            v=[v superview];
        }
        CVUICalendar *_calendar=(CVUICalendar*)v;
        if (_sCalendar==_calendar) {
            NSDate *date=[NSDate dateFromString:_sCalendar.popoverText.popoverTextField.text withFormat:@"yyyy-MM-dd"];
            NSDate *date1=[date dateByAddingDays:6];
            _eCalendar.popoverText.popoverTextField.text=[NSDate stringFromDate:date1 withFormat:@"yyyy-MM-dd"];
        }else{
             NSDate *date=[NSDate dateFromString:_eCalendar.popoverText.popoverTextField.text withFormat:@"yyyy-MM-dd"];
             NSDate *date1=[date dateByAddingDays:-6];
            _sCalendar.popoverText.popoverTextField.text=[NSDate stringFromDate:date1 withFormat:@"yyyy-MM-dd"];
        }
        //更新tableview
        [self updateOrderCellRow];
    }
}
- (void)setSelectedCellWithWeek:(int)week{
    for (int i=0; i<self.cells.count; i++) {
        id v=self.cells[i];
        if ([v isKindOfClass:[TKAreaWeekCell class]]) {
            TKAreaWeekCell *cell=(TKAreaWeekCell*)v;
            if (cell.index==week) {
                [cell setSelectedWeek:YES];
                if (cell.isOpen) {//打开的
                    NSIndexPath *indexPath=[_tableView indexPathForCell:cell];
                    int total=0;
                    int row=indexPath.row;
                    id elem=self.cells[row+1];
                    while (![elem isKindOfClass:[TKAreaWeekCell class]]) {
                        row++;
                        total++;
                        if (row>self.cells.count-1) {
                            break;
                        }
                        elem=self.cells[row];
                    }
                    NSMutableArray *source=[self.cellChilds objectForKey:[NSString stringWithFormat:@"%d",week]];
                    if (source.count-total>0) {
                        NSMutableArray *inserts=[NSMutableArray array];
                        for (int s=total; s<source.count; s++) {
                            [self.cells insertObject:[source objectAtIndex:s] atIndex:indexPath.row+s+1];
                            [inserts addObject:[NSIndexPath indexPathForRow:indexPath.row+s+1 inSection:0]];
                        }
                        [_tableView beginUpdates];
                        [_tableView insertRowsAtIndexPaths:inserts withRowAnimation:UITableViewRowAnimationFade];
                        [_tableView endUpdates];
                    }
                
                }
                break;
            }
        }
    }
}
//处理
- (void)handlerLimitWithArray:(NSArray*)source week:(NSString*)key{
    NSMutableArray *arr=[self.cellChilds objectForKey:key];
    NSArray *items=[AppHelper arrayWithSource:source className:@"AreaTimeSpan"];
    int total=0;
    for (AreaTimeSpan *k in items) {
        if (total==0) {
            TKAreaRangeCell *cell=arr[total];
            cell.startField.popoverText.popoverTextField.text=k.starTime;
            cell.endField.popoverText.popoverTextField.text=k.endTime;
            continue;
        }
        TKAreaRangeCell *cell1=[[TKAreaRangeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell1.button.hidden=YES;
        cell1.index=[key intValue];
        cell1.startField.popoverText.popoverTextField.text=k.starTime;
        cell1.endField.popoverText.popoverTextField.text=k.endTime;
        [cell1.deleteButton addTarget:self action:@selector(buttonDeleteRowClick:) forControlEvents:UIControlEventTouchUpInside];
        [arr addObject:cell1];
        [cell1 release];
        total++;
    }
    [self setSelectedCellWithWeek:[key intValue]];
}
//队列请求处理
- (void)queueLoading{
    if (self.AreaId&&[self.AreaId length]>0) {
        for (int i=1; i<8; i++) {
            NSMutableArray *params=[NSMutableArray array];
            [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",i],@"weekday", nil]];
            [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.AreaId,@"lineid", nil]];
            
            ServiceArgs *args=[[ServiceArgs alloc] init];
            args.methodName=@"GetAreaWeekTime";
            args.serviceURL=DataWebservice1;
            args.serviceNameSpace=DataNameSpace1;
            args.soapParams=params;
            ASIHTTPRequest *request=[ServiceHelper commonSharedRequest:args];
            [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",i-1],@"name", nil]];
            [self.serviceHelper addQueue:request];
            [args release];
            
        }
        [self.serviceHelper startQueue:nil failed:nil complete:^(NSArray *results) {
            NSString *start=@"",*end=@"";
            for (ServiceResult *result in results) {
                NSString *key=[[result userInfo] objectForKey:@"name"];
                NSDictionary *dic=[result json];
                if (dic!=nil) {
                    NSArray *arr=[dic objectForKey:@"TimeSpanList"];
                    if ([key isEqualToString:@"0"]&&arr&&[arr count]>0) {
                        start=[arr[0] objectForKey:@"validSTime"];
                    }
                    if ([key isEqualToString:@"6"]&&arr&&[arr count]>0) {
                       end=[arr[0] objectForKey:@"validSTime"];
                    }
                    [self handlerLimitWithArray:arr week:key];
                }
            }
            if ([start length]>0) {
                NSDate *date1=[NSDate dateFromString:start withFormat:@"yyyy-MM-dd HH:mm"];
                _sCalendar.popoverText.popoverTextField.text=[NSDate stringFromDate:date1 withFormat:@"yyyy-MM-dd"];
            }
            if ([end length]>0) {
                NSDate *date2=[NSDate dateFromString:end withFormat:@"yyyy-MM-dd HH:mm"];
                _eCalendar.popoverText.popoverTextField.text=[NSDate stringFromDate:date2 withFormat:@"yyyy-MM-dd"];
            }
        }];
        
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
- (BOOL)existsLimitedTime{
    NSDictionary *dic=[self getRuleTimeXml];
    if ([dic count]>0) {
        NSArray *source=[dic allValues];
        if ([source containsObject:@"1"]) {
            return YES;
        }
    }
    return NO;
}
- (NSString*)enableDayTimeXml{
    if (self.cellChilds&&[self.cellChilds count]>0) {
        NSMutableDictionary *source=[NSMutableDictionary dictionary];
        for (NSString *key in self.cellChilds.allKeys) {
            NSArray *arr=[self.cellChilds objectForKey:key];
            NSMutableArray *xml=[NSMutableArray array];
            for (TKAreaRangeCell *item in arr) {
                if ([[item timeSlot] length]>0) {
                    [xml addObject:[item timeSlot]];
                }
            }
            [source setValue:[xml componentsJoinedByString:@","] forKey:key];
        }
        NSMutableString *result=[NSMutableString stringWithFormat:@"<string>%@</string>",[source objectForKey:@"6"]];
        [result appendFormat:@"<string>%@</string>",[source objectForKey:@"0"]];
        [result appendFormat:@"<string>%@</string>",[source objectForKey:@"1"]];
        [result appendFormat:@"<string>%@</string>",[source objectForKey:@"2"]];
        [result appendFormat:@"<string>%@</string>",[source objectForKey:@"3"]];
        [result appendFormat:@"<string>%@</string>",[source objectForKey:@"4"]];
        [result appendFormat:@"<string>%@</string>",[source objectForKey:@"5"]];
        return result;
    }
    return @"";
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
    if (![self existsLimitedTime]) {
        [AlertHelper initWithTitle:@"提示" message:@"请至少选择一项有限时间!"];
        return;
    }
    
    Account *acc=[Account unarchiverAccount];
    NSMutableArray *params=[NSMutableArray array];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[self RuleDataXml],@"RuleData", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[self enableDayTimeXml],@"EnableDay", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:acc.WorkNo,@"Workno", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"CompanyID", nil]];
    
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.methodName=@"SaveRuleDateAndTime";
    args.soapParams=params;
    NSLog(@"soap=%@",args.soapMessage);
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
    if ([self.cells[indexPath.row] isKindOfClass:[TKAreaRangeCell class]]) {
        return;
    }
    TKAreaWeekCell *cell=self.cells[indexPath.row];
    NSString *key=[NSString stringWithFormat:@"%d",cell.index];
    NSArray *source=[self.cellChilds objectForKey:key];
    if (cell.isOpen) {//隐藏
        [cell setOpen:NO];
        NSMutableArray *indexPaths=[NSMutableArray array];
         [self.cells removeObjectsInRange:NSMakeRange(indexPath.row+1, source.count)];
        for (int i=0; i<source.count; i++) {
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
