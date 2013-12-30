//
//  DownloadMapController.h
//  LocationService
//
//  Created by aJia on 2013/12/30.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
@interface DownloadMapController : BasicViewController<BMKOfflineMapDelegate,BMKMapViewDelegate>{
   BMKMapView* _mapView;//.xib里要有BMKMapView类用于初始化数据驱动
   BMKOfflineMap* _offlineMap;
   NSArray* _arrayHotCityData;//热门城市
   NSArray* _arrayOfflineCityData;//全国支持离线地图的城市
   NSArray* _arraySearchCityData;//查询结果
    
   NSMutableArray * _arraylocalDownLoadMapInfo;//本地下载的离线地图
}
@property (nonatomic,assign) id controler;
@property(nonatomic,retain) NSMutableArray *downloadSource;//正在下载项
@end
