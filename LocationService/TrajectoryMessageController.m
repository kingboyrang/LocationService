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
@interface TrajectoryMessageController (){
    LoginButtons *_toolBar;
}
- (void)loadData;
- (void)buttonEditClick:(id)sender;
- (void)buttonRemoveClick:(id)sender;
- (void)buttonReadClick:(id)sender;
@end

@implementation TrajectoryMessageController

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
- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect r=self.view.bounds;
    r.origin.y=44;
    _tableView =[[PullingRefreshTableView alloc] initWithFrame:r pullingDelegate:self];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_tableView];
    
    _toolBar=[[LoginButtons alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, self.view.bounds.size.width, 44)];
    [_toolBar.cancel setTitle:@"删除(0)" forState:UIControlStateNormal];
    [_toolBar.submit setTitle:@"标记已读(0)" forState:UIControlStateNormal];
    [_toolBar.cancel addTarget:self action:@selector(buttonRemoveClick:) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar.submit addTarget:self action:@selector(buttonReadClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_toolBar];
    
    curPage=0;
    pageSize=10;
}
//删除
- (void)buttonRemoveClick:(id)sender{

}
//标记已读
- (void)buttonReadClick:(id)sender{
    if (self.readList&&[self.readList count]>0) {
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
                [self hideLoadingSuccessWithTitle:@"标记已读操作成功!" completed:^(AnimateErrorView *successView) {
                    NSArray *indexPaths=[self.readList allValues];
                    for (NSIndexPath *item in indexPaths) {
                        MessageCell *cell=(MessageCell*)[_tableView cellForRowAtIndexPath:item];
                        [cell.messageView setReading:YES];
                    }
                    [self.readList removeAllObjects];
                     [_toolBar.submit setTitle:@"标记已读(0)" forState:UIControlStateNormal];//更新操作
                    
                }];
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
//加载数据
- (void)loadData{

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
