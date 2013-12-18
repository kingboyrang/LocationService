//
//  TKDynamicPasswordCell.h
//  LocationService
//
//  Created by aJia on 2013/12/17.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TKDynamicPasswordCell : UITableViewCell<UITextFieldDelegate>
@property (nonatomic,strong) UITextField *textField;
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,strong) UILabel *label;
@property(nonatomic,readonly) BOOL hasValue;
@property(nonatomic,readonly) BOOL hasVeryFailed;
@property(nonatomic,readonly) NSDate *minDate;
@property(nonatomic,readonly) NSDate *maxDate;

- (void)startTimerWithTime:(NSString*)time;
@end
