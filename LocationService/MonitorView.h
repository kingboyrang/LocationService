//
//  MonitorView.h
//  LocationService
//
//  Created by aJia on 2013/12/24.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SupervisionPerson.h"
@interface MonitorView : UIView
@property (retain, nonatomic) IBOutlet UIButton *headImage;
@property (retain, nonatomic) IBOutlet UILabel *labName;
@property (retain, nonatomic) IBOutlet UILabel *labPhone;
@property (strong,nonatomic) SupervisionPerson *Entity;

- (IBAction)buttonMessageClick:(id)sender;
- (IBAction)buttonTrajectoryClick:(id)sender;
- (IBAction)buttonCallClick:(id)sender;
- (void)setDataSource:(SupervisionPerson*)entity;

@end
