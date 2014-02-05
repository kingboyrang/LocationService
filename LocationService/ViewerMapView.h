//
//  ViewerMapView.h
//  LocationService
//
//  Created by aJia on 2014/2/5.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavBarView.h"
#import "OnlineBackDelegate.h"
@interface ViewerMapView : UIView
@property(nonatomic,strong) NavBarView* navBarView;
@property(nonatomic,assign) id<OnlineBackDelegate> delegate;
@end
