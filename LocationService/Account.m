//
//  Account.m
//  LocationService
//
//  Created by aJia on 2013/12/16.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "Account.h"
#import "FileHelper.h"
@implementation Account
- (void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:self.UserId forKey:@"UserId"];
    [encoder encodeObject:self.Password forKey:@"Password"];
    [encoder encodeBool:self.isFirstRun forKey:@"isFirstRun"];
    [encoder encodeBool:self.isLogin forKey:@"isLogin"];
    [encoder encodeBool:self.isRememberPwd forKey:@"isRememberPwd"];
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self=[super init]) {
        self.UserId=[aDecoder decodeObjectForKey:@"UserId"];
        self.Password=[aDecoder decodeObjectForKey:@"Password"];
        self.isFirstRun=[aDecoder decodeBoolForKey:@"isFirstRun"];
        self.isLogin=[aDecoder decodeBoolForKey:@"isLogin"];
        self.isRememberPwd=[aDecoder decodeBoolForKey:@"isRememberPwd"];
    }
    return self;
}
-(void)save{
    NSString *path=[DocumentPath stringByAppendingPathComponent:@"Account.db"];
    [NSKeyedArchiver archiveRootObject:self toFile:path];
}
+(void)closed{
    Account *acc=[Account unarchiverAccount];
    acc.isLogin=NO;
    acc.isRememberPwd=NO;
    acc.UserId=@"";
    acc.Password=@"";
    [acc save];
}
+(void)loginWithUserId:(NSString*)userId password:(NSString*)pwd rememberPassword:(BOOL)remember{
    Account *acc=[Account unarchiverAccount];
    acc.isLogin=YES;
    if (remember) {
        acc.UserId=userId;
        acc.Password=pwd;
    }else{
        acc.UserId=@"";
        acc.Password=@"";
    }
    acc.isRememberPwd=remember;
    [acc save];
}
+(Account*)unarchiverAccount{
    NSString *path=[DocumentPath stringByAppendingPathComponent:@"Account.db"];
    if(![FileHelper existsFilePath:path]){ //如果不存在
        Account *acc=[[[Account alloc] init] autorelease];
        acc.isFirstRun=YES;
        return acc;
    }
    return (Account*)[NSKeyedUnarchiver unarchiveObjectWithFile: path];
}
+ (BOOL)firstRunning{
    Account *acc=[Account unarchiverAccount];
    return acc.isFirstRun;
}
+ (void)finishRunning{
    Account *acc=[Account unarchiverAccount];
    acc.isFirstRun=NO;
    [acc save];
}
@end
