//
//  OnlineMapViewController.h
//  LocationService
//
//  Created by aJia on 2013/12/27.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
@interface OnlineMapViewController : BasicViewController<BMKMapViewDelegate,BMKOfflineMapDelegate>{
   BMKMapView* _mapView;//.xib里要有BMKMapView类用于初始化数据驱动
   BMKOfflineMap* _offlineMap;
   NSMutableArray * _arraylocalDownLoadMapInfo;//本地下载的离线地图
    
    int currentDownloadCityId;//当前正在下载的城市id
}
@property(nonatomic,strong) NSMutableArray *arraylDownLoadSource;//下载地图
//新增一笔下载项
- (void)downloadMapWithEntity:(BMKOLSearchRecord*)entity;
//下载完成
- (void)finishedDownloadWithRow:(UITableViewCell*)cell element:(BMKOLUpdateElement*)elem;
//下载地图
- (void)startDownloadWithCityId:(int)cityId;
//暂停地图
- (void)pauseDownloadWithCityId:(int)cityId;
//删除下载地图
- (void)removeDownloadWithCityId:(int)cityId;
@end
