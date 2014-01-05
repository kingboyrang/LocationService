//
//  SingleMapShowViewController.h
//  LocationService
//
//  Created by aJia on 2014/1/5.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrajectoryHistory.h"
#import "BMapKit.h"
@interface SingleMapShowViewController : BasicViewController<BMKMapViewDelegate>{
   BMKMapView* _mapView;
}
@property (nonatomic,retain) TrajectoryHistory *Entity;
@property (nonatomic,copy) NSString *PersonName;
@end
