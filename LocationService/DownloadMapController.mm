//
//  DownloadMapController.m
//  LocationService
//
//  Created by aJia on 2013/12/30.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "DownloadMapController.h"
#import "UIImage+TPCategory.h"
@interface DownloadMapController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>{
    UITableView *_tableView;
    UITableView *_searchView;
}
-(NSString *)getDataSizeString:(int) nSize;
-(void)SearchData:(NSString*)searchText;
- (BOOL)findByIdUpdate:(int)cityId;
- (BMKOLUpdateElement*)findByCityId:(int)cityId;
- (NSString*)cellTitleWithEntity:(BMKOLSearchRecord*)entity;
- (BOOL)downloadingWithCityId:(int)cityId;//判断是否正在下载
@end

@implementation DownloadMapController
- (void)dealloc {
    [super dealloc];
    [_arrayHotCityData release];
    [_arrayOfflineCityData release];
    [_arraylocalDownLoadMapInfo release];
    if (_offlineMap != nil) {
        [_offlineMap release];
        _offlineMap = nil;
    }
    if (_mapView) {
        [_mapView release];
        _mapView = nil;
    }
    if (_arraySearchCityData) {
        [_arraySearchCityData release];
        _arraySearchCityData = nil;
    }
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
     _mapView.delegate = self;
     _offlineMap.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
     _mapView.delegate = nil; // 不用时，置nil
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
    
    _mapView=[[BMKMapView alloc] initWithFrame:r];
    [self.view addSubview:_mapView];
    
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
    
    //获取各城市离线地图更新信息
    _arraylocalDownLoadMapInfo = [[NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]] retain];
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
    if (_arraylocalDownLoadMapInfo&&[_arraylocalDownLoadMapInfo count]>0) {
        NSString *match=[NSString stringWithFormat:@"SELF.cityID ==%d",cityId];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:match];
        NSArray *results = [_arraylocalDownLoadMapInfo filteredArrayUsingPredicate:predicate];
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
- (NSString*)cellTitleWithEntity:(BMKOLSearchRecord*)entity{
    BMKOLUpdateElement *item=[self findByCityId:entity.cityID];
    NSString *datasize=[self getDataSizeString:entity.size];
    if (item==nil) {//未下载
         return  datasize;
    }
    //已下载
    NSString *memo=item.update?@"可更新":@"已下载";
    //正在下载
    if ([self downloadingWithCityId:entity.cityID]) {
        memo=@"正在下载";
    }
    return [NSString stringWithFormat:@"%@%@",memo,datasize];
}
#pragma mark 包大小转换工具类（将包大小转换成合适单位）
-(NSString *)getDataSizeString:(int) nSize
{
	NSString *string = nil;
	if (nSize<1024)
	{
		string = [NSString stringWithFormat:@"%dB", nSize];
	}
	else if (nSize<1048576)
	{
		string = [NSString stringWithFormat:@"%dK", (nSize/1024)];
	}
	else if (nSize<1073741824)
	{
		if ((nSize%1048576)== 0 )
        {
			string = [NSString stringWithFormat:@"%dM", nSize/1048576];
        }
		else
        {
            int decimal = 0; //小数
            NSString* decimalStr = nil;
            decimal = (nSize%1048576);
            decimal /= 1024;
            
            if (decimal < 10)
            {
                decimalStr = [NSString stringWithFormat:@"%d", 0];
            }
            else if (decimal >= 10 && decimal < 100)
            {
                int i = decimal / 10;
                if (i >= 5)
                {
                    decimalStr = [NSString stringWithFormat:@"%d", 1];
                }
                else
                {
                    decimalStr = [NSString stringWithFormat:@"%d", 0];
                }
                
            }
            else if (decimal >= 100 && decimal < 1024)
            {
                int i = decimal / 100;
                if (i >= 5)
                {
                    decimal = i + 1;
                    
                    if (decimal >= 10)
                    {
                        decimal = 9;
                    }
                    
                    decimalStr = [NSString stringWithFormat:@"%d", decimal];
                }
                else
                {
                    decimalStr = [NSString stringWithFormat:@"%d", i];
                }
            }
            
            if (decimalStr == nil || [decimalStr isEqualToString:@""])
            {
                string = [NSString stringWithFormat:@"%dMss", nSize/1048576];
            }
            else
            {
                string = [NSString stringWithFormat:@"%d.%@M", nSize/1048576, decimalStr];
            }
        }
	}
	else	// >1G
	{
		string = [NSString stringWithFormat:@"%dG", nSize/1073741824];
	}
	
	return string;
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
            //转换包大小
            UILabel *sizelabel =[[[UILabel alloc] initWithFrame:CGRectMake(210, 0, 100, 40)]autorelease];
            sizelabel.autoresizingMask =UIViewAutoresizingFlexibleLeftMargin;
            sizelabel.text = [self cellTitleWithEntity:item];
            sizelabel.textAlignment=NSTextAlignmentRight;
            sizelabel.backgroundColor = [UIColor clearColor];
            cell.accessoryView = sizelabel;
            
        }
        else  //支持离线下载城市列表
        {
            BMKOLSearchRecord* item = [_arrayOfflineCityData objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%d)", item.cityName, item.cityID];
            //转换包大小
            UILabel *sizelabel =[[[UILabel alloc] initWithFrame:CGRectMake(210, 0, 100, 40)]autorelease];
            sizelabel.autoresizingMask =UIViewAutoresizingFlexibleLeftMargin;
            sizelabel.text = [self cellTitleWithEntity:item];
            sizelabel.backgroundColor = [UIColor clearColor];
            cell.accessoryView = sizelabel;
            
        }
    }else{//搜索结果
        BMKOLSearchRecord* item = [_arraySearchCityData objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@(%d)", item.cityName, item.cityID];
        //转换包大小
        UILabel *sizelabel =[[[UILabel alloc] initWithFrame:CGRectMake(210, 0, 100, 40)]autorelease];
        sizelabel.autoresizingMask =UIViewAutoresizingFlexibleLeftMargin;
        sizelabel.text = [self cellTitleWithEntity:item];
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
       titleLabel.text=@"搜索绍果";
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
        if (self.controler&&[self.controler respondsToSelector:@selector(downloadMapWithEntity:)]) {
            [self.controler performSelector:@selector(downloadMapWithEntity:) withObject:entity];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
@end
