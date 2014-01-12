//
//  OfflineDemoMapViewController.m
//  BaiduMapSdkSrc
//
//  Created by BaiduMapAPI on 13-7-22.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import "OfflineDemoMapViewController.h"

@implementation OfflineDemoMapViewController
@synthesize cityId;
- (void)dealloc{
    [super dealloc];
    if (_mapView) {
        [_mapView release];
        _mapView = nil;
    }
    [_officeMap release],_officeMap=nil;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}    
- (void)viewDidLoad
{
    [super viewDidLoad];
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
//        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
       
    //显示当前某地的离线地图
    _mapView = [[BMKMapView alloc] init];
    [self setCurrentMapLevel:_mapView];
    _mapView.frame = CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-44);
    [self.view addSubview:_mapView];
    
    _officeMap=[[BMKOfflineMap alloc] init];
    
    BMKOLUpdateElement* localMapInfo;
    localMapInfo = [_officeMap getUpdateInfo:self.cityId];
    [_mapView setCenterCoordinate:localMapInfo.pt];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navBarView setNavBarTitle:@"查看离线地图"];
    
    [_mapView viewWillAppear];
    //_mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    //_mapView.delegate = nil; // 不用时，置nil
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
