//
//  MonitorView.m
//  LocationService
//
//  Created by aJia on 2013/12/24.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "MonitorView.h"
#import "UIButton+WebCache.h"
#import "UIImage+TPCategory.h"
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
    
   
    [self.headImage setImageWithURL:[NSURL URLWithString:entity.Photo] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"bg02.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image) {
            if (image.size.width>90||image.size.height>104) {
                [self.headImage setImage:[image imageByScalingToSize:CGSizeMake(90, 104)] forState:UIControlStateNormal];
            }else{
               [self.headImage setImage:image forState:UIControlStateNormal];
            }
        }
    }];
    //Photo
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
