//
//  OnlineMapViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/27.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "OnlineMapViewController.h"
#import "LoginButtons.h"
#import "DownloadMapController.h"
#import "TKMapCell.h"
#import "UIActionSheet+Blocks.h"
#import "UIDevice+TPCategory.h"
#import "OfflineDemoMapViewController.h"
#import "AppUI.h"
@interface OnlineMapViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
}
- (void)buttonAddClick:(id)sender;
- (void)buttonPauseClick:(id)sender;
- (void)buttonDownloadClick:(id)sender;
- (void)buttonUpdateClick:(id)sender;
- (BOOL)isLoadingSection;
- (void)viewerDownloadWithEntity:(BMKOLSearchRecord*)entity withRow:(int)row;
- (void)viewerlocalMapWithEntity:(BMKOLUpdateElement*)entity withRow:(int)row;
- (BOOL)existsDownloadSourceByCityId:(int)cityId;
- (BOOL)existslocalSourceByCityId:(int)cityId;
- (int)getDownloadMapRowWithCityId:(int)cityId;
- (NSMutableArray*)getUpdateMapsWithCompleted:(void(^)(NSMutableArray *indexPaths,NSMutableArray *delSource))completed;
- (NSString *)getDataSizeString:(int) nSize;
@end

@implementation OnlineMapViewController
- (void)dealloc {
    [super dealloc];
    [_arraylocalDownLoadMapInfo release];
    if (_offlineMap != nil) {
        [_offlineMap release];
        _offlineMap = nil;
    }
    /***
    if (_mapView) {
        [_mapView release];
        _mapView = nil;
    }
     **/
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
    [self.navBarView setNavBarTitle:@"离线地图"];
    if (![self.navBarView viewWithTag:301]) {
        UIButton *btn=[AppUI createhighlightButtonWithTitle:@"添加" frame:CGRectMake(self.view.bounds.size.width-50, (44-35)/2, 50, 35)];
        btn.tag=301;
        [btn addTarget:self action:@selector(buttonAddClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.navBarView addSubview:btn];
    }
    _offlineMap.delegate = self;
    //_mapView.delegate=self;
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
     //[_mapView viewWillDisappear];
    //_mapView.delegate=nil;
    
    _offlineMap.delegate = nil; // 不用时，置nil
     
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect r=self.view.bounds;
    r.size.height-=44*2;
    r.origin.y=44;
        
    //_mapView=[[BMKMapView alloc] init];
    
    _tableView=[[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    [self.view addSubview:_tableView];

    LoginButtons *buttons=[[LoginButtons alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    buttons.cancel.frame=CGRectMake(0, 0, self.view.bounds.size.width/3, 44);
    [buttons.cancel setTitle:@"全部暂停" forState:UIControlStateNormal];
    [buttons.cancel addTarget:self action:@selector(buttonPauseClick:) forControlEvents:UIControlEventTouchUpInside];
    buttons.submit.frame=CGRectMake(self.view.bounds.size.width/3, 0, self.view.bounds.size.width/3, 44);
    [buttons.submit setTitle:@"全部下载" forState:UIControlStateNormal];
    [buttons.submit addTarget:self action:@selector(buttonDownloadClick:) forControlEvents:UIControlEventTouchUpInside];
    UIButton  *downBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    downBtn.frame=CGRectMake(self.view.bounds.size.width*2/3, 0, self.view.bounds.size.width/3,44);
    [downBtn setTitle:@"全部更新" forState:UIControlStateNormal];
    [downBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    downBtn.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    downBtn.showsTouchWhenHighlighted = YES;  //指定按钮被按下时发光
    [downBtn setTitleColor:[UIColor colorFromHexRGB:@"4a7ebb"] forState:UIControlStateHighlighted];
    [downBtn addTarget:self action:@selector(buttonUpdateClick:) forControlEvents:UIControlEventTouchUpInside];
    [buttons addSubview:downBtn];
    
    [self.view addSubview:buttons];
    [buttons release];
    
    //初始化离线地图服务
    _offlineMap = [[BMKOfflineMap alloc] init];
    
    //获取各城市离线地图更新信息
    _arraylocalDownLoadMapInfo = [[NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]] retain];
    
    currentDownloadCityId=-1;
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
//下载地图
- (void)startDownloadWithCityId:(int)cityId{
    NSLog(@"为何总是不执行...");
    [_offlineMap scan:NO];
    currentDownloadCityId=cityId;
    if ([self existslocalSourceByCityId:cityId]) {
        [_offlineMap update:cityId];
    }else{
        [_offlineMap start:cityId];
    }
}
//暂停地图
- (void)pauseDownloadWithCityId:(int)cityId{
    currentDownloadCityId=cityId;
    [_offlineMap pause:cityId];
    
    int row=[self getDownloadMapRowWithCityId:cityId];
    if (row!=-1) {
        TKMapCell *cell=self.arraylDownLoadSource[row];
        cell.isPause=YES;
    }
    
}
//删除下载地图
- (void)removeDownloadWithCityId:(int)cityId{
    [_offlineMap remove:cityId];
}
//删除正在下载的地图
- (void)viewerDownloadWithEntity:(BMKOLSearchRecord*)entity withRow:(int)row{
    RIButtonItem *canBtn=[RIButtonItem item];
    canBtn.label=@"取消";
    canBtn.action=nil;
    
    RIButtonItem *viewerBtn=[RIButtonItem item];
    viewerBtn.label=@"查看地图";
    viewerBtn.action=^(){
        BMKOLSearchRecord *entity=self.arraylDownLoadSource[row];
        OfflineDemoMapViewController *offlineMapViewCtrl = [[[OfflineDemoMapViewController alloc] init] autorelease];
        offlineMapViewCtrl.cityId = entity.cityID;
        //offlineMapViewCtrl.offlineServiceOfMapview = _offlineMap;
        [self.navigationController pushViewController:offlineMapViewCtrl animated:YES];
    };
    
    RIButtonItem *pauseBtn=[RIButtonItem item];
    pauseBtn.label=@"暂停";
    pauseBtn.action=^(){
        BMKOLSearchRecord *entity=self.arraylDownLoadSource[row];
        [self pauseDownloadWithCityId:entity.cityID];//暂停下载
    };
    
    RIButtonItem *delBtn=[RIButtonItem item];
    delBtn.label=@"删除";
    delBtn.action=^(){
        BMKOLSearchRecord *entity=self.arraylDownLoadSource[row];
        [self removeDownloadWithCityId:entity.cityID];//删除正在下载的地图
        //删除数据源与数据行
        BOOL boo=NO;
        if (entity.cityID==currentDownloadCityId) {
            boo=YES;
        }
        if (self.arraylDownLoadSource.count==1) {
            [self.arraylDownLoadSource removeAllObjects];
            [_tableView beginUpdates];
            [_tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [_tableView endUpdates];
            currentDownloadCityId=-1;
        }else{
            [self.arraylDownLoadSource removeObjectAtIndex:row];
            [_tableView beginUpdates];
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:row inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
            [_tableView endUpdates];
        }
        //删除正在下载的离线地图
        if (boo&&[self isLoadingSection]) {
            BMKOLSearchRecord *entity=self.arraylDownLoadSource[0];
            [self startDownloadWithCityId:entity.cityID];//开始下一个下载
        }
    };
    UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:canBtn destructiveButtonItem:nil otherButtonItems:viewerBtn,pauseBtn,delBtn, nil];
    [sheet showInView:self.view];
    [sheet release];
}
//查看或删除已下载的地图
- (void)viewerlocalMapWithEntity:(BMKOLUpdateElement*)entity withRow:(int)row{
    RIButtonItem *canBtn=[RIButtonItem item];
    canBtn.label=@"取消";
    canBtn.action=nil;
    
    RIButtonItem *viewerBtn=[RIButtonItem item];
    viewerBtn.label=@"查看地图";
    viewerBtn.action=^(){
        OfflineDemoMapViewController *offlineMapViewCtrl = [[[OfflineDemoMapViewController alloc] init] autorelease];
        offlineMapViewCtrl.cityId = entity.cityID;
        //offlineMapViewCtrl.offlineServiceOfMapview = _offlineMap;
        [self.navigationController pushViewController:offlineMapViewCtrl animated:YES];
    };
    
    RIButtonItem *delBtn=[RIButtonItem item];
    delBtn.label=@"删除";
    delBtn.action=^(){
        int sec=0;
        if ([self isLoadingSection]) {
            sec=1;
        }
        //删除数据源
        [_arraylocalDownLoadMapInfo removeObjectAtIndex:row];
        //删除离线包
        [_offlineMap remove:entity.cityID];
        //更新资料行
        [_tableView beginUpdates];
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:row inSection:sec], nil] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
    };
    UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:canBtn destructiveButtonItem:nil otherButtonItems:viewerBtn,delBtn, nil];
    [sheet showInView:self.view];
    [sheet release];
}
//下载完成
- (void)finishedDownloadWithRow:(UITableViewCell*)cell element:(BMKOLUpdateElement*)elem{
    
    currentDownloadCityId=-1;//下载完成
    
    NSIndexPath *indexPath=[_tableView indexPathForCell:cell];
    int sec=1;
    if (indexPath.row==0) {
        [self.arraylDownLoadSource removeAllObjects];
        [_tableView beginUpdates];
        [_tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
        sec=0;
    }else{
        [_tableView beginUpdates];
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
    }
    [_arraylocalDownLoadMapInfo insertObject:elem atIndex:0];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:sec], nil] withRowAnimation:UITableViewRowAnimationFade];
    [_tableView endUpdates];
    
    //执行下一个地图下载
    if ([self isLoadingSection]) {
        BMKOLSearchRecord *entity=self.arraylDownLoadSource[0];
        [self startDownloadWithCityId:entity.cityID];
    }
}
- (BOOL)isLoadingSection{
    if (self.arraylDownLoadSource&&[self.arraylDownLoadSource count]>0) {
        return YES;
    }
    return NO;
}
//下载地图
- (void)downloadMapWithEntity:(BMKOLSearchRecord*)entity{
    if (!self.arraylDownLoadSource) {
        self.arraylDownLoadSource=[[NSMutableArray alloc] init];
    }
    [self.arraylDownLoadSource addObject:entity];
    if (self.arraylDownLoadSource.count==1) {
        //新增下载行
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        [_tableView beginUpdates];
        [_tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
        [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
        [self startDownloadWithCityId:entity.cityID];//开始下载地图
        return;
    }
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:self.arraylDownLoadSource.count-1 inSection:0];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    [_tableView endUpdates];
}
//全部暂停
- (void)buttonPauseClick:(id)sender{
    if ([self isLoadingSection]&&currentDownloadCityId!=-1) {
        [self pauseDownloadWithCityId:currentDownloadCityId];
    }
}
//全部下载
- (void)buttonDownloadClick:(id)sender{
    [self buttonUpdateClick:nil];
    if ([self isLoadingSection]&&currentDownloadCityId!=-1) {
        [self startDownloadWithCityId:currentDownloadCityId];
    }
    
}
//全部更新
- (void)buttonUpdateClick:(id)sender{
    NSMutableArray *result=[self getUpdateMapsWithCompleted:^(NSMutableArray *indexPaths, NSMutableArray *delSource) {
        [_arraylocalDownLoadMapInfo removeObjectsInArray:delSource];
        [_tableView beginUpdates];
        [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
    }];
    if (result!=nil&&[result count]>0) {
            if (!self.arraylDownLoadSource) {
                self.arraylDownLoadSource=[[NSMutableArray alloc] init];
            }
            //插入分区
            int start=self.arraylDownLoadSource.count;
            BOOL boo=NO;
            if (self.arraylDownLoadSource.count==0) {
                start=0;
                boo=YES;//判断是否添加选区
            }
            [self.arraylDownLoadSource addObjectsFromArray:result];
            NSMutableArray *indexPaths=[NSMutableArray array];
            for (int i=start;i<start+result.count; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:start inSection:0]];
            }
            [_tableView beginUpdates];
            if (boo) {
                [_tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            }
            [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            [_tableView endUpdates];
    }
}
//添加地图
- (void)buttonAddClick:(id)sender{
    DownloadMapController *map=[[DownloadMapController alloc] init];
    map.controler=self;
    map.downloadSource=self.arraylDownLoadSource;
    map.arraylocalDownLoadMapInfo=_arraylocalDownLoadMapInfo;
    [self.navigationController pushViewController:map animated:YES];
    [map release];
}
//取得有更新的地图
- (NSMutableArray*)getUpdateMapsWithCompleted:(void(^)(NSMutableArray *indexPaths,NSMutableArray *delSource))completed{
    if (_arraylocalDownLoadMapInfo&&[_arraylocalDownLoadMapInfo count]>0) {
        NSMutableArray *result=[NSMutableArray array];
        NSMutableArray *delSource=[NSMutableArray array];
        NSMutableArray *indexPaths=[NSMutableArray array];
        int sec=0;
        if ([self isLoadingSection]) {
            sec=1;
        }
        int total=0;
        for (BMKOLUpdateElement *item in _arraylocalDownLoadMapInfo) {
            BOOL boo=[self existsDownloadSourceByCityId:item.cityID];
            if (!boo) {
                BMKOLSearchRecord *entity=[[BMKOLSearchRecord alloc] init];
                entity.cityID=item.cityID;
                entity.cityName=item.cityName;
                entity.size=item.size;
                [result addObject:entity];
                [entity release];
                
                [delSource addObject:item];
                [indexPaths addObject:[NSIndexPath indexPathForRow:total inSection:sec]];
            }
            total++;
        }
        if (completed) {
            completed(indexPaths,delSource);
        }
        return result;
    }
    return nil;

}
//判断更新项是否存在下载列表中
- (BOOL)existsDownloadSourceByCityId:(int)cityId{
    if ([self isLoadingSection]) {
        NSString *match=[NSString stringWithFormat:@"SELF.cityID ==%d",cityId];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:match];
        NSArray *results = [self.arraylDownLoadSource filteredArrayUsingPredicate:predicate];
        if (results&&[results count]>0) {
            return YES;
        }
    }
    return NO;
}
//判断是否已下载的地图
- (BOOL)existslocalSourceByCityId:(int)cityId{
    NSArray *arr=[_offlineMap getAllUpdateInfo];
    if (arr&&[arr count]>0) {
        NSString *match=[NSString stringWithFormat:@"SELF.cityID ==%d",cityId];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:match];
        NSArray *results = [arr filteredArrayUsingPredicate:predicate];
        if (results&&[results count]>0) {
            return YES;
        }
    }
    return NO;
}
//获取下载行
- (int)getDownloadMapRowWithCityId:(int)cityId{
    if ([self isLoadingSection]) {
        NSString *match=[NSString stringWithFormat:@"SELF.cityID ==%d",cityId];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:match];
        NSArray *results = [self.arraylDownLoadSource filteredArrayUsingPredicate:predicate];
        if (results&&[results count]>0) {
            return [self.arraylDownLoadSource indexOfObject:[results objectAtIndex:0]];
        }
    }
    return -1;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark BMKOfflineMapDelegate methods
- (void)onGetOfflineMapState:(int)type withState:(int)state{
   
    NSLog(@"type=%d state=%d",type,state);
    if (type == TYPE_OFFLINE_UPDATE) {
        //id为state的城市正在下载或更新，start后会毁掉此类型
        BMKOLUpdateElement* updateInfo;
        updateInfo = [_offlineMap getUpdateInfo:state];
        int row=[self getDownloadMapRowWithCityId:updateInfo.cityID];
        NSLog(@"row=%d",row);
        NSLog(@"下载比例 rate=%d",updateInfo.ratio);
        if (row!=-1) {
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
            TKMapCell *cell=(TKMapCell*)[_tableView cellForRowAtIndexPath:indexPath];
            [cell updateProgressInfo:updateInfo];
        }
    }
    if (type == TYPE_OFFLINE_NEWVER) {
        //id为state的state城市有新版本,可调用update接口进行更新
        BMKOLUpdateElement* updateInfo;
        updateInfo = [_offlineMap getUpdateInfo:state];
        int row=[self getDownloadMapRowWithCityId:updateInfo.cityID];
        if (row!=-1) {
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
            TKMapCell *cell=(TKMapCell*)[_tableView cellForRowAtIndexPath:indexPath];
            [cell updateProgressInfo:updateInfo];
        }
    }
}
#pragma mark tableView datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([self isLoadingSection]) {
        return 2;
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self isLoadingSection]) {
        if (section==0) {
            return [self.arraylDownLoadSource count];
        }
    }
    return  [_arraylocalDownLoadMapInfo count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"mapcell";
    if ([self isLoadingSection]) {
         if (indexPath.section==0) {
             TKMapCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
             if (cell==nil||[cell isKindOfClass:[UITableViewCell class]]) {
                 cell=[[[TKMapCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
                 cell.controlers=self;
             }
             BMKOLSearchRecord *entity=self.arraylDownLoadSource[indexPath.row];
             [cell setDataSource:entity];
             return cell;
         }
     }
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil||[cell isKindOfClass:[TKMapCell class]]) {
        cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    BMKOLUpdateElement* item = [_arraylocalDownLoadMapInfo objectAtIndex:indexPath.row];
    
    NSString *memo=item.update?[NSString stringWithFormat:@"有更新包 %@",[self getDataSizeString:item.serversize]]:@"完成";
    CGSize size=[memo textSize:[UIFont fontWithName:DeviceFontName size:DeviceFontSize] withWidth:self.view.bounds.size.width];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%d)", item.cityName, item.cityID];
    cell.textLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    UILabel *sizelabel =[[[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-10-size.width, 0, size.width, size.height)]autorelease];
    sizelabel.autoresizingMask =UIViewAutoresizingFlexibleLeftMargin;
    sizelabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    sizelabel.text = memo;
    sizelabel.textColor=item.update?[UIColor blueColor]:[UIColor blackColor];
    sizelabel.backgroundColor = [UIColor clearColor];
    cell.accessoryView = sizelabel;
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title=@"已下载";
    if ([self isLoadingSection]) {
        if (section==0) {
            title=@"正在下载";
        }
    }
    UIView* myView = [[[UIView alloc] init] autorelease];
    myView.backgroundColor = [UIColor colorFromHexRGB:@"f2f2f2"];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 90, 22)];
    titleLabel.textColor=[UIColor blackColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    titleLabel.text=title;
    [myView addSubview:titleLabel];
    [titleLabel release];
    return myView;
}
//选中
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self isLoadingSection]) {
        if (indexPath.section==0) {
            BMKOLSearchRecord *entity=self.arraylDownLoadSource[indexPath.row];
            [self viewerDownloadWithEntity:entity withRow:indexPath.row];
        }else{
            BMKOLUpdateElement *entity=_arraylocalDownLoadMapInfo[indexPath.row];
            [self viewerlocalMapWithEntity:entity withRow:indexPath.row];
        }
    }else{
        BMKOLUpdateElement *entity=_arraylocalDownLoadMapInfo[indexPath.row];
        [self viewerlocalMapWithEntity:entity withRow:indexPath.row];
    }
}
@end
