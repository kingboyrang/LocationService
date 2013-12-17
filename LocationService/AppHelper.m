//
//  AppHelper.m
//  LocationService
//
//  Created by aJia on 2013/12/16.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "AppHelper.h"
#import "Account.h"
@interface AppHelper ()
- (void)runningAnimation:(void(^)())completed;
- (void)changeViewIndex:(void(^)())completed;
- (void)removeRunningAnimation:(void(^)())completed;
- (void)removeView;
@end

@implementation AppHelper

+ (void)runAnimation:(void(^)())completed{
    AppHelper *app=[[[AppHelper alloc] init] autorelease];
    [app runningAnimation:completed];
}

- (void)runningAnimation:(void(^)())completed{
    UIWindow *window=[[UIApplication sharedApplication] keyWindow];

    UIImageView *tovalue=[[[UIImageView alloc] initWithFrame:DeviceRect] autorelease];
    tovalue.tag=100;
    [tovalue setImage:[UIImage imageNamed:@"load02.jpg"]];
    [window addSubview:tovalue];
    
    UIImageView *imageView2=[[[UIImageView alloc] initWithFrame:DeviceRect] autorelease];
    imageView2.tag=101;
    [imageView2 setImage:[UIImage imageNamed:@"load01.jpg"]];
    [window addSubview:imageView2];
    
    [self performSelector:@selector(changeViewIndex:) withObject:completed afterDelay:2.0f];
}
- (void)changeViewIndex:(void(^)())completed{
    UIWindow *window=[[UIApplication sharedApplication] keyWindow];
    
    UIImageView *fromvalue=(UIImageView*)[window viewWithTag:101];
    UIImageView *tovalue=(UIImageView*)[window viewWithTag:100];
    
    [UIView transitionFromView:fromvalue toView:tovalue duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        if (finished) {
            [fromvalue removeFromSuperview];
            [self performSelector:@selector(removeRunningAnimation:) withObject:completed afterDelay:2.0f];
        }
    }];
}
- (void)removeView{
    UIWindow *window=[[UIApplication sharedApplication] keyWindow];
    UIImageView *imageView=(UIImageView*)[window viewWithTag:100];
    [imageView removeFromSuperview];
    
    Account *acc=[Account unarchiverAccount];
    acc.isFirstRun=NO;
    [acc save];
}
- (void)removeRunningAnimation:(void(^)())completed{
   
    UIWindow *window=[[UIApplication sharedApplication] keyWindow];
    UIImageView *imageView=(UIImageView*)[window viewWithTag:100];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeView)];
     imageView.alpha= 0.0;
    [UIView commitAnimations];
    
}
@end
