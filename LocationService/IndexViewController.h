//
//  IndexViewController.h
//  LocationService
//
//  Created by aJia on 2013/12/23.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
#import "SupervisionPerson.h"
#import "ToolBarView.h"
@interface IndexViewController : BasicViewController<BMKMapViewDelegate,UINavigationControllerDelegate>{
    BMKMapView* _mapView;
    float orginLevel;
    CLLocationCoordinate2D currentCoor;//当前定位坐标
    BOOL isFirstLoad;
    
    CLLocationCoordinate2D currentCenterCoor;//设置中心点
}
@property (nonatomic,strong) ToolBarView *toolBarView;
@property(nonatomic,strong) NSMutableArray *cells;
@property(nonatomic,retain) SupervisionPerson *selectedSupervision;
@property(nonatomic,readonly) BOOL canShowTrajectory;
@property(nonatomic,copy) NSString *laglnt;
- (BOOL)selectedTrajectoryIndex:(id)number;
- (void)setSelectedTabIndex:(id)num;
- (void)selectedMetaWithEntity:(SupervisionPerson*)entity;//进放仪表画面
- (void)setSelectedSupervisionCenter:(SupervisionPerson*)entity;//设置监管目标选中
@end
