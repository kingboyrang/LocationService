//
//  OnlineMapViewController.h
//  LocationService
//
//  Created by aJia on 2013/12/27.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMKOfflineMap.h"
@interface OnlineMapViewController : BasicViewController
@property(nonatomic,strong) NSMutableArray *list;
//新增一笔下载项
- (void)downloadMapWithEntity:(BMKOLSearchRecord*)entity;
//下载完成
- (void)finishedDownloadWithRow:(UITableViewCell*)cell;
@end
