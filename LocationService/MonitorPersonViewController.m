//
//  MonitorPersonViewController.m
//  LocationService
//
//  Created by aJia on 2014/1/13.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import "MonitorPersonViewController.h"
#import "SupervisionPerson.h"
#import "AppHelper.h"
#import "UIImageView+WebCache.h"
#import "UIImage+TPCategory.h"
#import "IndexViewController.h"
@interface MonitorPersonViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
}
- (void)loadingMonitors:(NSString*)name message:(NSString*)msg;
@end

@implementation MonitorPersonViewController
- (void)dealloc{
    [super dealloc];
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
    [self.navBarView setNavBarTitle:@"监管目标信息"];
    
    
    UILabel *label=(UILabel*)[self.navBarView viewWithTag:200];
    CGRect r=label.frame;
    r.origin.x=25+10;
    label.frame=r;
    
    if (![self.navBarView viewWithTag:300]) {
        CGFloat leftX=self.view.bounds.size.width/2-30;
        UISearchBar *searchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(leftX, 0, self.view.bounds.size.width-leftX-3, 44)];
        searchBar.tag=300;
        searchBar.delegate = self;
        searchBar.placeholder =@"请输入名称";
        searchBar.backgroundColor=[UIColor clearColor];
        UITextField *searchField = [[searchBar subviews] lastObject];
        //[searchField setReturnKeyType:UIReturnKeyDone];
        searchField.clearButtonMode=UITextFieldViewModeNever;
        for (UIView *subview in searchBar.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
                [subview removeFromSuperview];
                break;
            }
        }
        //为UISearchBar添加背景图片
        [self.navBarView addSubview:searchBar];
        [searchBar release];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect r=self.view.bounds;
    r.origin.y=44;
    r.size.height-=44;
    
    _tableView=[[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    [self.view addSubview:_tableView];
    
    [self loadingMonitors:@"" message:@"加载"];
}
- (void)loadingMonitors:(NSString*)name message:(NSString*)msg{
    if (![self hasNetWork]) {
        [self showErrorNetWorkNotice:nil];
        return;
    }
    
    Account *acc=[Account unarchiverAccount];
    NSMutableArray *params=[NSMutableArray array];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:acc.WorkNo,@"WorkNo", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:name,@"nameStr", nil]];
    
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.methodName=@"GetMonitorPersonInfo";
    args.soapParams=params;
    [self showLoadingAnimatedWithTitle:[NSString stringWithFormat:@"正在%@,请稍后...",msg]];
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        BOOL boo=NO;
        NSDictionary *dic=[result json];
        if (dic!=nil) {
            [self hideLoadingViewAnimated:nil];
            boo=YES;
            NSArray *source=[dic objectForKey:@"Person"];
            self.list=[AppHelper arrayWithSource:source className:@"SupervisionPerson"];
            [_tableView reloadData];
        }
        if (!boo) {
            [self hideLoadingFailedWithTitle:[NSString stringWithFormat:@"%@失败!",msg] completed:nil];
        }
        
    } failed:^(NSError *error, NSDictionary *userInfo) {
        [self hideLoadingFailedWithTitle:[NSString stringWithFormat:@"%@失败!",msg] completed:nil];
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma  mark -searchbar
/***
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    searchBar.showsCancelButton=YES;
    for (id cc in searchBar.subviews) {
        if([cc isKindOfClass:[UIButton class]]){
            UIButton *btn=(UIButton *)cc;
            [btn setTitle:@"取消" forState:UIControlStateNormal];
        }
    }
    return YES;
}
 **/
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.text=@"";
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton=NO;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self loadingMonitors:searchBar.text message:@"查询"];//查询
    //searchBar.showsCancelButton=NO;
}
#pragma mark UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.list count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"carCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        
    }
    SupervisionPerson *entity=self.list[indexPath.row];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id v=self.navigationController.viewControllers[0];
    if ([v isKindOfClass:[IndexViewController class]]) {
        IndexViewController *controls=(IndexViewController*)v;
        [controls setSelectedSupervisionCenter:self.list[indexPath.row]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
