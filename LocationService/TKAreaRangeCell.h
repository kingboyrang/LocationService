//
//  TKAreaRangeCell.h
//  LocationService
//
//  Created by aJia on 2014/1/6.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TKAreaRangeCell : UITableViewCell{
@private UILabel *_labLine;
}
@property (nonatomic,strong) UITextField *startField;
@property (nonatomic,strong) UITextField *endField;
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,strong) UIButton *deleteButton;
@property (nonatomic,assign) int index;
@end
