//
//  RangeWeekView.h
//  LocationService
//
//  Created by aJia on 2014/1/6.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RangeWeekView : UIView<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
}
@property(nonatomic,retain) NSMutableArray *cells;
@end
