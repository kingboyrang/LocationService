//
//  DownloadMapView.h
//  LocationService
//
//  Created by aJia on 2014/1/23.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DownloadMapViewDelegate <NSObject>
@optional
- (void)viewerMapWithCityId:(int)cityId;//查看地图
- (void)pauseDownloadWithCityId:(int)cityId;//地图暂停下载
- (void)removeMapWithCityId:(int)cityId;//删除地图
- (void)downloadMapWithCityId:(int)cityId;//下载地图
@end

@interface DownloadMapView : UIView
@property (nonatomic,retain) NSMutableArray *localMaps;//已下载的地图
@property (nonatomic,retain) NSMutableArray *downloadMaps;//正在下载的地图
@property (nonatomic,assign) id<DownloadMapViewDelegate> delegate;
- (int)getDownloadMapRowWithCityId:(int)cityId;//获取下载行
@end
