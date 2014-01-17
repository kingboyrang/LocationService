//
//  AppDelegate.m
//  LocationService
//
//  Created by aJia on 2013/12/16.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "AppDelegate.h"
#import "AppHelper.h"
#import "LoginViewController.h"
#import "BasicNavigationController.h"
#import "MainViewController.h"
#import "Account.h"
#import "IndexViewController.h"
#import "RunAnimateView.h"
@implementation AppDelegate

- (void)dealloc
{
    [_window release];
   
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //百度地图注册
    _mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [_mapManager start:@"0E0006d6779b856330e93e877acbd7d1"  generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    [_mapManager release];
    
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
     /***
    MainViewController *main=[[[MainViewController alloc] init] autorelease];
    self.window.rootViewController=main;
    [self.window makeKeyAndVisible];
    // Override point for customization after application launch.
   ***/
    Account *acc=[Account unarchiverAccount];
    if (acc.isRememberPwd) {//记住密码
        acc.isLogin=YES;
        [acc save];
        IndexViewController *controler=[[[IndexViewController alloc] init] autorelease];
        BasicNavigationController *basic=[[[BasicNavigationController alloc] initWithRootViewController:controler] autorelease];
         self.window.rootViewController=basic;
    }else{
        [Account closed];
        LoginViewController *login=[[[LoginViewController alloc] init] autorelease];
        BasicNavigationController *nav=[[[BasicNavigationController alloc] initWithRootViewController:login] autorelease];
        self.window.rootViewController =nav;
    }
     [self.window makeKeyAndVisible];
    
    if (acc.isFirstRun) {//第一次启动时加载动画
        RunAnimateView *view=[[RunAnimateView alloc] initWithFrame:DeviceRect];
        view.backgroundColor=[UIColor blackColor];
        [self.window addSubview:view];
    }
    //[AppHelper runAnimation:nil];
    
    return YES;
}
//回首页
- (void)onGetNetworkState:(int)iError
{
    NSLog(@"onGetNetworkState %d",iError);
}
- (void)onGetPermissionState:(int)iError
{
    NSLog(@"onGetPermissionState %d",iError);
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
@end
