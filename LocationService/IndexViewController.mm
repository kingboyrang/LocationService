//
//  IndexViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/23.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "IndexViewController.h"
#import "SupervisionViewController.h"
#import "AddSupervision.h"
#import "Account.h"
#import "AppHelper.h"
#import "KYPointAnnotation.h"
#import "TrajectoryPaoView.h"
#import "MainViewController.h"
#import "BasicNavigationController.h"
#import "PersonTrajectoryViewController.h"
#import "CallTrajectoryViewController.h"
#import "TrajectoryMessageController.h"
#import "AlertHelper.h"
#import "RecordView.h"
#import "MoreViewController.h"
#import "MeterViewController.h"
#import "MonitorPersonViewController.h"
#import "NSTimer+TPCategory.h"
#import "UIImage+TPCategory.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "PinView.h"
#import "BMKAnnotationView+TPCategory.h"
#import "NetWorkConnection.h"
@interface IndexViewController (){
    RecordView *_recordView;
    NSTimer *_updateTimer;
    BOOL isGps;
    BOOL isPushController;
    //PinView *_pinView;
}
- (void)buttonCompassClick;
- (void)buttonTargetClick;
- (void)buttonMonitorClick;
- (void)cleanMap;
- (void)startUserLocation;
- (void)setRecetiveSupersion:(SupervisionPerson*)entity;
- (SupervisionPerson*)findByGuidEntity:(NSString*)guid;
- (void)setOrginTrajectorySupersion;
- (void)changedAdTimer:(NSTimer *)timer;
- (void)loadingReadCountWithId:(NSString*)personId;//加载未读总数
- (void)updateInfoUI:(int)total;//
- (void)reloadAnnotations:(BMKMapView *)mapView;
- (void)removeSupervisionAnnotations;
- (void)reloadDataSupervisionAnnotations;
- (void)setChoosetTarget;
@end

@implementation IndexViewController
- (void)dealloc {
    [super dealloc];
    if (_mapView) {
        [_mapView release];
        _mapView = nil;
    }
    if(_recordView)
    {
        [_recordView release];
        _recordView = nil;
    }
    if (_updateTimer) {
        [_updateTimer release];
    }
    
   // [_pinView release];
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationController.navigationBar.translucent = NO;
    self.navigationController.delegate=self;
    
    isFirstLoad=YES;
//    NSString *str=@"名称:";
//    CGSize size=[str textSize:[UIFont fontWithName:DeviceFontName size:12] withWidth:self.view.bounds.size.width];
//    NSLog(@"size=%@",NSStringFromCGSize(size));

    isGps=YES;
    isPushController=NO;
    
    CGRect r=self.view.bounds;
    r.origin.y=44;
    r.size.height-=TabHeight+44;
    _mapView= [[BMKMapView alloc]initWithFrame:r];
    
    [self.view addSubview:_mapView];
    orginLevel=_mapView.zoomLevel;

    
    _toolBarView=[[ToolBarView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-TabHeight, self.view.bounds.size.width, TabHeight)];
    _toolBarView.controls=self;
    [self.view addSubview:_toolBarView];
    
    _recordView=[[RecordView alloc] initWithFrame:CGRectMake(DeviceWidth*4/5-DeviceWidth/10, self.view.bounds.size.height-25-20, 25, 25)];
    
    //先执行一次
    [self loadSupervision];
    //30秒刷新一次
     _updateTimer=[[NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(changedAdTimer:) userInfo:nil repeats:YES] retain];
}
- (void)selectedMetaWithEntity:(SupervisionPerson*)entity{
    MeterViewController *meter=[[MeterViewController alloc] init];
    meter.Entity=entity;
    [self.navigationController pushViewController:meter animated:YES];
    [meter release];
}
- (void)setSelectedSupervisionCenter:(SupervisionPerson*)entity{
    if ([[entity.Latitude Trim] length]>0&&[[entity.Longitude Trim] length]>0) {
        //[self setRecetiveSupersion:entity];
        CLLocationCoordinate2D coor;
        coor.latitude=[entity.Latitude floatValue];
        coor.longitude=[entity.Longitude floatValue];
        [_mapView setCenterCoordinate:coor];
        self.laglnt=entity.ID;
        //[NSString stringWithFormat:@"%@,%@",entity.Latitude,entity.Longitude];
        if (![NetWorkConnection locationServicesEnabled]) {//表示未开启定位功能
            [self setChoosetTarget];
            [self setRecetiveSupersion:entity];
        }
        /***
        //选中监管目标
        if(_mapView.annotations&&[_mapView.annotations count]>0)
        {
            for (id  v in _mapView.annotations) {
                if ([v isKindOfClass:[KYPointAnnotation class]]) {
                    KYPointAnnotation *point=(KYPointAnnotation*)v;
                    if (point.coordinate.latitude==coor.latitude&&point.coordinate.longitude==coor.longitude) {
                        //[_mapView selectAnnotation:point animated:YES];
                         
                        [_mapView setCenterCoordinate:point.coordinate];
                        break;
                    }
                }
            }
        }
         ***/
    }
}
#pragma mark - UINavigationController delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.hidesBottomBarWhenPushed=YES;
       
    if ( viewController == [navigationController.viewControllers objectAtIndex:0]) {
        [navigationController setNavigationBarHidden:YES animated:animated];
    } else if ( [navigationController isNavigationBarHidden] ) {
        // [navigationController setNavigationBarHidden:NO animated:animated];
    }
}
- (BOOL)canShowTrajectory{
    if (self.selectedSupervision&&self.selectedSupervision.ID&&[self.selectedSupervision.ID length]>0) {
        return YES;
    }
    return NO;
}
- (BOOL)selectedTrajectoryIndex:(id)number{
    NSNumber *pos=(NSNumber*)number;
    int index=[pos intValue];
    if (index>=1&&index<4) {
        if (![self canShowTrajectory]) {
            return NO;
        }
    }
    return YES;
}
//获取设置的Tab选中项
- (void)setSelectedTabIndex:(id)num{
    NSNumber *number=(NSNumber*)num;
    int index=[number intValue];
    if (index==1) {//轨迹
        PersonTrajectoryViewController *viewController2=[[PersonTrajectoryViewController alloc] init];
        viewController2.Entity=self.selectedSupervision;
        [self.navigationController pushViewController:viewController2 animated:YES];
        [viewController2 release];
    }
    if (index==2) {//电话
        CallTrajectoryViewController *viewController2=[[CallTrajectoryViewController alloc] init];
        viewController2.Entity=self.selectedSupervision;
        [self.navigationController pushViewController:viewController2 animated:YES];
        [viewController2 release];
    }
    if (index==3) {//信息
        TrajectoryMessageController *viewController2=[[TrajectoryMessageController alloc] init];
        viewController2.Entity=self.selectedSupervision;
        [self.navigationController pushViewController:viewController2 animated:YES];
        [viewController2 release];
    }
    if (index==4) {//应用中心
        MoreViewController *viewController2=[[MoreViewController alloc] init];
        [self.navigationController pushViewController:viewController2 animated:YES];
        [viewController2 release];
    }
}
//更新一次
- (void)changedAdTimer:(NSTimer *)timer
{
    [self startUserLocation];//当前定位
    [self loadSupervision];
}
- (void)setOrginTrajectorySupersion{
    if(self.cells&&[self.cells count]>0)
    {
        if ([self canShowTrajectory]) {
            SupervisionPerson *entity=[self findByGuidEntity:self.selectedSupervision.ID];
            [self setRecetiveSupersion:entity];
            return;
        }
    }
    [self setRecetiveSupersion:nil];
}
- (SupervisionPerson*)findByGuidEntity:(NSString*)guid{
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
- (void)setRecetiveSupersion:(SupervisionPerson*)entity{
    self.selectedSupervision=entity;
    if (entity&&entity.ID&&[entity.ID length]>0) {
        [self loadingReadCountWithId:entity.ID];//加载记录总数
    }else{
        [self updateInfoUI:0];
    }
}
- (void)loadingReadCountWithId:(NSString*)personId{
    Account *acc=[Account unarchiverAccount];
    NSMutableArray *params=[NSMutableArray array];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:acc.WorkNo,@"workno", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:personId,@"personid", nil]];
    
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.methodName=@"GetNotReadCounts";
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.soapParams=params;
    
    [ServiceHelper asynService:args success:^(ServiceResult *result) {
        BOOL boo=NO;
        if (result.hasSuccess) {
            NSDictionary *dic=[result json];
            int total=[[dic objectForKey:@"Result"] intValue];
            if (total>0) {
                boo=YES;
                [self updateInfoUI:total];
            }
        }
        if (!boo) {
            [self updateInfoUI:0];
        }
        
    } failed:^(NSError *error, NSDictionary *userInfo) {
        [self updateInfoUI:0];
    }];
}
- (void)updateInfoUI:(int)total{
    
    [_recordView setRecordCount:total];
    if (_recordView.hasValue) {
        
        if (![self.view.subviews containsObject:_recordView]) {
            CGRect r=_recordView.frame;
            CGFloat w=DeviceWidth/5;
            if (r.size.width>w/2) {
                r.origin.x=DeviceWidth/3+(w-r.size.width)/2+5;
            }else{
                r.origin.x=DeviceWidth*4/5-DeviceWidth/10;
            }
            _recordView.frame=r;
            [self.view addSubview:_recordView];
        }
    }else{
        if ([self.view.subviews containsObject:_recordView]) {
            [_recordView removeFromSuperview];
        }
    }
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //更新记录总数
    if([self canShowTrajectory])
    {
        [self loadingReadCountWithId:self.selectedSupervision.ID];
    }else{
        [self updateInfoUI:0];
    }
    
    [self.navBarView setCompassButtonWithTarget:self action:@selector(buttonCompassClick)];
    [self.navBarView setTargetButtonWithTarget:self action:@selector(buttonTargetClick)];
    [self.navBarView setMonitorButtonWithTarget:self action:@selector(buttonMonitorClick)];
    
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
    if (isGps) {
        isGps=NO;
        [self startUserLocation];//当前定位
    }else{
        if ([NetWorkConnection locationServicesEnabled]) {//表示开启定位功能
            [self startUserLocation];//当前定位
        }
    }
    if (isPushController) {//popController后执行的对象
        isPushController=NO;
        if (_mapView.annotations.count==0||_mapView.annotations.count==1) {
             [self reloadDataSupervisionAnnotations];//重新加载
        }
    }
    [_updateTimer resume]; //恢复计时器
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    //暂停计时器
    [_updateTimer pause];
    isPushController=YES;
}
//当前定位
- (void)startUserLocation{
    if (_mapView.annotations&&[_mapView.annotations count]>0) {
        NSArray* arr = [NSArray arrayWithArray:_mapView.annotations];
        for (NSInteger i = 0;i<[arr count];i++) {
            id elem = [arr objectAtIndex:i];
            if ([elem isKindOfClass:[BMKUserLocation class]]||[elem isKindOfClass:[BMKPointAnnotation class]]) {
                [_mapView removeAnnotation:elem];
            }
            
        }
    }
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
}
- (void)loadSupervision{

    Account *acc=[Account unarchiverAccount];
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.methodName=@"GetSuperviseInfo";
    args.soapParams=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:acc.WorkNo,@"WorkNo", nil], nil];
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        BOOL boo=NO;
        if (result.hasSuccess) {
            NSDictionary *dic=[result json];
            NSArray *source=[dic objectForKey:@"Person"];
            self.cells=[NSMutableArray arrayWithArray:[AppHelper arrayWithSource:source className:@"SupervisionPerson"]];
            [self removeSupervisionAnnotations];//移除之前标注
            if (self.cells&&[self.cells count]>0) {
                boo=YES;
                //加载监管目标
                for (int i=0; i<self.cells.count; i++) {
                    SupervisionPerson *entity=self.cells[i];
                    if ([entity.Latitude length]==0||[entity.Longitude length]==0) {
                        continue;
                    }
                    CLLocationCoordinate2D coor;
                    coor.latitude=[entity.Latitude floatValue];
                    coor.longitude=[entity.Longitude floatValue];
                    KYPointAnnotation* item = [[KYPointAnnotation alloc] init];
                    item.laglnt=entity.ID;
                    item.coordinate =coor;
                    item.title=@"当前位置";
                    item.tag=100+i;
                    [_mapView addAnnotation:item];
                    [item release];
                    if (isFirstLoad) {
                        isFirstLoad=NO;
                        [_mapView setCenterCoordinate:coor];
                    }
                    
                }
                [self setChoosetTarget];//设置选中监管目标
            }
           
        }
      [self setOrginTrajectorySupersion];//加载记录总数
    } failed:^(NSError *error, NSDictionary *userInfo) {
        [self setOrginTrajectorySupersion];//加载记录总数
    }];
}
-(void)cleanMap
{
    [_mapView removeOverlays:_mapView.overlays];
    //[_mapView removeAnnotations:_mapView.annotations];
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
}
//显示当前定位
- (void)buttonCompassClick{
    if ([NetWorkConnection locationServicesEnabled]) {
        if (currentCoor.latitude>0&&currentCoor.longitude>0) {
            [_mapView setCenterCoordinate:currentCoor];
        }
    }else{
        [self startUserLocation];//当前定位
    }
}
//新增监管目标
- (void)buttonTargetClick{
    AddSupervision *supervision=[[AddSupervision alloc] init];
    supervision.operateType=1;//新增
    [self.navigationController pushViewController:supervision animated:YES];
    [supervision release];
}
//监管列表
- (void)buttonMonitorClick{
    MonitorPersonViewController *supervision=[[MonitorPersonViewController alloc] init];
    [self.navigationController pushViewController:supervision animated:YES];
    [supervision release];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    
     BMKPinAnnotationView *newAnnotation = (BMKPinAnnotationView*)[mapView viewForAnnotation:annotation];
    NSString *AnnotationViewID =@"renameMark";
     if ([annotation isKindOfClass:[KYPointAnnotation class]]) {
        AnnotationViewID = [NSString stringWithFormat:@"renameMark%d",[(KYPointAnnotation*)annotation tag]];
     }
     if (newAnnotation == nil) {
         newAnnotation = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        
         if ([annotation isKindOfClass:[KYPointAnnotation class]]) {
             int pos=[(KYPointAnnotation*)annotation tag]-100;
             //自定义图片
             //UIImage* image = [self getPinImageWithLevel:mapView.zoomLevel source:self.cells[pos]];
             //newAnnotation.image = image;
             [newAnnotation setPinImageWithEntity:self.cells[pos] mapLevel:mapView.zoomLevel];
             
             //newAnnotation.annotation = annotation;
             newAnnotation.centerOffset = CGPointMake(0, -(newAnnotation.frame.size.height * 0.5));
             newAnnotation.annotation = annotation;
             //自定义气泡
             TrajectoryPaoView *_areaPaoView=[[[TrajectoryPaoView alloc] initWithFrame:CGRectMake(0, 0, 250, 350)] autorelease];
             _areaPaoView.tag=200+pos;
             _areaPaoView.controls=self;
             [_areaPaoView setDataSource:self.cells[pos]];
             BMKActionPaopaoView *paopao=[[BMKActionPaopaoView alloc] initWithCustomView:_areaPaoView];
             newAnnotation.paopaoView=paopao;
             [paopao release];
         }else{
             // 设置颜色
             ((BMKPinAnnotationView*)newAnnotation).pinColor = BMKPinAnnotationColorRed;
             // 从天上掉下效果
             ((BMKPinAnnotationView*)newAnnotation).animatesDrop = YES;
         }
     }else{
         if ([annotation isKindOfClass:[KYPointAnnotation class]]) {
              int pos=[(KYPointAnnotation*)annotation tag]-100;
             [newAnnotation setPinImageWithEntity:self.cells[pos] mapLevel:mapView.zoomLevel];
         }
     }
     return newAnnotation;
}
- (void)mapView:(BMKMapView *)mapView1 didUpdateUserLocation:(BMKUserLocation *)userLocation
{
   /******/
    BMKCoordinateRegion region;
    region.center.latitude  = userLocation.location.coordinate.latitude;
    region.center.longitude = userLocation.location.coordinate.longitude;
    region.span.latitudeDelta  = 0.2;
    region.span.longitudeDelta = 0.2;
    if (_mapView)
    {
        _mapView.region = region;
    }
    
    _mapView.showsUserLocation=NO;
}
//定位失败

-(void)mapView:(BMKMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
    [mapView setShowsUserLocation:NO];
    
    [self setChoosetTarget];
    

}
- (void)setChoosetTarget{
    if ([self canShowTrajectory]) {
        self.laglnt=self.selectedSupervision.ID;
    }
    //设置监管目标选中
    if (_mapView.annotations&&[_mapView.annotations count]>0) {
        NSArray* arr = [NSArray arrayWithArray:_mapView.annotations];
        for (NSInteger i = 0;i<[arr count];i++) {
            id elem = [arr objectAtIndex:i];
            if ([elem isKindOfClass:[KYPointAnnotation class]]) {
                KYPointAnnotation *annotation=(KYPointAnnotation*)elem;
                if([annotation.laglnt isEqualToString:self.laglnt])
                {
                    [_mapView selectAnnotation:annotation animated:YES];
                    [_mapView setCenterCoordinate:annotation.coordinate];
                    self.laglnt=@"";
                    break;
                }
            }
            
        }
    }

}
//定位停止
-(void)mapViewDidStopLocatingUser:(BMKMapView *)mapView{

  
    BMKUserLocation *userLocation = mapView.userLocation;
    userLocation.title = @"当前位置";
    currentCoor= userLocation.coordinate;//保存当前定位
    [_mapView addAnnotation:userLocation];
    /***
    BMKPointAnnotation *annotation=[[BMKPointAnnotation alloc] init];
    annotation.title=@"当前位置";
    annotation.coordinate=userLocation.coordinate;//保存当前定位
    [_mapView addAnnotation:annotation];
    [annotation release];
     ***/
    
   
    [self setChoosetTarget];
   
    if ([self.cells count]==0) {
        [_mapView setCenterCoordinate:userLocation.coordinate];
    }
    
    //当前中心点
   
    //选中一项
    /***
    if (self.cells&&[self.cells count]>0) {
        for (int i=0; i<self.cells.count; i++) {
            SupervisionPerson *entity=self.cells[i];
            if ([entity.Latitude length]>0&&[entity.Longitude length]>0) {
                CLLocationCoordinate2D coor;
                coor.latitude=[entity.Latitude floatValue];
                coor.longitude=[entity.Longitude floatValue];
                [_mapView setCenterCoordinate:coor];
                break;
            }
        }
    }
     ***/
    //poi检索  异步函数，返回结果在BMKSearchDelegate里的onGetPoiResult:searchType:errorCode:通知
}
//选中
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
   
    if ([view.annotation isKindOfClass:[KYPointAnnotation class]]) {//选中监管目标
        KYPointAnnotation *elem=(KYPointAnnotation*)view.annotation;
        int index=elem.tag-100;
        SupervisionPerson *entity=self.cells[index];
        [self setRecetiveSupersion:entity];
        
        if ([[view.paopaoView viewWithTag:200+index] isKindOfClass:[TrajectoryPaoView class]]) {
            TrajectoryPaoView *pao=(TrajectoryPaoView*)[view.paopaoView viewWithTag:200+index];
            [pao loadDataSource];//重载数据
        }
         //BMKPinAnnotationView *newAnnotation = (BMKPinAnnotationView*)[mapView viewForAnnotation:annotation];
    }
}
//双击事件
- (void)mapview:(BMKMapView *)mapView onDoubleClick:(CLLocationCoordinate2D)coordinate{
    [self reloadAnnotations:mapView];
   
}
//区域发生改变时，调用
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
   
    [self reloadAnnotations:mapView];
}
//重新加载标注
- (void)reloadAnnotations:(BMKMapView *)mapView{
    // NSLog(@"orgin level=%f",orginLevel);
    if (orginLevel>6&&mapView.zoomLevel<6) {
        orginLevel=mapView.zoomLevel;
        [self removeSupervisionAnnotations];//移除之前标注
        //NSLog(@"当前地图等级小于6，count=%d",_mapView.annotations.count);
        [self reloadDataSupervisionAnnotations];
        //return;
    }
    if (orginLevel<6&&mapView.zoomLevel>6) {
        orginLevel=mapView.zoomLevel;
        [self removeSupervisionAnnotations];//移除之前标注,在重新加载
         //NSLog(@"当前地图等级大于6，count=%d",_mapView.annotations.count);
        [self reloadDataSupervisionAnnotations];
    }
}
- (void)removeSupervisionAnnotations{
    if (_mapView.annotations&&[_mapView.annotations count]>0) {
        NSArray* arr = [NSArray arrayWithArray:_mapView.annotations];
        for (NSInteger i = 0;i<[arr count];i++) {
            id elem = [arr objectAtIndex:i];
            if ([elem isKindOfClass:[KYPointAnnotation class]]) {
                [_mapView removeAnnotation:elem];
            }
            
        }
    }
}
- (void)reloadDataSupervisionAnnotations{
    if (self.cells&&[self.cells count]>0) {
        //加载监管目标
        for (int i=0; i<self.cells.count; i++) {
            SupervisionPerson *entity=self.cells[i];
            if ([entity.Latitude length]==0||[entity.Longitude length]==0) {
                continue;
            }
            CLLocationCoordinate2D coor;
            coor.latitude=[entity.Latitude floatValue];
            coor.longitude=[entity.Longitude floatValue];
            KYPointAnnotation* item = [[KYPointAnnotation alloc] init];
            item.laglnt=entity.ID;
            item.coordinate =coor;
            item.title=@"当前位置";
            item.tag=100+i;
            [_mapView addAnnotation:item];
            [item release];
            //[_mapView setCenterCoordinate:coor];
        }
    }
}
@end
