//
//  OfflineDemoMapViewController.h
//  BaiduMapSdkSrc
//
//  Created by BaiduMapAPI on 13-7-22.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
@interface OfflineDemoMapViewController : BasicViewController<BMKMapViewDelegate>{
    BMKMapView* _mapView;
}
@property (nonatomic, assign) int cityId;
@property (nonatomic, retain) BMKOfflineMap* offlineServiceOfMapview;
@end
