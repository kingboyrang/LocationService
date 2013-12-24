//
//  SupervisionCell.m
//  LocationService
//
//  Created by aJia on 2013/12/24.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "SupervisionCell.h"

@implementation SupervisionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)buttonCallClick:(id)sender {
    
}

- (void)setDataSource:(SupervisionPerson*)entity{
    self.Entity=entity;
    
    self.labName.text=entity.Name;
    self.labName.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    self.labName.textColor=[UIColor blackColor];
    self.labTel.text=entity.SimNo;
    self.labTel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    self.labTel.textColor=[UIColor blackColor];
}
- (void)dealloc {
    [_buttonImage release];
    [_labName release];
    [_labTel release];
    [_buttonTrajectory release];
    [_buttonMsg release];
    [super dealloc];
}
@end
