//
//  LoginViewController.h
//  LocationService
//
//  Created by aJia on 2013/12/16.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PagerViewController.h"
@interface LoginViewController : PagerViewController
- (void)selectedMenuItemIndex:(NSNumber*)number;
- (void)handChangePageIndex:(int)index;
@end
