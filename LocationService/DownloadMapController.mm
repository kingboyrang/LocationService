//
//  DownloadMapController.m
//  LocationService
//
//  Created by aJia on 2013/12/30.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "DownloadMapController.h"
#import "UIImage+TPCategory.h"
#import "OnlineMapViewController.h"
#import "OfflineHelper.h"
@interface DownloadMapController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>{
    UITableView *_tableView;
    UITableView *_searchView;
}
-(void)SearchData:(NSString*)searchText;
- (BOOL)findByIdUpdate:(int)cityId;
- (BMKOLUpdateElement*)findByCityId:(int)cityId;
- (NSString*)cellTitleWithEntity:(BMKOLSearchRecord*)entity color:(UIColor**)fontColor;
- (BOOL)downloadingWithCityId:(int)cityId;//判断是否正在下载
@end

@implementation DownloadMapController
- (void)dealloc {
    [super dealloc];
    [_arrayHotCityData release];
    [_arrayOfflineCityData release];
    if (_offlineMap != nil) {
        [_offlineMap release];
        _offlineMap = nil;
    }
    /**
    if (_mapView) {
        [_mapView release];
        _mapView = nil;
    }
     ***/
    if (_arraySearchCityData) {
        [_arraySearchCityData release];
        _arraySearchCityData = nil;
    }
    [_tableView release];
    [_searchView release];
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
    [self.navBarView setNavBarTitle:@"添加城市"];
    // _mapView.delegate = self;
     _offlineMap.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // _mapView.delegate = nil; // 不用时，置nil
    _offlineMap.delegate = nil; // 不用时，置nil
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UISearchBar *searchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, 44)];
    searchBar.delegate = self;
    searchBar.placeholder =@"请输入城市名称或首字母";
    searchBar.backgroundColor=[UIColor colorFromHexRGB:@"dbe6f3"];
    UITextField *searchField = [[searchBar subviews] lastObject];
    [searchField setReturnKeyType:UIReturnKeyDone];
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
    [self.view addSubview:searchBar];
    
    CGRect r=self.view.bounds;
    r.size.height-=44*2;
    r.origin.y=44*2;
    
   // _mapView=[[BMKMapView alloc] initWithFrame:r];
   // [self.view addSubview:_mapView];
    
    _searchView=[[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
    _searchView.delegate=self;
    _searchView.dataSource=self;
    [self.view addSubview:_searchView];
    
    
    _tableView=[[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    [self.view addSubview:_tableView];
    //初始化离线地图服务
    _offlineMap = [[BMKOfflineMap alloc] init];
    //获取热门城市
    _arrayHotCityData = [[_offlineMap getHotCityList] retain];
    //获取支持离线下载城市列表
    _arrayOfflineCityData = [[_offlineMap getOfflineCityList] retain];
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma  mark -searchbar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self SearchData:[searchText Trim]];
    [self.view bringSubviewToFront:_searchView];
}
//search
-(void)SearchData:(NSString*)searchText{
    //根据城市名获取城市信息，得到cityID
    NSArray* city = [_offlineMap searchCity:searchText];
    if (_arraySearchCityData) {
        [_arraySearchCityData release];
        _arraySearchCityData=nil;
    }
    if (city.count > 0) {
        _arraySearchCityData=[city retain];
    }
    [_searchView reloadData];
}


-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    //searchBar.text=@"";
    
}
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
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.text=@"";
    [self SearchData:searchBar.text];
    [searchBar resignFirstResponder];
    [self.view sendSubviewToBack:_searchView];
    searchBar.showsCancelButton=NO;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
     [searchBar resignFirstResponder];
     searchBar.showsCancelButton=NO;
}
#pragma mark BMKOfflineMapDelegate Methods
- (void)onGetOfflineMapState:(int)type withState:(int)state{
    if (type == TYPE_OFFLINE_UPDATE) {
        //id为state的城市正在下载或更新，start后会毁掉此类型
        BMKOLUpdateElement* updateInfo;
        updateInfo = [_offlineMap getUpdateInfo:state];
        NSLog(@"城市名：%@,下载比例:%d",updateInfo.cityName,updateInfo.ratio);
    }
    if (type == TYPE_OFFLINE_NEWVER) {
        //id为state的state城市有新版本,可调用update接口进行更新
        BMKOLUpdateElement* updateInfo;
        updateInfo = [_offlineMap getUpdateInfo:state];
        NSLog(@"是否有更新%d",updateInfo.update);
    }
    if (type == TYPE_OFFLINE_UNZIP) {
        //正在解压第state个离线包，导入时会回调此类型
    }
    if (type == TYPE_OFFLINE_ZIPCNT) {
        //检测到state个离线包，开始导入时会回调此类型
        NSLog(@"检测到%d个离线包",state);
        if(state==0)
        {
            //[self showImportMesg:state];
        }
    }
    if (type == TYPE_OFFLINE_ERRZIP) {
        //有state个错误包，导入完成后会回调此类型
        NSLog(@"有%d个离线包导入错误",state);
    }
    if (type == TYPE_OFFLINE_UNZIPFINISH) {
        NSLog(@"成功导入%d个离线包",state);
        //导入成功state个离线包，导入成功后会回调此类型
        //[self showImportMesg:state];
    }
}
- (BMKOLUpdateElement*)findByCityId:(int)cityId{
    if (self.arraylocalDownLoadMapInfo&&[self.arraylocalDownLoadMapInfo count]>0) {
        NSString *match=[NSString stringWithFormat:@"SELF.cityID ==%d",cityId];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:match];
        NSArray *results = [self.arraylocalDownLoadMapInfo filteredArrayUsingPredicate:predicate];
        if (results&&[results count]>0) {
            BMKOLUpdateElement *item=[results objectAtIndex:0];
            return item;
        }
    }
    return nil;
}
//判断是否已下载，并没有更新
- (BOOL)findByIdUpdate:(int)cityId{
    BMKOLUpdateElement *item=[self findByCityId:cityId];
    if (item!=nil) {
        if (!item.update||[self downloadingWithCityId:cityId]) {
            return YES;
        }
    }
    return NO;
}
- (BOOL)downloadingWithCityId:(int)cityId{
    //正在下载
    if (self.downloadSource&&[self.downloadSource count]>0) {
        NSString *match=[NSString stringWithFormat:@"SELF.cityID ==%d",cityId];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:match];
        NSArray *results = [self.downloadSource filteredArrayUsingPredicate:predicate];
        if (results&&[results count]>0) {
            return YES;
        }
    }
    return NO;
}
- (NSString*)cellTitleWithEntity:(BMKOLSearchRecord*)entity color:(UIColor**)fontColor{
    BMKOLUpdateElement *item=[self findByCityId:entity.cityID];
    NSString *datasize=[OfflineHelper getDataSizeString:entity.size];
    if (item==nil) {//未下载
         *fontColor=[UIColor blackColor];
         return  datasize;
    }
    //已下载
    NSString *memo=item.update?@"可更新":@"已下载";
    if (item.update) {
         *fontColor=[UIColor blueColor];
    }else{
         *fontColor=[UIColor grayColor];
    }
    //正在下载
    if ([self downloadingWithCityId:entity.cityID]) {
        *fontColor=[UIColor redColor];
        memo=@"正在下载";
    }
    return [NSString stringWithFormat:@"%@%@",memo,datasize];
}
#pragma mark tableView source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView==_searchView) {
        return 1;
    }
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView==_tableView) {
        if (section==0) {
            return [_arrayHotCityData count];
        }
        return [_arrayOfflineCityData count];
    }
    return [_arraySearchCityData count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   static NSString *cellIdentifier=@"downloadCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    if (tableView==_tableView) {
        //热门城市列表
        if(indexPath.section==0)
        {
            BMKOLSearchRecord* item = [_arrayHotCityData objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%d)", item.cityName, item.cityID];
            cell.textLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
            //转换包大小
            UIColor *fontColor;
            NSString *labName=[self cellTitleWithEntity:item color:&fontColor];
            CGSize size=[labName textSize:[UIFont fontWithName:DeviceFontName size:DeviceFontSize] withWidth:self.view.bounds.size.width];
            UILabel *sizelabel =[[[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-10-size.width, 0, size.width, size.height)]autorelease];
            sizelabel.autoresizingMask =UIViewAutoresizingFlexibleLeftMargin;
            sizelabel.text = labName;
            sizelabel.textColor=fontColor;
            sizelabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
            sizelabel.textAlignment=NSTextAlignmentRight;
            sizelabel.backgroundColor = [UIColor clearColor];
            cell.accessoryView = sizelabel;
            
        }
        else  //支持离线下载城市列表
        {
            BMKOLSearchRecord* item = [_arrayOfflineCityData objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%d)", item.cityName, item.cityID];
            cell.textLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
            //转换包大小
            UIColor *fontColor;
            NSString *labName=[self cellTitleWithEntity:item color:&fontColor];
            CGSize size=[labName textSize:[UIFont fontWithName:DeviceFontName size:DeviceFontSize] withWidth:self.view.bounds.size.width];
            
            UILabel *sizelabel =[[[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-10-size.width, 0, size.width, size.height)]autorelease];
            sizelabel.autoresizingMask =UIViewAutoresizingFlexibleLeftMargin;
            sizelabel.text = labName;
            sizelabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
            sizelabel.textColor=fontColor;
            sizelabel.backgroundColor = [UIColor clearColor];
            cell.accessoryView = sizelabel;
            
        }
    }else{//搜索结果
        BMKOLSearchRecord* item = [_arraySearchCityData objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@(%d)", item.cityName, item.cityID];
        cell.textLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
        //转换包大小
        UIColor *fontColor;
        NSString *labName=[self cellTitleWithEntity:item color:&fontColor];
        CGSize size=[labName textSize:[UIFont fontWithName:DeviceFontName size:DeviceFontSize] withWidth:self.view.bounds.size.width];
        UILabel *sizelabel =[[[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-10-size.width, 0, size.width, size.height)]autorelease];
        sizelabel.autoresizingMask =UIViewAutoresizingFlexibleLeftMargin;
        sizelabel.text = labName;
        sizelabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
        sizelabel.textColor=fontColor;
        sizelabel.backgroundColor = [UIColor clearColor];
        cell.accessoryView = sizelabel;
    }
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[[UIView alloc] init] autorelease];
    myView.backgroundColor = [UIColor colorFromHexRGB:@"f2f2f2"];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.bounds.size.width-10, 22)];
    titleLabel.textColor=[UIColor blackColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    if(tableView==_tableView){
       titleLabel.text=section==0?@"热门城市":@"按省份查找";
    }else{
       titleLabel.text=@"搜索结果";
    }
    [myView addSubview:titleLabel];
    [titleLabel release];
    return myView;
}
//表的行选择操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
      [tableView deselectRowAtIndexPath:indexPath animated:NO];
    BMKOLSearchRecord* entity;
    if (tableView==_tableView) {
        if (indexPath.section==0) {
            entity=[_arrayHotCityData objectAtIndex:indexPath.row];
        }else{
            entity=[_arrayOfflineCityData objectAtIndex:indexPath.row];
        }
    }else{
        entity=[_arraySearchCityData objectAtIndex:indexPath.row];
    }
    BOOL boo=[self findByIdUpdate:entity.cityID];
    if (!boo) {//可下载
        if([self.navigationController.viewControllers[2] isKindOfClass:[OnlineMapViewController class]])
        {
            OnlineMapViewController *online=(OnlineMapViewController*)self.navigationController.viewControllers[2];
            online.downloadRecord=entity;
        }
        [self.navigationController popViewControllerAnimated:YES];
        /***
        if (self.controler&&[self.controler respondsToSelector:@selector(downloadMapWithEntity:)]) {
            [self.controler downloadMapWithEntity:entity];
        }
         ***/
    }
}
@end
