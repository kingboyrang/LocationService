//
//  IndexViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/23.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "IndexViewController.h"

@interface IndexViewController ()
- (void)buttonCompassClick;
- (void)buttonTargetClick;
- (void)buttonMonitorClick;
@end

@implementation IndexViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

        [self.navBarView setCompassButtonWithTarget:self action:@selector(buttonCompassClick)];
        [self.navBarView setTargetButtonWithTarget:self action:@selector(buttonTargetClick)];
        [self.navBarView setMonitorButtonWithTarget:self action:@selector(buttonMonitorClick)];
    
}
- (void)buttonCompassClick{

}
- (void)buttonTargetClick{
    
}
- (void)buttonMonitorClick{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
