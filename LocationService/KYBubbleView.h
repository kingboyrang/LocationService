//
//  KYBubbleView.h
//  DrugRef
//
//  Created by chen xin on 12-6-6.
//  Copyright (c) 2012年 Kingyee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KYBubbleView : UIScrollView<UITextFieldDelegate> {   //UIView是气泡view的本质
}
@property (nonatomic,strong) UITextField *field;
- (BOOL)showFromRect:(CGRect)rect;
@end
