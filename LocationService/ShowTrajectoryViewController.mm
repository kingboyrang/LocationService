//
//  ShowTrajectoryViewController.m
//  LocationService
//
//  Created by aJia on 2014/1/5.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import "ShowTrajectoryViewController.h"
#import "TrajectoryPaoView.h"
#import "KYPointAnnotation.h"
#import "Account.h"
#import "AppHelper.h"
#import "MeterViewController.h"
#import "NSDate+TPCategory.h"
#import "UIImage+TPCategory.h"
#import "IndexViewController.h"
#import "PersonTrajectoryViewController.h"
@interface ShowTrajectoryViewController (){
    BOOL isFirstLoad;
}
- (void)cleanMap;
- (void)loadingHistory;
- (void)loadingPointAnnotations;
@end

@implementation ShowTrajectoryViewController
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
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navBarView setNavBarTitle:[NSString stringWithFormat:@"%@--足迹",self.Entity.Name]];
    if (![self.navBarView viewWithTag:300]) {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(self.view.bounds.size.width-90, (44-35)/2, 50, 35);
        btn.tag=300;
        [btn setTitle:@"列表" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
        btn.showsTouchWhenHighlighted = YES;  //指定按钮被按下时发光
        [btn setTitleColor:[UIColor colorFromHexRGB:@"4a7ebb"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(buttonListClick) forControlEvents:UIControlEventTouchUpInside];
        [self.navBarView addSubview:btn];
    }
    if (![self.navBarView viewWithTag:301]) {
        
        UIImage *image=[UIImage imageNamed:@"bottomico.png"];
        
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(self.view.bounds.size.width-image.size.width-5, (44-image.size.height)/2, image.size.width, image.size.height);
        btn.tag=301;
        [btn setImage:image forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"topico.png"] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(buttonSwitchClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.navBarView addSubview:btn];
    }
    
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
    if (isFirstLoad) {
        isFirstLoad=NO;
        [self cleanMap];
        [self loadingHistory];
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _trajectorySearch=[[TrajectorySearch alloc] initWithFrame:CGRectMake(0, 44-79, self.view.bounds.size.width, 79)];
    [_trajectorySearch.button addTarget:self action:@selector(buttonSearchClick) forControlEvents:UIControlEventTouchUpInside];
    _trajectorySearch.backgroundColor=[UIColor whiteColor];
    _trajectorySearch.startCalendar.popoverText.popoverTextField.text=self.startTime;
    _trajectorySearch.endCalendar.popoverText.popoverTextField.text=self.endTime;
    [self.view addSubview:_trajectorySearch];
    [self.view sendSubviewToBack:_trajectorySearch];
    
    CGRect r=self.view.bounds;
    r.origin.y=44;
    r.size.height-=TabHeight;
    _mapView= [[BMKMapView alloc]initWithFrame:r];
    [self.view addSubview:_mapView];
    _mapView.zoomLevel=16;
    isFirstLoad=YES;
    
}
- (BOOL)backPrevViewController{
    if (self.navigationController) {
        if (self.navigationController.viewControllers.count==2) {
            id v=self.navigationController.viewControllers[0];
            if ([v isKindOfClass:[IndexViewController class]]) {
                IndexViewController *index=(IndexViewController*)v;
                [index.toolBarView setSelectedItemIndex:0];
            }
        }
    }
    PersonTrajectoryViewController *person=self.navigationController.viewControllers[self.navigationController.viewControllers.count-2];
    person.trajectorySearch.startCalendar.popoverText.popoverTextField.text=self.trajectorySearch.startCalendar.popoverText.popoverTextField.text;
    person.trajectorySearch.endCalendar.popoverText.popoverTextField.text=self.trajectorySearch.endCalendar.popoverText.popoverTextField.text;
    return YES;
}
-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    
}
- (void)selectedMetaWithEntity:(SupervisionPerson*)entity{
    MeterViewController *meter=[[MeterViewController alloc] init];
    meter.Entity=entity;
    [self.navigationController pushViewController:meter animated:YES];
    [meter release];
}
//列表
- (void)buttonListClick{
    [self.navigationController popViewControllerAnimated:YES];
}
//查询
- (void)buttonSearchClick{
    if (![_trajectorySearch compareToDate]) {
        return;
    }
    [self loadingHistory];
}
//查询
- (void)buttonSwitchClick:(id)sender{
    UIButton *btn=(UIButton*)sender;
    if (btn.selected) {//隐藏
        CGRect r=self.trajectorySearch.frame;
        r.origin.y=44-r.size.height;
        [UIView animateWithDuration:0.5f animations:^{
            self.trajectorySearch.frame=r;
            btn.selected=NO;
        } completion:^(BOOL finished) {
            if (finished) {
                [self.view sendSubviewToBack:self.trajectorySearch];
            }
        }];
    }else{//显示
        [self.view sendSubviewToBack:_mapView];
        
        CGRect r=self.trajectorySearch.frame;
        r.origin.y=44;
        
        [UIView animateWithDuration:0.5f animations:^{
            self.trajectorySearch.frame=r;
            btn.selected=YES;
            
        }];
    }
}
- (void)loadingHistory{
    //表示网络未连接
    if (![self hasNetWork]) {
        [self showErrorNetWorkNotice:nil];
        return;
    }
    Account *acc=[Account unarchiverAccount];
    NSMutableArray *params=[NSMutableArray array];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:acc.WorkNo,@"workno", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.Entity.ID,@"id", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.trajectorySearch.startCalendar.popoverText.popoverTextField.text,@"stime", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.trajectorySearch.endCalendar.popoverText.popoverTextField.text,@"etime", nil]];
    
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.methodName=@"ObjectHistoryInfo";
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.soapParams=params;
    
    [self showLoadingAnimatedWithTitle:@"正在加载足迹,请稍后..."];
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        
        BOOL boo=NO;
        if (result.hasSuccess) {
            XmlNode *node=[result methodNode];
            NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[node.InnerText dataUsingEncoding:NSUTF8StringEncoding] options:1 error:nil];
            if ([dic.allKeys containsObject:@"Person"]) {
                boo=YES;
                NSArray *source=[dic objectForKey:@"Person"];
                NSArray *arr=[AppHelper arrayWithSource:source className:@"TrajectoryHistory"];
                if(arr&&[arr count]>0)
                {
                    NSComparator cmptr = ^(id obj1, id obj2){
                        TrajectoryHistory *field1=(TrajectoryHistory*)obj1;
                        TrajectoryHistory *field2=(TrajectoryHistory*)obj2;
                        NSDate *date1=[NSDate dateFromString:field1.pctime withFormat:@"yyyy/MM/dd HH:mm:ss"];
                        NSDate *date2=[NSDate dateFromString:field2.pctime withFormat:@"yyyy/MM/dd HH:mm:ss"];
                        return [date1 compare:date2];
                        
                    };
                    self.list=[arr sortedArrayUsingComparator:cmptr];//降序排序
//                    for (TrajectoryHistory *item in self.list) {
//                        NSLog(@"time=%@",item.pctime);
//                    }
                    
                }else{
                    self.list=[NSArray array];
                }
                //重新加载地图
                [self loadingPointAnnotations];
                [self hideLoadingViewAnimated:^(AnimateLoadView *hideView) {
                  
                }];
            }
        }
        if (!boo) {
            [self hideLoadingFailedWithTitle:@"加载失败!" completed:nil];
        }
        
    } failed:^(NSError *error, NSDictionary *userInfo) {
        //NSLog(@"error=%@",error.debugDescription);
        [self hideLoadingFailedWithTitle:@"加载失败!" completed:nil];
    }];
}
- (void)loadingPointAnnotations
{
    [self cleanMap];
    if (self.list&&[self.list count]>0) {
        int numPoints=self.list.count;
        // 添加折线覆盖物
        //动态数组
        CLLocationCoordinate2D *points = (CLLocationCoordinate2D*)malloc( numPoints * sizeof( CLLocationCoordinate2D));
        for (int i=0; i<self.list.count; i++) {
            TrajectoryHistory *entity=self.list[i];
            //NSLog(@"time=%@",entity.pctime);
            CLLocationCoordinate2D coor;
            coor.latitude=[entity.Latitude floatValue];
            coor.longitude=[entity.Longitude floatValue];
            
            points[i].latitude=[entity.Latitude floatValue];
            points[i].longitude=[entity.Longitude floatValue];
            
            
            KYPointAnnotation *item=[[KYPointAnnotation alloc] init];
            item.coordinate=coor;
            item.title=@"当前位置";
            item.tag=100+i;
            [_mapView addAnnotation:item];
            [item release];
            if (i==self.list.count-1) {
                [_mapView setCenterCoordinate:coor animated:YES];
            }
        }
        //画线
        BMKPolyline* polyline = [BMKPolyline polylineWithCoordinates:points count:numPoints];
        [_mapView addOverlay:polyline];
    }
}
-(void)cleanMap
{
    [_mapView removeOverlays:_mapView.overlays];
    //[_mapView removeAnnotations:_mapView.annotations];
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
   
    NSString *annotaionIdentifier=[NSString createGUID];
    if ([annotation isKindOfClass:[KYPointAnnotation class]]) {
        annotaionIdentifier=[NSString stringWithFormat:@"%@%d",[NSString createGUID],[(KYPointAnnotation*)annotation tag]];
    }
	BMKAnnotationView* view = nil;
    view = [mapView dequeueReusableAnnotationViewWithIdentifier:annotaionIdentifier];
    if (view == nil) {
        view = [[[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotaionIdentifier] autorelease];
        //view.canShowCallout = TRUE;
        int pos=0;
        if ([annotation isKindOfClass:[KYPointAnnotation class]]) {
            KYPointAnnotation *p=(KYPointAnnotation*)annotation;
            pos=p.tag-100;
            
        }
        TrajectoryHistory *entity=self.list[pos];
        if (pos==0) {
            view.image=[UIImage imageNamed:@"mapapi.bundle/images/icon_nav_start.png"];
            view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
        }else if(pos==self.list.count-1)
        {
            view.image=[UIImage imageNamed:@"mapapi.bundle/images/icon_nav_end.png"];
            view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
        }else{
            //自定义图片
            //UIImage* image = [UIImage imageNamed:@"mapapi.bundle/images/icon_direction.png"];
            UIImage* image = [UIImage imageNamed:@"dirce1.png"];
            if (entity.angle&&[entity.angle length]>0) {
                view.image = [image imageRotatedByDegrees:[entity.angle floatValue]];
            }else{
                view.image = image;
            }
             view.enabled3D=YES;
        }
        view.annotation = annotation;
       
        //自定义气泡
        TrajectoryPaoView *_areaPaoView=[[[TrajectoryPaoView alloc] initWithFrame:CGRectMake(0, 0, 250, 350)] autorelease];
        [_areaPaoView setDataSourceHistory:entity name:self.Entity.Name];
        _areaPaoView.controls=self;
        BMKActionPaopaoView *paopao=[[[BMKActionPaopaoView alloc] initWithCustomView:_areaPaoView] autorelease];
        view.paopaoView=paopao;
        
    }
   	return view;
}
// Override
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKPolyline class]]){
        BMKPolylineView* polylineView = [[[BMKPolylineView alloc] initWithOverlay:overlay] autorelease];
        polylineView.strokeColor = [UIColor blueColor];
        polylineView.lineWidth = 2.0;
        return polylineView;
    }
    return nil;
}
//点击空白处调用此接口
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate{
   //隐藏搜索按钮
    
    CGRect r=self.trajectorySearch.frame;
    if (r.origin.y>0) {
        r.origin.y=44-r.size.height;
        [UIView animateWithDuration:0.5f animations:^{
            self.trajectorySearch.frame=r;
        } completion:^(BOOL finished) {
            if (finished) {
                [self.view sendSubviewToBack:self.trajectorySearch];
            }
        }];
    }
    
}
@end
