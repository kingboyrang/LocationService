//
//  BasicNavigationController.m
//  LocationService
//
//  Created by aJia on 2013/12/18.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "BasicNavigationController.h"

@interface BasicNavigationController ()

@end

@implementation BasicNavigationController

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
	
    /***
    for (UIView *v in self.view.subviews) {
        NSLog(@"class=%@,frame=%@",[v class],NSStringFromCGRect(v.frame));
    }
     ***/
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (![self.topViewController isKindOfClass:[viewController class]]) {
        [super pushViewController:viewController animated:animated];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
