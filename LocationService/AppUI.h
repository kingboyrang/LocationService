//
//  AppUI.h
//  Wisdom
//
//  Created by aJia on 2013/10/29.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXLabel.h"
@interface AppUI : NSObject
+(FXLabel*)showLabelTitle:(NSString*)title frame:(CGRect)rect;
+(FXLabel*)barButtonItemTitle:(NSString*)title frame:(CGRect)rect;
@end
