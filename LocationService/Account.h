//
//  Account.h
//  LocationService
//
//  Created by aJia on 2013/12/16.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Account : NSObject<NSCoding>
@property(nonatomic,copy) NSString *UserId;//帐号
@property(nonatomic,copy) NSString *Password;//密码
@property(nonatomic,assign) BOOL isFirstRun;//第一次启动App
@property(nonatomic,assign) BOOL isLogin;//是否已登入
@property(nonatomic,assign) BOOL isRememberPwd;//是否记住密码

//保存
- (void)save;
//注销
+ (void)closed;
//登入
+ (void)loginWithUserId:(NSString*)userId password:(NSString*)pwd rememberPassword:(BOOL)remember;
//帐号
+ (Account*)unarchiverAccount;
//第一次启动
+ (BOOL)firstRunning;
+ (void)finishRunning;
@end
