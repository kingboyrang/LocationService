//
//  MainViewController.h
//  active
//
//  Created by 徐 军 on 13-8-20.
//  Copyright (c) 2013年 chenjin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SupervisionPerson.h"
#import "RecordView.h"
@interface MainViewController : UITabBarController<UINavigationControllerDelegate>{
@private
    UIView *_tabbarView;
    int _prevSelectIndex;
    int _barButtonItemCount;
    RecordView *_recordView;
}
@property (nonatomic,retain) SupervisionPerson *Entity;
- (void)setSelectedItemIndex:(int)index;
- (void)showTabbar:(BOOL)show;
@end
