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
#import "SupervisionPerson.h"
#import "KYPointAnnotation.h"
#import "TrajectoryPaoView.h"
@interface IndexViewController ()
- (void)buttonCompassClick;
- (void)buttonTargetClick;
- (void)buttonMonitorClick;
- (void)cleanMap;
- (void)startUserLocation;
@end

@implementation IndexViewController
- (void)dealloc {
    [super dealloc];
    if (_mapView) {
        [_mapView release];
        _mapView = nil;
    }
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
    CGRect r=self.view.bounds;
    r.origin.y=44;
    r.size.height-=TabHeight+44;
    _mapView= [[BMKMapView alloc]initWithFrame:r];
    [self.view addSubview:_mapView];
    
    /***
    NSString *memo=@"亲";
    CGSize size=[memo textSize:[UIFont fontWithName:DeviceFontName size:DeviceFontSize] withWidth:self.view.bounds.size.width];
    NSLog(@"size=%@",NSStringFromCGSize(size));
     ***/
   // [_mapView addObserver:self forKeyPath:@"zoomLevel" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navBarView setCompassButtonWithTarget:self action:@selector(buttonCompassClick)];
    [self.navBarView setTargetButtonWithTarget:self action:@selector(buttonTargetClick)];
    [self.navBarView setMonitorButtonWithTarget:self action:@selector(buttonMonitorClick)];
    
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
    
    [self loadSupervision];
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
 
}
//当前定位
- (void)startUserLocation{
    [self cleanMap];
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
                    item.coordinate =coor;
                    item.title=@"当前位置";
                    item.tag=100+i;
                    [_mapView addAnnotation:item];
                    [item release];
                }
            }
        }
        if (!boo) {
            [self startUserLocation];
        }
    } failed:^(NSError *error, NSDictionary *userInfo) {
        [self startUserLocation];
    }];
}
-(void)cleanMap
{
    [_mapView removeOverlays:_mapView.overlays];
    //[_mapView removeAnnotations:_mapView.annotations];
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
}
//设置当前地图等级
- (void)buttonCompassClick{
    
}
//新增监管目标
- (void)buttonTargetClick{
    AddSupervision *supervision=[[AddSupervision alloc] init];
    [self.navigationController pushViewController:supervision animated:YES];
    [supervision release];
}
//监管列表
- (void)buttonMonitorClick{
    SupervisionViewController *supervision=[[SupervisionViewController alloc] init];
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
     NSString *AnnotationViewID = @"renameMark";
     if ([annotation isKindOfClass:[KYPointAnnotation class]]) {
        AnnotationViewID = [NSString stringWithFormat:@"renameMark%d",[(KYPointAnnotation*)annotation tag]];
     }
     if (newAnnotation == nil) {
         newAnnotation = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
         // 设置颜色
         ((BMKPinAnnotationView*)newAnnotation).pinColor = BMKPinAnnotationColorRed;
         // 从天上掉下效果
         ((BMKPinAnnotationView*)newAnnotation).animatesDrop = YES;
         
         if ([annotation isKindOfClass:[KYPointAnnotation class]]) {
             int pos=[(KYPointAnnotation*)annotation tag]-100;
             
             newAnnotation.centerOffset = CGPointMake(0, -(newAnnotation.frame.size.height * 0.5));
             newAnnotation.annotation = annotation;
             //自定义气泡
             TrajectoryPaoView *_areaPaoView=[[[TrajectoryPaoView alloc] initWithFrame:CGRectMake(0, 0, 300, 350)] autorelease];
             [_areaPaoView setDataSource:self.cells[pos]];
             BMKActionPaopaoView *paopao=[[BMKActionPaopaoView alloc] initWithCustomView:_areaPaoView];
             newAnnotation.paopaoView=paopao;
             [paopao release];
         }
         // 设置可拖拽
         //((BMKPinAnnotationView*)newAnnotation).draggable = YES;
     }
     return newAnnotation;
}
- (void)mapView:(BMKMapView *)mapView1 didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    BMKCoordinateRegion region;
    region.center.latitude  = userLocation.location.coordinate.latitude;
    region.center.longitude = userLocation.location.coordinate.longitude;
    region.span.latitudeDelta  = 0.2;
    region.span.longitudeDelta = 0.2;
    if (_mapView)
    {
        _mapView.region = region;
        //NSLog(@"当前的坐标是: %f,%f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    }
    _mapView.showsUserLocation=NO;
}
//定位失败

-(void)mapView:(BMKMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
    [mapView setShowsUserLocation:NO];
}
//定位停止
-(void)mapViewDidStopLocatingUser:(BMKMapView *)mapView{
    //添加圆形覆盖
    //BMKCircle* circle = [BMKCircle circleWithCenterCoordinate:mapView.centerCoordinate radius:1000];
    //[mapView addOverlay:circle];
    
    
    BMKPointAnnotation* item = [[BMKPointAnnotation alloc] init];
    item.coordinate = mapView.centerCoordinate;
    item.title=@"当前位置";
    [_mapView addAnnotation:item];
    [item release];
    
    /*
     //标记我的位置
     BMKUserLocation *userLocation = mapView.userLocation;
     userLocation.title = @"当前位置";
     [_mapView addAnnotation:userLocation];
     */
    //poi检索  异步函数，返回结果在BMKSearchDelegate里的onGetPoiResult:searchType:errorCode:通知
}
//选中
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[KYPointAnnotation class]]) {//选中监管目标
        KYPointAnnotation *elem=(KYPointAnnotation*)view.annotation;
        int index=elem.tag-100;
        SupervisionPerson *entity=self.cells[index];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"trajectTarget" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:entity,@"Entity", nil]];
    }
}

@end
