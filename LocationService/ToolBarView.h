//
//  ToolBarView.h
//  LocationService
//
//  Created by aJia on 2014/1/13.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToolBarView : UIView
@property (nonatomic,assign) int selectedIndex;
@property (nonatomic,assign) id controls;
- (void)setSelectedItemIndex:(int)index;
@end
