//
//  ViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/16.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "ViewController.h"
#import "AppHelper.h"
@interface ViewController ()
- (void)changeViewIndex;
- (void)removeRunningAnimation:(void(^)())completed;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
   
    return;
    NSLog(@"frame=%@",NSStringFromCGRect(DeviceRect));
    
    UIImageView *tovalue=[[[UIImageView alloc] initWithFrame:DeviceRect] autorelease];
    tovalue.tag=100;
    [tovalue setImage:[UIImage imageNamed:@"load02.jpg"]];
    [self.view addSubview:tovalue];
    
    UIImageView *imageView2=[[[UIImageView alloc] initWithFrame:DeviceRect] autorelease];
    imageView2.tag=101;
    [imageView2 setImage:[UIImage imageNamed:@"load01.jpg"]];
    [self.view addSubview:imageView2];
    
    [self performSelector:@selector(changeViewIndex) withObject:nil afterDelay:2.0f];
	
    
}
- (void)changeViewIndex{
    //UIWindow *window=[[UIApplication sharedApplication] keyWindow];
    
    UIImageView *fromvalue=(UIImageView*)[self.view viewWithTag:101];
    UIImageView *tovalue=(UIImageView*)[self.view viewWithTag:100];
    
    
    
    [UIView transitionFromView:fromvalue toView:tovalue duration:0.5 options:UIViewAnimationOptionCurveEaseIn completion:^(BOOL finished) {
        //这个api 原理   ：
        //        1:[fromvalue.superview addSubview:tovalue];
        //        2:[fromvalue removeFromSuperview];
        if (finished) {
            [fromvalue removeFromSuperview];
            [self performSelector:@selector(removeRunningAnimation:) withObject:nil afterDelay:2.0f];
        }
    }];

}
- (void)removeRunningAnimation:(void(^)())completed{
    
    //UIWindow *window=[[UIApplication sharedApplication] keyWindow];
    UIImageView *imageView=(UIImageView*)[self.view viewWithTag:100];
    
    [UIView animateWithDuration:0.5f animations:^{
        [imageView removeFromSuperview];
        //self.view.alpha=1.0;
        if (completed) {
            completed();
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
