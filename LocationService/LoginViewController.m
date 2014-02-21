//
//  LoginViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/16.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginWay.h"
#import "GeneralLoginViewController.h"
#import "DynamicLoginViewController.h"
@interface LoginViewController (){
    LoginWay *_way;
}
@end

@implementation LoginViewController
- (void)dealloc{
    [super dealloc];
    [_way release];
}
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
    self.showBarView=NO;
   [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    
    _way=[[LoginWay alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    _way.controlers=self;
    [self.view addSubview:_way];
    
    GeneralLoginViewController *_general=[[[GeneralLoginViewController alloc] init] autorelease];
    DynamicLoginViewController *_dynamic=[[[DynamicLoginViewController alloc] init] autorelease];
    [self addChildViewController:_general];
    [self addChildViewController:_dynamic];

    
}
-(void)selectedMenuItemIndex:(NSNumber*)number{
    int index=[number intValue];
    [self changePageIndex:index];
}
//左右切换
- (void)handChangePageIndex:(int)index{
    [_way setWaySelectedItemIndex:index];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
