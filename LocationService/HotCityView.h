//
//  HotCityView.h
//  LocationService
//
//  Created by aJia on 2014/1/22.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavBarView.h"
#import "BMapKit.h"
@interface HotCityView : UIView
@property (nonatomic,retain) NSArray *hotCitys;//热门城市
@property (nonatomic,retain) NSArray *countryCitys;//全国城市
@property (nonatomic,retain) NSArray *searchResultCitys;//搜索城市
@property (nonatomic,retain) NSArray *localMaps;//本地下载的离线地图
@property (nonatomic,retain) NSArray *downloadMaps;//正在下载的离线地图
@end
