//
//  BasicViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/17.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "BasicViewController.h"
#import "UIColor+TPCategory.h"
#import "NetWorkConnection.h"
#import "WBErrorNoticeView.h"
#import "WBInfoNoticeView.h"
@interface BasicViewController (){
    AnimateLoadView *_loadView;
    AnimateErrorView *_errorView;
    AnimateErrorView *_successView;
}
@property (nonatomic,readonly) BOOL containNavigator;
-(void)buttonBackClick;
@end

@implementation BasicViewController
@synthesize serviceHelper=_serviceHelper;
-(void)dealloc{
    [super dealloc];
    if(_loadView){
        [_loadView release],_loadView=nil;
    }
    if(_errorView){
        [_errorView release],_errorView=nil;
    }
    if(_successView){
        [_successView release],_successView=nil;
    }
    //[_serviceHelper release];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}
//设置地图等级
- (void)setCurrentMapLevel:(BMKMapView*)map
{
    float level=[Account mapZoomLevel];
    if (level==0) {
        level=11.0;
    }
    map.zoomLevel=level;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.showBarView) {
        if (![self.view.subviews containsObject:_navBarView]) {
            _navBarView=[[NavBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
            //CGRectMake(0, 0, DeviceWidth, 44)
            [self.view addSubview:_navBarView];
            
            if (self.showBackButton) {
                if (self.navigationController) {
                    if ([self.navigationController.viewControllers count]>1) {
                        [_navBarView setBackButtonWithTarget:self action:@selector(buttonBackClick)];
                    }
                }
            }
        }
    }
}
-(void)buttonBackClick{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.serviceHelper=[[ServiceHelper alloc] init];
    self.view.backgroundColor=[UIColor whiteColor];
    //[self showNavigationBackButton];
    self.showBarView=YES;
    self.showBackButton=YES;
    
    
    
}
- (BOOL)hasNetWork{
    return [NetWorkConnection IsEnableConnection];
}
- (void) showErrorNetWorkNotice:(void (^)(void))dismissError{
    
    [self showErrorViewWithHide:^(AnimateErrorView *errorView) {
        errorView.labelTitle.text=@"网络未连接,请检查!";
    } completed:^(AnimateErrorView *errorView) {
        if (dismissError) {
            dismissError();
        }
    }];
    /***
    WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"网络未连接" message:@"请检查您的网络连接."];
    [notice setDismissalBlock:^(BOOL dismissedInteractively) {
        if (dismissError) {
            dismissError();
        }
    }];
    [notice show];
     ***/
}
- (void) showMessageWithTitle:(NSString*)title{
    [self showMessageWithTitle:title innerView:self.view dismissed:nil];
}
- (void) showMessageWithTitle:(NSString*)title innerView:(UIView*)view dismissed:(void(^)())completed{
    WBInfoNoticeView *info=[WBInfoNoticeView infoNoticeInView:view title:title];
    [info setDismissalBlock:^(BOOL dismissedInteractively) {
        if (dismissedInteractively) {
            if (completed) {
                completed();
            }
        }
    }];
    [info show];
    info.gradientView.backgroundColor=[UIColor colorFromHexRGB:@"c94018"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)containNavigator{
    if (self.navigationController&&[self.navigationController.viewControllers count]>1)return YES;
    return NO;
}
#pragma mark 动画提示
-(AnimateErrorView*) errorView {
    
    if (!_errorView) {
        if ([self containNavigator]) {
            _errorView=[[AnimateErrorView alloc] initWithFrame:CGRectMake(0,4, self.view.bounds.size.width, 40)];
        }else{
           _errorView=[[AnimateErrorView alloc] initWithFrame:CGRectMake(0, -40, self.view.bounds.size.width, 40)];
        }
        _errorView.backgroundColor=[UIColor redColor];
        [_errorView setErrorImage:[UIImage imageNamed:@"notice_error_icon.png"]];
    }
    return _errorView;
}

-(AnimateLoadView*) loadingView {
    if (!_loadView) {
        if ([self containNavigator]) {
           _loadView=[[AnimateLoadView alloc] initWithFrame:CGRectMake(0,4, self.view.bounds.size.width, 40)];
        }else{
           _loadView=[[AnimateLoadView alloc] initWithFrame:CGRectMake(0, -40, self.view.bounds.size.width, 40)];
        }
        
    }
    return _loadView;
}
-(AnimateErrorView*) successView {
    if (!_successView) {
        if ([self containNavigator]) {
           _successView=[[AnimateErrorView alloc] initWithFrame:CGRectMake(0, 4, self.view.bounds.size.width, 40)];
        }else{
           _successView=[[AnimateErrorView alloc] initWithFrame:CGRectMake(0, -40, self.view.bounds.size.width, 40)];
        }
        _successView.backgroundColor=[UIColor colorFromHexRGB:@"51c345"];
        [_successView setErrorImage:[UIImage imageNamed:@"notice_success_icon.png"]];
    }
    return _successView;
}
-(void) showLoadingAnimatedWithTitle:(NSString*)title{
    [self showLoadingAnimated:^(AnimateLoadView *errorView) {
        errorView.labelTitle.text=title;
    }];
}
-(void) showLoadingAnimated:(void (^)(AnimateLoadView *errorView))process{
    AnimateLoadView *loadingView = [self loadingView];
    if (process) {
        process(loadingView);
    }
    BOOL boo=[self containNavigator];
    [self.view addSubview:loadingView];
    [self.view sendSubviewToBack:loadingView];
    CGRect r=loadingView.frame;
    r.origin.y=boo?46:2;
    if (boo) {
        for (UIView *v in self.view.subviews) {
            if ([v isKindOfClass:[NavBarView class]]||[v isKindOfClass:[AnimateLoadView class]]) {
                continue;
            }
            [self.view sendSubviewToBack:v];
        }
    }
    [loadingView.activityIndicatorView startAnimating];
    [UIView animateWithDuration:0.5f animations:^{
        loadingView.frame=r;
    }];
}

-(void) hideLoadingViewAnimated:(void (^)(AnimateLoadView *hideView))complete{
    
    AnimateLoadView *loadingView = [self loadingView];
    CGRect r=loadingView.frame;
    r.origin.y=-r.size.height;
    [UIView animateWithDuration:0.5f animations:^{
        loadingView.frame=r;
    } completion:^(BOOL finished) {
        [loadingView.activityIndicatorView stopAnimating];
        [loadingView removeFromSuperview];
        if (complete) {
            complete(loadingView);
        }
    }];
}


-(void) showErrorViewAnimated:(void (^)(AnimateErrorView *errorView))process{
    AnimateErrorView *errorView = [self errorView];
    if (process) {
        process(errorView);
    }
    BOOL boo=[self containNavigator];
    [self.view addSubview:errorView];
    [self.view sendSubviewToBack:errorView];
    CGRect r=errorView.frame;
    r.origin.y=boo?46:2;
    if (boo) {
        for (UIView *v in self.view.subviews) {
            if ([v isKindOfClass:[NavBarView class]]||[v isKindOfClass:[AnimateErrorView class]]) {
                continue;
            }
            [self.view sendSubviewToBack:v];
        }
    }
    [UIView animateWithDuration:0.5f animations:^{
        errorView.frame=r;
    }];
}
-(void) hideErrorViewAnimatedWithDuration:(NSTimeInterval)duration completed:(void (^)(AnimateErrorView *errorView))complete;{
    AnimateErrorView *errorView = [self errorView];
    CGRect r=errorView.frame;
    r.origin.y=-r.size.height;
    [UIView animateWithDuration:duration animations:^{
        errorView.frame=r;
    } completion:^(BOOL finished) {
        [errorView removeFromSuperview];
        if (complete) {
            complete(errorView);
        }
    }];
}
-(void) hideErrorViewAnimated:(void (^)(AnimateErrorView *errorView))complete{
    [self hideErrorViewAnimatedWithDuration:0.5f completed:complete];
}
-(void) showErrorViewWithHide:(void (^)(AnimateErrorView *errorView))process completed:(void (^)(AnimateErrorView *errorView))complete{
    [self showErrorViewAnimated:process];
    [self performSelector:@selector(hideErrorViewAnimated:) withObject:complete afterDelay:2.0f];
}
-(void) hideLoadingFailedWithTitle:(NSString*)title completed:(void (^)(AnimateErrorView *errorView))complete{
    [self hideLoadingViewAnimated:^(AnimateLoadView *hideView) {
        [self showErrorViewWithHide:^(AnimateErrorView *errorView) {
            errorView.labelTitle.text=title;
        } completed:complete];
    }];
}
-(void) showSuccessViewAnimated:(void (^)(AnimateErrorView *errorView))process{
    AnimateErrorView *errorView = [self successView];
    if (process) {
        process(errorView);
    }
    BOOL boo=[self containNavigator];
    [self.view addSubview:errorView];
    [self.view sendSubviewToBack:errorView];
    CGRect r=errorView.frame;
    r.origin.y=boo?46:2;
    if (boo) {
        for (UIView *v in self.view.subviews) {
            if ([v isKindOfClass:[NavBarView class]]||[v isKindOfClass:[AnimateErrorView class]]) {
                continue;
            }
            [self.view sendSubviewToBack:v];
        }
    }
    [UIView animateWithDuration:0.5f animations:^{
        errorView.frame=r;
    }];
}
-(void) hideSuccessViewAnimated:(void (^)(AnimateErrorView *errorView))complete{
    AnimateErrorView *errorView = [self successView];
    CGRect r=errorView.frame;
    r.origin.y=-r.size.height;
    [UIView animateWithDuration:0.5f animations:^{
        errorView.frame=r;
    } completion:^(BOOL finished) {
        [errorView removeFromSuperview];
        if (complete) {
            complete(errorView);
        }
    }];
}
-(void) showSuccessViewWithHide:(void (^)(AnimateErrorView *errorView))process completed:(void (^)(AnimateErrorView *errorView))complete{
    [self showSuccessViewAnimated:process];
    [self performSelector:@selector(hideSuccessViewAnimated:) withObject:complete afterDelay:2.0f];
}
-(void) hideLoadingSuccessWithTitle:(NSString*)title completed:(void (^)(AnimateErrorView *errorView))complete{
    [self hideLoadingViewAnimated:^(AnimateLoadView *hideView) {
        [self showSuccessViewAnimated:^(AnimateErrorView *errorView) {
            errorView.labelTitle.text=title;
        }];
        [self performSelector:@selector(hideSuccessViewAnimated:) withObject:complete afterDelay:2.0f];
    }];
}
-(CATransition *)getAnimation:(NSInteger)type subtype:(NSInteger)subtype{
    CATransition *animation = [CATransition animation];
    //animation.delegate = self;
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    switch (type) {
        case 1:
            animation.type = kCATransitionFade;
            break;
        case 2:
            animation.type = kCATransitionPush;
            break;
        case 3:
            animation.type = kCATransitionReveal;
            break;
        case 4:
            animation.type = kCATransitionMoveIn;
            break;
        case 5:
            animation.type = @"cube";
            break;
        case 6:
            animation.type = @"suckEffect";
            break;
        case 7:
            animation.type = @"oglFlip";
            break;
        case 8:
            animation.type = @"rippleEffect";//波纹
            break;
        case 9:
            animation.type = @"pageCurl";
            break;
        case 10:
            animation.type = @"pageUnCurl";
            break;
        case 11:
            animation.type = @"cameraIrisHollowOpen";
            break;
        case 12:
            animation.type = @"cameraIrisHollowClose";
            break;
        default:
            animation.type = kCATransitionFade;
            break;
    }
    switch (subtype) {
        case 0:
            animation.subtype = kCATransitionFromLeft;
            break;
        case 1:
            animation.subtype = kCATransitionFromBottom;
            break;
        case 2:
            animation.subtype = kCATransitionFromRight;
            break;
        case 3:
            animation.subtype = kCATransitionFromTop;
            break;
        default:
            animation.subtype = kCATransitionFromLeft;
            break;
    }
    return animation;
}
@end
