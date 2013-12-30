//
//  IndexViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/23.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "IndexViewController.h"

@interface IndexViewController ()
- (void)buttonCompassClick;
- (void)buttonTargetClick;
- (void)buttonMonitorClick;
-(void)cleanMap;
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
    r.size.height-=82+44;
    _mapView= [[BMKMapView alloc]initWithFrame:r];
    [self.view addSubview:_mapView];
    
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navBarView setCompassButtonWithTarget:self action:@selector(buttonCompassClick)];
    [self.navBarView setTargetButtonWithTarget:self action:@selector(buttonTargetClick)];
    [self.navBarView setMonitorButtonWithTarget:self action:@selector(buttonMonitorClick)];
    
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
    
    [self cleanMap];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
}
-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    
    
}
-(void)cleanMap
{
    [_mapView removeOverlays:_mapView.overlays];
    //[_mapView removeAnnotations:_mapView.annotations];
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
}
- (void)buttonCompassClick{

}
- (void)buttonTargetClick{
    
}
- (void)buttonMonitorClick{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark mapViewDelegate 代理方法
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
@end
