//
//  MonitorView.m
//  LocationService
//
//  Created by aJia on 2013/12/24.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "MonitorView.h"

@implementation MonitorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setDataSource:(SupervisionPerson*)entity{
    self.Entity=entity;
    
    self.labName.text=entity.Name;
    self.labName.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    self.labName.textColor=[UIColor blackColor];
    self.labPhone.text=entity.SimNo;
    self.labPhone.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    self.labPhone.textColor=[UIColor blackColor];
}

- (void)dealloc {
    [_headImage release];
    [_labName release];
    [_labPhone release];
    [super dealloc];
}
- (IBAction)buttonMessageClick:(id)sender {
}

- (IBAction)buttonTrajectoryClick:(id)sender {
}

- (IBAction)buttonCallClick:(id)sender {
}
@end
