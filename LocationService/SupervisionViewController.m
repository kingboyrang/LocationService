//
//  SupervisionViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/24.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "SupervisionViewController.h"
#import "Account.h"
#import "TKMonitorCell.h"
#import "LoginButtons.h"
#import "AlertHelper.h"
#import "AddSupervision.h"
#import "EditSupervisionHead.h"
#import "TrajectoryViewController.h"
#import "TrajectoryMessageController.h"
#import "EditSupervisionViewController.h"
#import "CallTrajectoryViewController.h"
#import "AppUI.h"
#import "PersonTrajectoryViewController.h"
@interface SupervisionViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
    LoginButtons *_toolBar;
}
- (void)buttonAddClick;
- (void)buttonEditClick:(id)sender;
- (void)loadSupervision;
- (NSArray*)arrayToSupervisions:(NSArray*)source;
- (void)buttonSubmitRemoveClick;
- (void)buttonCancelRemoveClick;
- (SupervisionPerson*)FindById:(NSString*)guid;
- (void)deleteSupervisons;
@end

@implementation SupervisionViewController

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
    [self.navBarView setNavBarTitle:@"监管目标"];
    
    if ([self.view.subviews containsObject:self.navBarView]) {
        if (![self.navBarView viewWithTag:300]) {
            UIButton *btn=[AppUI createhighlightButtonWithTitle:@"添加" frame:CGRectMake(self.view.bounds.size.width-90, (44-35)/2, 50, 35)];
            btn.tag=300;
            [btn addTarget:self action:@selector(buttonAddClick) forControlEvents:UIControlEventTouchUpInside];
            [self.navBarView addSubview:btn];
        }
        if (![self.navBarView viewWithTag:301]) {
            UIButton *btn=[AppUI createhighlightButtonWithTitle:@"编辑" frame:CGRectMake(self.view.bounds.size.width-50, (44-35)/2, 50, 35)];
            btn.tag=301;
            [btn addTarget:self action:@selector(buttonEditClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.navBarView addSubview:btn];
        }
    }
    [self loadSupervision];//重新加载资料
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	CGRect r=self.view.bounds;
    r.size.height-=44;
    r.origin.y=44;
    _tableView=[[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    //_tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    //_tableView.separatorColor=[UIColor clearColor];
    //_tableView.bounces=NO;
    [self.view addSubview:_tableView];
    
    _toolBar=[[LoginButtons alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, self.view.bounds.size.width, 44)];
    _toolBar.cancel.hidden=YES;
    _toolBar.submit.frame=CGRectMake(0, 0, self.view.bounds.size.width, 44);
    [_toolBar.submit setTitle:@"删除(0)" forState:UIControlStateNormal];
    [_toolBar.cancel setTitle:@"清空" forState:UIControlStateNormal];
    [_toolBar.cancel addTarget:self action:@selector(buttonCancelRemoveClick) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar.submit addTarget:self action:@selector(buttonSubmitRemoveClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_toolBar];
    
    
}
- (void)loadSupervision{
    
    if (!self.hasNetWork) {
        [self showErrorNetWorkNotice:nil];
        return;
    }
    Account *acc=[Account unarchiverAccount];
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.methodName=@"GetSuperviseInfo";
    args.soapParams=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:acc.WorkNo,@"WorkNo", nil], nil];
    [self showLoadingAnimatedWithTitle:@"正在加载,请稍后..."];
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        [self hideLoadingViewAnimated:nil];
    
            NSDictionary *dic=[result json];
        if (dic!=nil) {
            NSArray *source=[dic objectForKey:@"Person"];
            //NSLog(@"source=%@",source);
            self.cells=[NSMutableArray arrayWithArray:[self arrayToSupervisions:source]];
            [_tableView reloadData];

        }
                  
    } failed:^(NSError *error, NSDictionary *userInfo) {
        [self hideLoadingFailedWithTitle:@"加载失败!" completed:nil];
    }];
}
- (NSArray*)arrayToSupervisions:(NSArray*)source{
    if (source&&[source count]>0) {
        NSMutableArray *result=[NSMutableArray arrayWithCapacity:source.count];
        for (NSDictionary *item in source) {
            SupervisionPerson *entity=[[SupervisionPerson alloc] init];
            for (NSString *k in item.allKeys) {
                SEL sel=NSSelectorFromString(k);
                if ([entity respondsToSelector:sel]) {
                    [entity setValue:[item objectForKey:k] forKey:k];
                }

            }
            [result addObject:entity];
            [entity release];
        }
        return result;
    }
    return [NSArray array];
}
-(void)supervisionEditHeadWithEntity:(SupervisionPerson*)entity{
    EditSupervisionHead *edit=[[EditSupervisionHead alloc] init];
    edit.Entity=entity;
    edit.operateType=2;//修改
    [self.navigationController pushViewController:edit animated:YES];
    [edit release];
}
-(void)supervisionMessageWithEntity:(SupervisionPerson*)entity{
    TrajectoryMessageController *message=[[TrajectoryMessageController alloc] init];
    message.Entity=entity;
    [self.navigationController pushViewController:message animated:YES];
    [message release];
}
-(void)supervisionTrajectoryWithEntity:(SupervisionPerson*)entity{
    PersonTrajectoryViewController *trajectory=[[PersonTrajectoryViewController alloc] init];
    trajectory.Entity=entity;
    [self.navigationController pushViewController:trajectory animated:YES];
    [trajectory release];
    /***
    TrajectoryViewController *trajectory=[[TrajectoryViewController alloc] init];
    trajectory.Entity=entity;
    [self.navigationController pushViewController:trajectory animated:YES];
    [trajectory release];
     ***/
}
-(void)supervisionCallWithEntity:(SupervisionPerson*)entity{
    CallTrajectoryViewController *controler=[[CallTrajectoryViewController alloc] init];
    controler.Entity=entity;
    [self.navigationController pushViewController:controler animated:YES];
    [controler release];
}
//取消删除
- (void)buttonCancelRemoveClick{
    if (self.removeList&&self.removeList.count>0) {
        NSArray *indexPaths=[[self.removeList allValues] retain];
        for (NSString *item in indexPaths) {
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[item intValue] inSection:0];
            [_tableView deselectRowAtIndexPath:indexPath animated:YES]; 
            [self tableView:_tableView didDeselectRowAtIndexPath:indexPath];
        }
        [indexPaths release];
    }else{
       [_toolBar.submit setTitle:@"删除(0)" forState:UIControlStateNormal];
    }
   
}
- (SupervisionPerson*)FindById:(NSString*)guid{
    if (self.cells&&[self.cells count]>0) {
        NSString *match=[NSString stringWithFormat:@"SELF.ID =='%@'",guid];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:match];
        NSArray *results = [self.cells filteredArrayUsingPredicate:predicate];
        if (results&&[results count]>0) {
            SupervisionPerson *item=[results objectAtIndex:0];
            return item;
        }
    }
    return nil;

}
//删除
- (void)deleteSupervisons{
    [self showLoadingAnimatedWithTitle:@"正在删除,请稍后..."];
    NSMutableArray *delSource=[NSMutableArray array];
    NSMutableArray *indexPaths=[NSMutableArray array];
    for (NSString *item in self.removeList.allKeys) {
        NSString *row=[self.removeList objectForKey:item];
        [indexPaths addObject:[NSIndexPath indexPathForRow:[row intValue] inSection:0]];
        [delSource addObject:self.cells[[row intValue]]];
    }
    NSString *ids=[NSString stringWithFormat:@"'%@'",[self.removeList.allKeys componentsJoinedByString:@"','"]];
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.methodName=@"DeletePerson";
    args.soapParams=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:ids,@"personID", nil], nil];
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        BOOL boo=NO;
        if (result.hasSuccess) {
            XmlNode *node=[result methodNode];
            NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[node.InnerText dataUsingEncoding:NSUTF8StringEncoding] options:1 error:nil];
            if ([[dic objectForKey:@"Result"] isEqualToString:@"1"]) {
                boo=YES;
                [self hideLoadingSuccessWithTitle:@"删除成功!" completed:^(AnimateErrorView *successView) {
                    [self.cells removeObjectsInArray:delSource];
                    [_tableView beginUpdates];
                    [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                    [_tableView endUpdates];
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
//确认删除
- (void)buttonSubmitRemoveClick{
    if (self.removeList&&[self.removeList count]>0) {
        [AlertHelper confirmWithTitle:@"删除" confirm:^{
            [self deleteSupervisons];
        } innnerView:self.view];
    }
}
//新增
- (void)buttonAddClick{
    AddSupervision *add=[[AddSupervision alloc] init];
    add.operateType=1;//表示新增
    [self.navigationController pushViewController:add animated:YES];
    [add release];
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
        //[self buttonCancelRemoveClick];
        if (self.removeList&&[self.removeList count]>0) {
            [self.removeList removeAllObjects];
        }
        [_toolBar.submit setTitle:@"删除(0)" forState:UIControlStateNormal];
        
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
    return self.cells.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier=@"SupervisionCell";
    TKMonitorCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[TKMonitorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.monitorView.controler=self;
    }
    SupervisionPerson *entity=self.cells[indexPath.row];
    [cell.monitorView setDataSource:entity];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 104;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIButton *btn=(UIButton*)[self.navBarView viewWithTag:301];
    if ([btn.currentTitle isEqualToString:@"编辑"]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        EditSupervisionViewController *edit=[[EditSupervisionViewController alloc] init];
        edit.Entity=self.cells[indexPath.row];
        [self.navigationController pushViewController:edit animated:YES];//修改监管目标
        [edit release];
    }else{
        if (!self.removeList) {
            self.removeList=[NSMutableDictionary dictionary];
        }
        SupervisionPerson *entity=self.cells[indexPath.row];
        [self.removeList setValue:[NSString stringWithFormat:@"%d",indexPath.row] forKey:entity.ID];
        [_toolBar.submit setTitle:[NSString stringWithFormat:@"删除(%d)",self.removeList.count] forState:UIControlStateNormal];
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    UIButton *btn=(UIButton*)[self.navBarView viewWithTag:301];
    if ([btn.currentTitle isEqualToString:@"取消"]) {
         SupervisionPerson *entity=self.cells[indexPath.row];
        [self.removeList removeObjectForKey:entity.ID];
        [_toolBar.submit setTitle:[NSString stringWithFormat:@"删除(%d)",self.removeList.count] forState:UIControlStateNormal];
    }
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
}
@end
