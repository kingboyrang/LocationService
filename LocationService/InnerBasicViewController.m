//
//  InnerBasicViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/27.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "InnerBasicViewController.h"

@interface InnerBasicViewController ()

@end

@implementation InnerBasicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    CGRect r1=loadingView.frame;
    r1.origin.y=44-r1.size.height;
    loadingView.frame=r1;
    
    [self.view addSubview:loadingView];
    [self.view sendSubviewToBack:loadingView];
    [loadingView.activityIndicatorView startAnimating];
    CGRect r=loadingView.frame;
    r.origin.y=44+2;
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
    [self.view addSubview:errorView];
    [self.view bringSubviewToFront:errorView];
    CGRect r=errorView.frame;
    r.origin.y=2;
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
    [self.view addSubview:errorView];
    [self.view bringSubviewToFront:errorView];
    CGRect r=errorView.frame;
    r.origin.y=2;
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
@end
