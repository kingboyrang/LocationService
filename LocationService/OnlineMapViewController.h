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
   BMKOfflineMap* _offlineMap;
   NSMutableArray * _arraylocalDownLoadMapInfo;//本地下载的离线地图
    
    int currentDownloadCityId;//当前正在下载的城市id
    BMKMapView* _mapView;
}

@property(nonatomic,strong) NSMutableArray *arraylDownLoadSource;//下载地图
@property(nonatomic,retain) BMKOLSearchRecord *downloadRecord;//保存当前要下载的地图
//添加一个地图下载
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
