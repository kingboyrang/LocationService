//
//  CallPhoneView.h
//  LocationService
//
//  Created by aJia on 2014/1/5.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleSwitch.h"
@interface CallPhoneView : UIView
@property (nonatomic,strong) UILabel *labPhone;
@property (nonatomic,strong) SimpleSwitch *switchPhone;
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,copy) NSString *shipPhone;
@property (nonatomic,copy) NSString *trajectoryPhone;

@property (nonatomic,assign) id controlers;
- (void)setDataWithShipPhone:(NSString*)phone trajectoryTel:(NSString*)tel;
@end
