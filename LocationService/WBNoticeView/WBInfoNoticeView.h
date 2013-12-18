//
//  WBInfoNoticeView.h
//  Eland
//
//  Created by aJia on 13/10/7.
//  Copyright (c) 2013年 rang. All rights reserved.
//

#import "WBNoticeView.h"

@interface WBInfoNoticeView : WBNoticeView
+ (WBInfoNoticeView *)infoNoticeInView:(UIView *)view title:(NSString *)title;
+ (WBInfoNoticeView *)infoNoticeInView:(UIView *)view title:(NSString *)title dismiss:(void (^)(BOOL dismissedInteractively))block;
@end
