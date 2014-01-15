//
//  TrajectoryMessageController.m
//  LocationService
//
//  Created by aJia on 2013/12/26.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "TrajectoryMessageController.h"
#import "MessageCell.h"
#import "TrajectoryMessage.h"
#import "LoginButtons.h"
#import "Account.h"
#import "AppHelper.h"
#import "AppUI.h"
#import "ReadMessageViewController.h"
#import "ExceptionViewController.h"
@interface TrajectoryMessageController (){
    LoginButtons *_toolBar;
}
- (void)loadData;
- (void)buttonEditClick:(id)sender;
- (void)buttonRemoveClick:(id)sender;
- (void)buttonReadClick:(id)sender;
- (BOOL)existsFindyById:(NSString*)msgId;
- (NSString*)findByMessageId:(NSString*)msgId;
@end

@implementation TrajectoryMessageController
- (void)dealloc{
    [super dealloc];
    [_toolBar release];
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
    [self.navBarView setNavBarTitle:[NSString stringWithFormat:@"%@--信息",self.Entity.Name]];
    
    if (![self.navBarView viewWithTag:300]) {
        UIButton *btn=[AppUI createhighlightButtonWithTitle:@"历史" frame:CGRectMake(self.view.bounds.size.width-90, (44-35)/2, 50, 35)];
        btn.tag=300;
        [btn addTarget:self action:@selector(buttonHistoryClick) forControlEvents:UIControlEventTouchUpInside];
        [self.navBarView addSubview:btn];
    }
    if (![self.navBarView viewWithTag:301]) {
        UIButton *btn=[AppUI createhighlightButtonWithTitle:@"编辑" frame:CGRectMake(self.view.bounds.size.width-50, (44-35)/2, 50, 35)];
        btn.tag=301;
        [btn addTarget:self action:@selector(buttonEditClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.navBarView addSubview:btn];
    }
    if (curPage==0) {
        if (self.Entity&&self.Entity.ID&&[self.Entity.ID length]>0) {
            [_tableView launchRefreshing];
        }else{
            if (self.cells&&[self.cells count]>0) {
                [self.cells removeAllObjects];
            }else{
                self.cells=[NSMutableArray array];
            }
            [_tableView reloadData];
        }
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect r=self.view.bounds;
    r.origin.y=44;
    r.size.height-=44;
    
    _tableView =[[PullingRefreshTableView alloc] initWithFrame:r pullingDelegate:self];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    [self.view addSubview:_tableView];
    
    CGFloat topY=self.view.bounds.size.height+44;
    _toolBar=[[LoginButtons alloc] initWithFrame:CGRectMake(0, topY, self.view.bounds.size.width, 44)];
    [_toolBar.cancel setTitle:@"删除(0)" forState:UIControlStateNormal];
    [_toolBar.submit setTitle:@"标记已读(0)" forState:UIControlStateNormal];
    [_toolBar.cancel addTarget:self action:@selector(buttonRemoveClick:) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar.submit addTarget:self action:@selector(buttonReadClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_toolBar];
    
    curPage=0;
    pageSize=10;
}
//进入已读取信息列表
- (void)buttonHistoryClick{
    ReadMessageViewController *read=[[ReadMessageViewController alloc] init];
    read.Entity=self.Entity;
    [self.navigationController pushViewController:read animated:YES];
    [read release];
}
- (void)receiveParams:(SupervisionPerson*)entity{
    self.Entity=entity;
    curPage=0;
    pageSize=10;
}
- (BOOL)canShowMessage{
    if (self.Entity&&self.Entity.ID&&[self.Entity.ID length]>0) {
        return YES;
    }
    return NO;
}
- (BOOL)existsFindyById:(NSString*)msgId{
    if (self.cells&&[self.cells count]>0) {
        NSString *match=[NSString stringWithFormat:@"SELF.ID =='%@'",msgId];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:match];
        NSArray *results = [self.cells filteredArrayUsingPredicate:predicate];
        if (results&&[results count]>0) {
            return YES;
        }
    }
    return NO;
}
- (NSString*)findByMessageId:(NSString*)msgId{
    if (self.cells&&[self.cells count]>0) {
        NSString *match=[NSString stringWithFormat:@"SELF.ID =='%@'",msgId];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:match];
        NSArray *results = [self.cells filteredArrayUsingPredicate:predicate];
        if (results&&[results count]>0) {
            TrajectoryMessage *item=[results objectAtIndex:0];
            return item.PCTime;
        }
    }
    return @"";
}
//删除
- (void)buttonRemoveClick:(id)sender{
    if (self.removeList&&[self.removeList count]>0) {
        
        NSMutableArray *delSource=[NSMutableArray array];
        for (NSIndexPath *item in [self.removeList allValues]) {
            [delSource addObject:self.cells[item.row]];
        }
        
        NSMutableArray *ids=[NSMutableArray array];
        for (NSString *msgid in self.removeList.allKeys) {
            [ids addObject:[NSString stringWithFormat:@"%@,%@",msgid,[self findByMessageId:msgid]]];
        }
        
        NSMutableArray *params=[NSMutableArray array];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[ids componentsJoinedByString:@"$"],@"idAndTime", nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"type", nil]];
        //[params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"time", nil]];
        
        ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
        args.serviceURL=DataWebservice1;
        args.serviceNameSpace=DataNameSpace1;
        args.methodName=@"DelPersonMsg";
        args.soapParams=params;
        [self showLoadingAnimatedWithTitle:@"正在删除,请稍后..."];
        [self.serviceHelper asynService:args success:^(ServiceResult *result) {
            BOOL boo=NO;
            if (result.hasSuccess) {
                NSDictionary *dic=[result json];
                if (dic!=nil&&[[dic objectForKey:@"Result"] isEqualToString:@"true"]) {
                    boo=YES;
                    [self.cells removeObjectsInArray:delSource];
                    [_tableView beginUpdates];
                    [_tableView deleteRowsAtIndexPaths:[self.removeList allValues] withRowAnimation:UITableViewRowAnimationFade];
                    [_tableView endUpdates];
                    //更新操作
                    [self.readList removeAllObjects];
                    [self.removeList removeAllObjects];
                    [_toolBar.submit setTitle:@"标记已读(0)" forState:UIControlStateNormal];//更新操作
                    [_toolBar.cancel setTitle:@"删除(0)" forState:UIControlStateNormal];//更新操作
                    [self hideLoadingSuccessWithTitle:@"删除成功!" completed:nil];
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
//标记已读
- (void)buttonReadClick:(id)sender{
    if (self.readList&&[self.readList count]>0) {
        NSMutableArray *delSource=[NSMutableArray array];
        for (NSIndexPath *item in [self.removeList allValues]) {
            [delSource addObject:self.cells[item.row]];
        }
        
        
        UIButton *btn=(UIButton*)sender;
        btn.enabled=NO;
        ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
        args.serviceURL=DataWebservice1;
        args.serviceNameSpace=DataNameSpace1;
        args.methodName=@"BatchHandleAlarmData";
        args.soapParams=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:[self.readList.allKeys componentsJoinedByString:@","],@"id", nil], nil];
        [self showLoadingAnimatedWithTitle:@"正在标记已读操作,请稍后..."];
        [self.serviceHelper asynService:args success:^(ServiceResult *result) {
            btn.enabled=YES;
            BOOL boo=NO;
            if (result.hasSuccess) {
                NSDictionary *dic=(NSDictionary*)[result json];
                if (dic!=nil&&[[dic objectForKey:@"Result"] isEqualToString:@"true"]) {
                    boo=YES;
                }
            }
            if (boo) {
                [self.cells removeObjectsInArray:delSource];
                [_tableView beginUpdates];
                [_tableView deleteRowsAtIndexPaths:[self.readList allValues] withRowAnimation:UITableViewRowAnimationFade];
                [_tableView endUpdates];
                
                [self.readList removeAllObjects];
                [self.removeList removeAllObjects];
                [_toolBar.submit setTitle:@"标记已读(0)" forState:UIControlStateNormal];//更新操作
                [_toolBar.cancel setTitle:@"删除(0)" forState:UIControlStateNormal];//更新操作
                [self hideLoadingSuccessWithTitle:@"标记已读操作成功!" completed:nil];
            }else{
                [self hideLoadingFailedWithTitle:@"标记已读操作失败!" completed:nil];
            }
            
        } failed:^(NSError *error, NSDictionary *userInfo) {
            btn.enabled=YES;
            [self hideLoadingFailedWithTitle:@"标记已读操作失败!" completed:nil];
        }];
    }
}
//编辑
- (void)buttonEditClick:(id)sender{
    UIButton *btn=(UIButton*)sender;
    [_tableView setEditing:!_tableView.editing animated:YES];
    if(_tableView.editing){//编辑
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
	else {//取消
        if (self.readList&&[self.readList count]>0) {
            [self.readList removeAllObjects];
            [_toolBar.submit setTitle:@"标记已读(0)" forState:UIControlStateNormal];
        }
        if (self.removeList&&[self.removeList count]>0) {
            [self.removeList removeAllObjects];
            [_toolBar.cancel setTitle:@"删除(0)" forState:UIControlStateNormal];
        }
        
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
//加载数据
- (void)loadData{
    curPage++;
    
    Account *acc=[Account unarchiverAccount];
    NSMutableArray *params=[NSMutableArray array];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:acc.WorkNo,@"workno", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.Entity.ID,@"personid", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",curPage],@"curPage", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",pageSize],@"pageSize", nil]];
    
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.methodName=@"GetPersonAlarmDataPage";
    args.soapParams=params;
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        [_tableView tableViewDidFinishedLoading];
        _tableView.reachedTheEnd  = NO;
        if (self.refreshing) {
            self.refreshing = NO;
        }
        BOOL boo=NO;
        if (result.hasSuccess) {
            NSDictionary *dic=[result json];
            if (dic!=nil) {
                NSArray *source=[dic objectForKey:@"Person"];
                NSArray *list=[AppHelper arrayWithSource:source className:@"TrajectoryMessage"];
                if (list&&[list count]>0) {
                    boo=YES;
                    if (curPage==1) {
                        self.cells=[NSMutableArray arrayWithArray:list];
                        [_tableView reloadData];
                        [self showSuccessViewWithHide:^(AnimateErrorView *successView) {
                            successView.labelTitle.text=[NSString stringWithFormat:@"更新%d笔信息!",list.count];
                        } completed:nil];
                    }else{
                        NSMutableArray *insertIndexPaths = [NSMutableArray array];
                        int total=0;
                        int s=self.cells.count;
                        for (int i=0; i<[list count]; i++) {
                            TrajectoryMessage *entity=list[i];
                            if ([self existsFindyById:entity.ID]) {continue;}
                            [self.cells addObject:[list objectAtIndex:i]];
                            NSIndexPath *newPath=[NSIndexPath indexPathForRow:s+total inSection:0];
                            [insertIndexPaths addObject:newPath];
                            total++;
                        }
                        [self showSuccessViewWithHide:^(AnimateErrorView *successView) {
                            successView.labelTitle.text=[NSString stringWithFormat:@"更新%d笔信息!",insertIndexPaths.count];
                        } completed:nil];
                        //重新呼叫UITableView的方法, 來生成行.
                        [_tableView beginUpdates];
                        [_tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                        [_tableView endUpdates];
                        [self showSuccessViewWithHide:^(AnimateErrorView *successView) {
                            successView.labelTitle.text=[NSString stringWithFormat:@"更新%d笔信息!",insertIndexPaths.count];
                        } completed:nil];
                    }
                }
               
            }
        }
        if (!boo) {
            curPage--;
            [self showErrorViewWithHide:^(AnimateErrorView *errorView) {
                errorView.labelTitle.text=@"没有更新信息哦!";
                errorView.backgroundColor=[UIColor colorFromHexRGB:@"0e4880"];
            } completed:nil];
        }
        
    } failed:^(NSError *error, NSDictionary *userInfo) {
        curPage--;
        [self showErrorViewWithHide:^(AnimateErrorView *errorView) {
            errorView.labelTitle.text=@"没有更新信息哦!";
            errorView.backgroundColor=[UIColor colorFromHexRGB:@"0e4880"];
        } completed:nil];
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
    static NSString *cellIdentifier=@"messageCell";
    MessageCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        //cell.monitorView.controler=self;
    }
    TrajectoryMessage *entity=self.cells[indexPath.row];
    [cell.messageView setDataSource:entity];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TrajectoryMessage *entity=self.cells[indexPath.row];
    if (entity.Address&&[entity.Address length]>0) {
        CGSize size=[entity.Address textSize:[UIFont systemFontOfSize:16] withWidth:280];
        if (size.height>20) {
            return 65+size.height-20;
        }
    }
    return 65;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIButton *btn=(UIButton*)[self.navBarView viewWithTag:301];
    if ([btn.currentTitle isEqualToString:@"编辑"]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        ExceptionViewController *control=[[ExceptionViewController alloc] init];
        control.Entity=self.cells[indexPath.row];
        [self.navigationController pushViewController:control animated:YES];
        [control release];
    }else{
        if (!self.removeList) {
            self.removeList=[NSMutableDictionary dictionary];
        }
        if (!self.readList) {
            self.readList=[NSMutableDictionary dictionary];
        }
        TrajectoryMessage *entity=self.cells[indexPath.row];
        [self.removeList setValue:indexPath forKey:entity.ID];
        [self.readList setValue:indexPath forKey:entity.ID];
        [_toolBar.cancel setTitle:[NSString stringWithFormat:@"删除(%d)",self.removeList.count] forState:UIControlStateNormal];
        [_toolBar.submit setTitle:[NSString stringWithFormat:@"标记已读(%d)",self.readList.count] forState:UIControlStateNormal];
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIButton *btn=(UIButton*)[self.navBarView viewWithTag:301];
    if ([btn.currentTitle isEqualToString:@"取消"]) {
        TrajectoryMessage *entity=self.cells[indexPath.row];
        [self.removeList removeObjectForKey:entity.ID];
        [self.readList removeObjectForKey:entity.ID];
        [_toolBar.cancel setTitle:[NSString stringWithFormat:@"删除(%d)",self.removeList.count] forState:UIControlStateNormal];
        [_toolBar.submit setTitle:[NSString stringWithFormat:@"标记已读(%d)",self.readList.count] forState:UIControlStateNormal];
    }
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
}
#pragma mark - PullingRefreshTableViewDelegate
//下拉加载
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    self.refreshing = YES;
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.f];
}
//上拉加载
- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.f];
}
#pragma mark - Scroll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_tableView tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_tableView tableViewDidEndDragging:scrollView];
}
@end
