//
//  IndexViewController.h
//  LocationService
//
//  Created by aJia on 2013/12/23.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
@interface IndexViewController : BasicViewController<BMKMapViewDelegate>{
    BMKMapView* _mapView;
}
@end
