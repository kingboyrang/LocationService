//
//  HotCityView.m
//  LocationService
//
//  Created by aJia on 2014/1/22.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import "HotCityView.h"
#import "OfflineHelper.h"
@interface HotCityView ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>{
    UITableView *_tableView;
    UITableView *_searchView;
}
- (NSString*)cellTitleWithEntity:(BMKOLSearchRecord*)entity color:(UIColor**)fontColor;
- (BMKOLUpdateElement*)findByCityId:(int)cityId;
- (BOOL)downloadingWithCityId:(int)cityId;
- (BOOL)findByIdUpdate:(int)cityId;
- (void)searchExitKeyboard;
@end

@implementation HotCityView
- (void)dealloc{
    [super dealloc];
    [_tableView release];
    [_searchView release];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NavBarView *topView=[[NavBarView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
        [topView setNavBarTitle:@"添加城市"];
        [topView setBackButtonWithTarget:self action:@selector(buttonHideView)];
        [self addSubview:topView];
        [topView release];
        
        UISearchBar *searchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0, 44, frame.size.width, 44)];
        searchBar.tag=40;
        searchBar.delegate = self;
        searchBar.placeholder =@"请输入城市名称或首字母";
        searchBar.backgroundColor=[UIColor colorFromHexRGB:@"dbe6f3"];
#ifdef __IPHONE_7_0
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
                    UIView *searchV = [[searchBar subviews] lastObject];
            for (id v in searchV.subviews) {
                if ([v isKindOfClass:[UITextField class]])
                {
                    UITextField *field=(UITextField*)v;
                    field.returnKeyType=UIReturnKeyDone;
                    field.clearButtonMode=UITextFieldViewModeNever;
                    break;
                }
            }
        }
#endif

        for (UIView *subview in searchBar.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
                [subview removeFromSuperview];
                break;
            }
        }
        for (UIView *subview in searchBar.subviews)
        {
            if ([subview isKindOfClass:[UITextField class]])
            {
                UITextField *field=(UITextField*)subview;
                field.returnKeyType=UIReturnKeyDone;
                field.clearButtonMode=UITextFieldViewModeNever;
                break;
            }
        }
        //为UISearchBar添加背景图片
        [self addSubview:searchBar];
        
        CGRect r=self.bounds;
        r.size.height-=44*2;
        r.origin.y=44*2;
        
        // _mapView=[[BMKMapView alloc] initWithFrame:r];
        // [self.view addSubview:_mapView];
        
        _searchView=[[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
        _searchView.delegate=self;
        _searchView.dataSource=self;
        [self addSubview:_searchView];
        
        
        _tableView=[[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        [self addSubview:_tableView];
    }
    return self;
}
//返回操作
- (void)buttonHideView{
    if (self.backDelegate&&[self.backDelegate respondsToSelector:@selector(viewBackToControl:)]) {
        [self.backDelegate viewBackToControl:self];
    }
}
- (void)reloadDataSource{
    [_tableView reloadData];
}
#pragma  mark -searchbar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self SearchData:[searchText Trim]];
    [self bringSubviewToFront:_searchView];
}
//search
-(void)SearchData:(NSString*)searchText{
    //根据城市名获取城市信息，得到cityID
    /***
    NSArray* city = [_offlineMap searchCity:searchText];
    if (_arraySearchCityData) {
        [_arraySearchCityData release];
        _arraySearchCityData=nil;
    }
    if (city.count > 0) {
        _arraySearchCityData=[city retain];
    }
   
     ***/
    if(self.delegate&&[self.delegate respondsToSelector:@selector(searchOfflineCitys:)])
    {
        self.searchResultCitys=[self.delegate searchOfflineCitys:searchText];
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
    [self sendSubviewToBack:_searchView];
    searchBar.showsCancelButton=NO;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton=NO;
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
            return [self.hotCitys count];
        }
        return [self.countryCitys count];
    }
    return [self.searchResultCitys count];
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
            BMKOLSearchRecord* item = [self.hotCitys objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%d)", item.cityName, item.cityID];
            cell.textLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
            //转换包大小
            UIColor *fontColor;
            NSString *labName=[self cellTitleWithEntity:item color:&fontColor];
            CGSize size=[labName textSize:[UIFont fontWithName:DeviceFontName size:DeviceFontSize] withWidth:self.bounds.size.width];
            UILabel *sizelabel =[[[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-10-size.width, 0, size.width, size.height)]autorelease];
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
            BMKOLSearchRecord* item = [self.countryCitys objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%d)", item.cityName, item.cityID];
            cell.textLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
            //转换包大小
            UIColor *fontColor;
            NSString *labName=[self cellTitleWithEntity:item color:&fontColor];
            CGSize size=[labName textSize:[UIFont fontWithName:DeviceFontName size:DeviceFontSize] withWidth:self.bounds.size.width];
            
            UILabel *sizelabel =[[[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-10-size.width, 0, size.width, size.height)]autorelease];
            sizelabel.autoresizingMask =UIViewAutoresizingFlexibleLeftMargin;
            sizelabel.text = labName;
            sizelabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
            sizelabel.textColor=fontColor;
            sizelabel.backgroundColor = [UIColor clearColor];
            cell.accessoryView = sizelabel;
            
        }
    }else{//搜索结果
        BMKOLSearchRecord* item = [self.searchResultCitys objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@(%d)", item.cityName, item.cityID];
        cell.textLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
        //转换包大小
        UIColor *fontColor;
        NSString *labName=[self cellTitleWithEntity:item color:&fontColor];
        CGSize size=[labName textSize:[UIFont fontWithName:DeviceFontName size:DeviceFontSize] withWidth:self.bounds.size.width];
        UILabel *sizelabel =[[[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-10-size.width, 0, size.width, size.height)]autorelease];
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
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.bounds.size.width-10, 22)];
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
            entity=[self.hotCitys objectAtIndex:indexPath.row];
        }else{
            entity=[self.countryCitys objectAtIndex:indexPath.row];
        }
    }else{
        entity=[self.searchResultCitys objectAtIndex:indexPath.row];
    }
    BOOL boo=[self findByIdUpdate:entity.cityID];
    if (!boo) {//可下载
         if (self.delegate&&[self.delegate respondsToSelector:@selector(addOfflineMapDownload:)]) {
             [self searchExitKeyboard];//隐藏键盘
             [self.delegate addOfflineMapDownload:entity];
         }
         
    }
}
#pragma mark private  methods
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
- (BMKOLUpdateElement*)findByCityId:(int)cityId{
    if (self.localMaps&&[self.localMaps count]>0) {
        NSString *match=[NSString stringWithFormat:@"SELF.cityID ==%d",cityId];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:match];
        NSArray *results = [self.localMaps filteredArrayUsingPredicate:predicate];
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
    if (self.downloadMaps&&[self.downloadMaps count]>0) {
        NSString *match=[NSString stringWithFormat:@"SELF.cityID ==%d",cityId];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:match];
        NSArray *results = [self.downloadMaps filteredArrayUsingPredicate:predicate];
        if (results&&[results count]>0) {
            return YES;
        }
    }
    return NO;
}
- (void)searchExitKeyboard{
    UISearchBar *search=(UISearchBar*)[self viewWithTag:40];
#ifdef __IPHONE_7_0
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        UIView *searchV = [[search subviews] lastObject];
        for (id v in searchV.subviews) {
            if ([v isKindOfClass:[UITextField class]])
            {
                UITextField *field=(UITextField*)v;
                [field resignFirstResponder];
                break;
            }
        }
    }
    return;
#endif
    for (UIView *subview in search.subviews)
    {
        if ([subview isKindOfClass:[UITextField class]])
        {
            UITextField *field=(UITextField*)subview;
            [field resignFirstResponder];
            break;
        }
    }
}
@end
