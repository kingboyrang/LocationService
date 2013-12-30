//
//  TKMapCell.h
//  LocationService
//
//  Created by aJia on 2013/12/30.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMKOfflineMap.h"
@interface TKMapCell : UITableViewCell<BMKOfflineMapDelegate>{
        BMKOfflineMap* _offlineMap;
}
@property(nonatomic,strong) UILabel *labTitle;
@property(nonatomic,strong) UILabel *labprocess;
@property(nonatomic,strong) UIProgressView *progressView;
@property(nonatomic,retain) BMKOLSearchRecord *Entity;
@property(nonatomic,assign) id controlers;
//开始下载
- (void)start;
//暂停下载
- (void)stop;
//删除
- (void)remove;
- (void)setDataSource:(BMKOLSearchRecord*)entity;
@end
