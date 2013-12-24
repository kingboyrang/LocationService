//
//  SupervisionViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/24.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "SupervisionViewController.h"
#import "Account.h"
#import "SupervisionCell.h"
#import "TKMonitorCell.h"
@interface SupervisionViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
}
- (void)buttonAddClick;
- (void)buttonEditClick:(id)sender;
- (void)loadSupervision;
- (NSArray*)arrayToSupervisions:(NSArray*)source;
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
    r.size.height-=44*2;
    r.origin.y=44;
    _tableView=[[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    //_tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    //_tableView.separatorColor=[UIColor clearColor];
    //_tableView.bounces=NO;
    [self.view addSubview:_tableView];
    
    [self loadSupervision];
}
- (void)loadSupervision{
    //Account *acc=[Account unarchiverAccount];
    
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.methodName=@"GetSuperviseInfo";
    args.soapParams=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"fd7bd3c8-5671-4049-9dd9-c65cc4bfdae8",@"WorkNo", nil], nil];
    
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        if (result.hasSuccess) {
            XmlNode *node=[result methodNode];
            NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[node.InnerText dataUsingEncoding:NSUTF8StringEncoding] options:1 error:nil];
            NSArray *source=[dic objectForKey:@"Person"];
            self.cells=[self arrayToSupervisions:source];
            [_tableView reloadData];
        }
        
    } failed:^(NSError *error, NSDictionary *userInfo) {
        
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
//新增
- (void)buttonAddClick{

}
//编辑
- (void)buttonEditClick:(id)sender{
    UIButton *btn=(UIButton*)sender;
    [_tableView setEditing:!_tableView.editing animated:YES];
    if(_tableView.editing){
        [btn setTitle:@"取消" forState:UIControlStateNormal];
    }
	else {
        [btn setTitle:@"编辑" forState:UIControlStateNormal];
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
    }
    SupervisionPerson *entity=self.cells[indexPath.row];
    [cell.monitorView setDataSource:entity];
    return cell;
    /***
    SupervisionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        //通过xib的名称加载自定义的cell
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SupervisionCell" owner:self options:nil] lastObject];
    }
    SupervisionPerson *entity=self.cells[indexPath.row];
    [cell setDataSource:entity];
    
    return cell;
     **/
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 104;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
}
@end
