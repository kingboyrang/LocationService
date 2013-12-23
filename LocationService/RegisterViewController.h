//
//  RegisterViewController.h
//  LocationService
//
//  Created by aJia on 2013/12/17.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : BasicViewController
@property(nonatomic,strong) NSMutableArray *cells;
-(void) showErrorViewAnimated:(void (^)(AnimateErrorView *errorView))process;
-(void) showLoadingAnimated:(void (^)(AnimateLoadView *errorView))process;
@end
