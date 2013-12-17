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
@property(nonatomic,readonly) BOOL hasValue;
@end
