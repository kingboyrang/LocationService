//
//  ModifyAreaViewController.m
//  LocationService
//
//  Created by aJia on 2014/1/2.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import "ModifyAreaViewController.h"
#import "LoginButtons.h"
#import "KYPointAnnotation.h"
#import "KYBubbleView.h"
#import "Account.h"
#import "AreaRangeViewController.h"
#import "AreaRuleViewController.h"
@interface ModifyAreaViewController (){
    UISlider *_silder;
    UILabel* _labDistance;
    KYPointAnnotation* pointAnnotation;
    KYBubbleView *bubbleView;
    BOOL isPinSelected;     //用于判断大头针是否被选中
    BMKAnnotationView *selectedAV;
}
- (void)buttonNextClick:(id)sender;
- (void)buttonFinishedClick:(id)sender;
- (void)changeSilderValue:(id)sender;
-(void)cleanMap;
- (void)addAreaCompleted:(void(^)(NSString* areaId))completed;
@end

@implementation ModifyAreaViewController
static CGFloat kTransitionDuration = 0.45f;
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
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navBarView setNavBarTitle:@"电子围栏"];
    
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
    
    [self cleanMap];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    isPinSelected=NO;
    bubbleView = [[KYBubbleView alloc] initWithFrame:CGRectMake(0, 0, 180, 40)];
    bubbleView.hidden = YES;
    
    
    CGRect r=self.view.bounds;
    r.origin.y=44;
    r.size.height-=44*2+73;
    _mapView= [[BMKMapView alloc]initWithFrame:r];
    [self.view addSubview:_mapView];
    _mapView.zoomLevel = 16;
    
    
    CGFloat topY=r.origin.y+r.size.height+5;
    _labDistance=[[UILabel alloc] initWithFrame:CGRectMake(0, topY, self.view.bounds.size.width-10*2, 20)];
    _labDistance.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    _labDistance.text=@"100米";
    _labDistance.textColor=[UIColor blackColor];
    _labDistance.textAlignment=NSTextAlignmentRight;
    _labDistance.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_labDistance];
    topY+=25;
    _silder=[[UISlider alloc] initWithFrame:CGRectMake(10, topY, self.view.bounds.size.width-10*2, 23)];
    _silder.minimumValue=0.0;
    _silder.maximumValue=100;
    _silder.value=10.0;
    [_silder addTarget:self action:@selector(changeSilderValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_silder];
    
    LoginButtons *buttons=[[LoginButtons alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    [buttons.cancel setTitle:@"下一步" forState:UIControlStateNormal];
    [buttons.cancel addTarget:self action:@selector(buttonNextClick:) forControlEvents:UIControlEventTouchUpInside];
    [buttons.submit setTitle:@"完成" forState:UIControlStateNormal];
    [buttons.submit addTarget:self action:@selector(buttonFinishedClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttons];
    [buttons release];
}
//发生改变
- (void)changeSilderValue:(id)sender{
    int meter=(int)_silder.value*10;
     _labDistance.text=[NSString stringWithFormat:@"%d米",meter];
}
//下一步
- (void)buttonNextClick:(id)sender{
    [self addAreaCompleted:^(NSString *areaId) {
        [self hideLoadingViewAnimated:^(AnimateLoadView *hideView) {
            AreaRuleViewController *areaRange=[[AreaRuleViewController alloc] init];
            [self.navigationController pushViewController:areaRange animated:YES];
            [areaRange release];
        }];
    }];
}
- (void)addAreaCompleted:(void(^)(NSString* areaId))completed{
    Account *acc=[Account unarchiverAccount];
    
    NSMutableArray *params=[NSMutableArray array];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:bubbleView.field.text,@"AreaName", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"remark", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"LinePointArystr", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",_silder.value],@"CircleRedius", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Rotundity",@"AreaType", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:acc.WorkNo,@"Workno", nil]];
    
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.methodName=@"AddArea";
    args.soapParams=params;
    [self showLoadingAnimatedWithTitle:@"正在新增,请稍后..."];
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        BOOL boo=NO;
        if (result.hasSuccess) {
            NSDictionary *dic=[result json];
            if (dic!=nil&&![[dic objectForKey:@"Result"] isEqualToString:@"Fail"]&&![[dic objectForKey:@"Result"] isEqualToString:@"Error"]) {
                boo=YES;
                if (completed) {
                    completed([dic objectForKey:@"Result"]);
                }
            }
        }
        if (!boo) {
            [self hideLoadingFailedWithTitle:@"新增失败!" completed:nil];
        }
    } failed:^(NSError *error, NSDictionary *userInfo) {
        [self hideLoadingFailedWithTitle:@"新增失败!" completed:nil];
    }];

}
//完成
- (void)buttonFinishedClick:(id)sender{
    [self addAreaCompleted:^(NSString *areaId) {
        [self hideLoadingViewAnimated:^(AnimateLoadView *hideView) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark mapViewDelegate 代理方法
// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    BMKPinAnnotationView *annotationView = (BMKPinAnnotationView*)[mapView viewForAnnotation:annotation];
    if (annotationView == nil)
    {
        KYPointAnnotation *ann;
        if ([annotation isKindOfClass:[KYPointAnnotation class]]) {
            ann = annotation;
        }
        NSUInteger tag =123;
        //ann.tag;
        NSString *AnnotationViewID = [NSString stringWithFormat:@"AnnotationView-%i", tag];
        annotationView = [[[BMKPinAnnotationView alloc] initWithAnnotation:annotation
                                                           reuseIdentifier:AnnotationViewID] autorelease];
         // 设置颜色
        ((BMKPinAnnotationView*) annotationView).pinColor = BMKPinAnnotationColorRed;
        // 设置该标注点动画显示
		((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
        // 设置可拖拽
		((BMKPinAnnotationView*)annotationView).draggable = YES;
        
        
        annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
        annotationView.annotation = annotation;
        
	}
	return annotationView ;
    /***
    NSString *AnnotationViewID = @"renameMark";
    if (newAnnotation == nil) {
        newAnnotation = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        // 设置颜色
		((BMKPinAnnotationView*)newAnnotation).pinColor = BMKPinAnnotationColorPurple;
        // 从天上掉下效果
		((BMKPinAnnotationView*)newAnnotation).animatesDrop = YES;
        // 设置可拖拽
		((BMKPinAnnotationView*)newAnnotation).draggable = YES;
    }
    return newAnnotation;
     ***/
    
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
    pointAnnotation = [[KYPointAnnotation alloc] init];
    pointAnnotation.tag=123;
    pointAnnotation.coordinate = mapView.centerCoordinate;
    pointAnnotation.title = @"当前位置";
    [_mapView addAnnotation:pointAnnotation];
   // [pointAnnotation release];
    
 
    
    
}
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    isPinSelected = YES;
    //CGPoint point = [mapView convertCoordinate:view.annotation.coordinate toPointToView:mapView];
    if ([view isKindOfClass:[BMKPinAnnotationView class]]) {
#ifdef Debug
        CGPoint point = [mapView convertCoordinate:selectedAV.annotation.coordinate toPointToView:selectedAV.superview];
        //CGRect rect = selectedAV.frame;
       
#endif
        selectedAV = view;
        if (bubbleView.superview == nil) {
			//bubbleView加在BMKAnnotationView的superview(UIScrollView)上,且令zPosition为1
            [view.superview addSubview:bubbleView];  //为大头针添加自定义对气泡view
            bubbleView.layer.zPosition = 1;
        }
        //bubbleView.infoDict = [dataArray objectAtIndex:[(KYPointAnnotation*)view.annotation tag]];  //数据全部在数据字典中
        //bubbleView.infoDict = [dataArray objectAtIndex:0];  //数据全部在数据字典中
        //        [self showBubble:YES];//先移动地图，完成后再显示气泡
    }
    else {
        selectedAV = nil;
    }
    [mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
}

- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view
{
    
    isPinSelected = NO;
    if ([view isKindOfClass:[BMKPinAnnotationView class]]) {
        [self showBubble:NO];
    }
}

#pragma mark 区域改变
- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if (selectedAV) {
#ifdef Debug
        CGPoint point = [mapView convertCoordinate:selectedAV.annotation.coordinate toPointToView:selectedAV.superview];
        //CGRect rect = selectedAV.frame;
       
#endif
    }
    
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (selectedAV) {
        if (isPinSelected) {    //只有当大头针被选中时的区域改变才会显示气泡
            [self showBubble:YES];       //modify 地图区域改变  - 原代码是没有注释的
            [self changeBubblePosition];
        }
    }
    
}

- (void)showBubble:(BOOL)show {
    if (show) {
        [bubbleView showFromRect:selectedAV.frame];
       
        
        bubbleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kTransitionDuration/3];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
        bubbleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        bubbleView.hidden = NO;
       
        [UIView commitAnimations];
        
    }
    else {
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kTransitionDuration/3];
       
        bubbleView.hidden = YES;
        [UIView commitAnimations];
    }
}
- (void)changeBubblePosition {
    if (selectedAV) {
        CGRect rect = selectedAV.frame;
        CGPoint center;
        center.x = rect.origin.x + rect.size.width/2;
        center.y = rect.origin.y - bubbleView.frame.size.height/2 + 8;
        bubbleView.center = center;
    }
}

@end
