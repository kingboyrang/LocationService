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
#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

@interface ShowTrajectoryViewController ()
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
    
    [self cleanMap];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _trajectorySearch=[[TrajectorySearch alloc] initWithFrame:CGRectMake(0, 44-79, self.view.bounds.size.width, 79)];
    [_trajectorySearch.button addTarget:self action:@selector(buttonSearchClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_trajectorySearch];
    [self.view sendSubviewToBack:_trajectorySearch];
    
    CGRect r=self.view.bounds;
    r.origin.y=44;
    r.size.height-=82+44;
    _mapView= [[BMKMapView alloc]initWithFrame:r];
    [self.view addSubview:_mapView];
}
-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    
}
//查询
- (void)buttonSearchClick{
    [self loadingHistory];
}
//查询
- (void)buttonSwitchClick:(id)sender{
    UIButton *btn=(UIButton*)sender;
    if (btn.selected) {//隐藏
        CGRect r=self.trajectorySearch.frame;
        r.origin.y=44-r.size.height;
        
        CGRect r1=_mapView.frame;
        r1.origin.y=44;
        r1.size.height=self.view.bounds.size.height-r1.origin.y;
        
        [UIView animateWithDuration:0.5f animations:^{
            self.trajectorySearch.frame=r;
            _mapView.frame=r1;
            btn.selected=NO;
            [self.view sendSubviewToBack:self.trajectorySearch];
        }];
    }else{//显示
        [self.view sendSubviewToBack:_mapView];
        
        CGRect r=self.trajectorySearch.frame;
        r.origin.y=44;
        
        CGRect r1=_mapView.frame;
        r1.origin.y=44+r.size.height;
        r1.size.height=self.view.bounds.size.height-r1.origin.y;
        
        [UIView animateWithDuration:0.5f animations:^{
            self.trajectorySearch.frame=r;
            _mapView.frame=r1;
            btn.selected=YES;
            
        }];
    }
}
- (void)loadingHistory{
    
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
    
    [self showLoadingAnimatedWithTitle:@"正在查询,请稍后..."];
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        
        BOOL boo=NO;
        if (result.hasSuccess) {
            XmlNode *node=[result methodNode];
            NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[node.InnerText dataUsingEncoding:NSUTF8StringEncoding] options:1 error:nil];
            if ([dic.allKeys containsObject:@"Person"]) {
                boo=YES;
                [self hideLoadingViewAnimated:^(AnimateLoadView *hideView) {
                    NSArray *source=[dic objectForKey:@"Person"];
                    self.list=[AppHelper arrayWithSource:source className:@"TrajectoryHistory"];
                   //重新加载地图
                    [self loadingPointAnnotations];
                }];
            }
        }
        if (!boo) {
            [self hideLoadingFailedWithTitle:@"查询失败!" completed:nil];
        }
        
    } failed:^(NSError *error, NSDictionary *userInfo) {
        //NSLog(@"error=%@",error.debugDescription);
        [self hideLoadingFailedWithTitle:@"查询失败!" completed:nil];
    }];
}
- (void)loadingPointAnnotations
{
    [self cleanMap];
    if (self.list&&[self.list count]>0) {
        for (int i=0; i<self.list.count; i++) {
            TrajectoryHistory *entity=self.list[i];
            
            CLLocationCoordinate2D coor;
            coor.latitude=[entity.Latitude floatValue];
            coor.longitude=[entity.Longitude floatValue];
            
            KYPointAnnotation *item=[[KYPointAnnotation alloc] init];
            item.coordinate=coor;
            item.title=@"当前位置";
            item.tag=100+i;
            [_mapView addAnnotation:item];
            [item release];
            [_mapView setCenterCoordinate:coor];
        }
    }
}
-(void)cleanMap
{
    [_mapView removeOverlays:_mapView.overlays];
    //[_mapView removeAnnotations:_mapView.annotations];
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
}
- (NSString*)getMyBundlePath1:(NSString *)filename
{
	
	NSBundle * libBundle = MYBUNDLE ;
	if ( libBundle && filename ){
		NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent : filename];
		return s;
	}
	return nil ;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(id <BMKAnnotation>)routeAnnotation
{
    int index=0;
    NSString *annotaionIdentifier=@"route_node";
    if ([routeAnnotation isKindOfClass:[KYPointAnnotation class]]) {
        KYPointAnnotation *kypoint=(KYPointAnnotation*)routeAnnotation;
        index=kypoint.tag-100;
        annotaionIdentifier=[NSString stringWithFormat:@"route_node%d",kypoint.tag];
    }
    
	BMKAnnotationView* view = nil;
    view = [mapview dequeueReusableAnnotationViewWithIdentifier:annotaionIdentifier];
    if (view == nil) {
        view = [[[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:annotaionIdentifier] autorelease];
        view.canShowCallout = TRUE;
        
        //自定义气泡
        TrajectoryPaoView *_areaPaoView=[[[TrajectoryPaoView alloc] initWithFrame:CGRectMake(0, 0, 300, 350)] autorelease];
        [_areaPaoView setDataSourceHistory:self.list[index] name:self.Entity.Name];
        BMKActionPaopaoView *paopao=[[BMKActionPaopaoView alloc] initWithCustomView:_areaPaoView];
        view.paopaoView=paopao;
        [paopao release];
        
    } else {
        [view setNeedsDisplay];
    }
    
    UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_direction.png"]];
    view.image = image;
    view.annotation = routeAnnotation;
	return view;
}
@end
