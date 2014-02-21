//
//  BasicViewController.h
//  LocationService
//
//  Created by aJia on 2013/12/17.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AnimateLoadView.h"
#import "AnimateErrorView.h"
#import "ServiceHelper.h"
#import "NavBarView.h"
#import "Account.h"
#import "BMapKit.h"
@interface BasicViewController : UIViewController
@property(nonatomic,strong) NavBarView *navBarView;
@property(nonatomic,assign) BOOL showBarView;
@property(nonatomic,assign) BOOL showBackButton;
@property(nonatomic,strong) ServiceHelper *serviceHelper;
@property(nonatomic,readonly) BOOL hasNetWork;
@property(nonatomic,readonly) float topHeight;
//动画操作
-(AnimateErrorView*) errorView;
-(AnimateErrorView*) successView;
-(AnimateLoadView*) loadingView;
-(void) showLoadingAnimatedWithTitle:(NSString*)title;
-(void) showLoadingAnimated:(void (^)(AnimateLoadView *loadView))process;
-(void) hideLoadingViewAnimated:(void (^)(AnimateLoadView *hideView))complete;
-(void) hideLoadingSuccessWithTitle:(NSString*)title completed:(void (^)(AnimateErrorView *successView))complete;
-(void) hideLoadingFailedWithTitle:(NSString*)title completed:(void (^)(AnimateErrorView *failedView))complete;

-(void) showErrorViewAnimated:(void (^)(AnimateErrorView *errorView))process;
-(void) hideErrorViewAnimatedWithDuration:(NSTimeInterval)duration completed:(void (^)(AnimateErrorView *errorView))complete;
-(void) hideErrorViewAnimated:(void (^)(AnimateErrorView *errorView))complete;
-(void) showErrorViewWithHide:(void (^)(AnimateErrorView *errorView))process completed:(void (^)(AnimateErrorView *errorView))complete;


-(void) showSuccessViewAnimated:(void (^)(AnimateErrorView *successView))process;
-(void) hideSuccessViewAnimated:(void (^)(AnimateErrorView *successView))complete;
-(void) showSuccessViewWithHide:(void (^)(AnimateErrorView *successView))process completed:(void (^)(AnimateErrorView *successView))complete;

- (void) showErrorNetWorkNotice:(void (^)(void))dismissError;
- (void) showMessageWithTitle:(NSString*)title;
- (void) showMessageWithTitle:(NSString*)title innerView:(UIView*)view dismissed:(void(^)())completed;
- (CATransition *)getAnimation:(NSInteger)type subtype:(NSInteger)subtype;

- (void)setCurrentMapLevel:(BMKMapView*)map;//设置地图等级
- (BOOL)backPrevViewController;
@end
