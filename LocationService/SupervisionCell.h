//
//  SupervisionCell.h
//  LocationService
//
//  Created by aJia on 2013/12/24.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SupervisionPerson.h"
@interface SupervisionCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIButton *buttonImage;
@property (retain, nonatomic) IBOutlet UILabel *labName;
@property (retain, nonatomic) IBOutlet UILabel *labTel;
@property (retain, nonatomic) IBOutlet UIButton *buttonTrajectory;
@property (retain, nonatomic) IBOutlet UIButton *buttonMsg;
@property (strong,nonatomic) SupervisionPerson *Entity;

//拨打电话
- (IBAction)buttonCallClick:(id)sender;

- (void)setDataSource:(SupervisionPerson*)entity;
@end
