//
//  TrajectoryPaoView.h
//  LocationService
//
//  Created by aJia on 2014/1/5.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SupervisionPerson.h"
#import "TrajectoryHistory.h"
@interface TrajectoryPaoView : UIView
@property (nonatomic,retain) NSMutableArray *cells;
- (void)setDataSource:(SupervisionPerson*)entity;
- (void)setDataSourceHistory:(TrajectoryHistory*)entity name:(NSString*)name;
@end
