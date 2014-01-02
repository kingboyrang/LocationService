//
//  ModifyAreaViewController.h
//  LocationService
//
//  Created by aJia on 2014/1/2.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
@interface ModifyAreaViewController : BasicViewController<BMKMapViewDelegate>{
    BMKMapView* _mapView;
}
- (void)showBubble:(BOOL)show;
@end
