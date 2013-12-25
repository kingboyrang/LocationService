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
- (IBAction)buttonEditHead:(id)sender {
    if (self.controler&&[self.controler respondsToSelector:@selector(supervisionEditHeadWithEntity:)]) {
        [self.controler performSelector:@selector(supervisionEditHeadWithEntity:) withObject:self.Entity];
    }
}

- (IBAction)buttonMessageClick:(id)sender {
    if (self.controler&&[self.controler respondsToSelector:@selector(supervisionMessageWithEntity:)]) {
        [self.controler performSelector:@selector(supervisionMessageWithEntity:) withObject:self.Entity];
    }
}

- (IBAction)buttonTrajectoryClick:(id)sender {
    if (self.controler&&[self.controler respondsToSelector:@selector(supervisionTrajectoryWithEntity:)]) {
        [self.controler performSelector:@selector(supervisionTrajectoryWithEntity:) withObject:self.Entity];
    }
}

- (IBAction)buttonCallClick:(id)sender {
    if (self.controler&&[self.controler respondsToSelector:@selector(supervisionCallWithEntity:)]) {
        [self.controler performSelector:@selector(supervisionCallWithEntity:) withObject:self.Entity];
    }
}
@end
