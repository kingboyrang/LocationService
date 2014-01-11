//
//  Global.h
//  Eland
//
//  Created by aJia on 13/9/27.
//  Copyright (c) 2013年 rang. All rights reserved.
//

//获取设备的物理大小
#define DeviceRect [UIScreen mainScreen].bounds
#define DeviceWidth [UIScreen mainScreen].bounds.size.width
#define DeviceHeight [UIScreen mainScreen].bounds.size.height
#define StatusBarHeight 20 //状态栏高度
#define TabHeight 44 //工具栏高度
#define DeviceRealHeight DeviceHeight-20
#define DeviceRealRect CGRectMake(0, 0, DeviceWidth, DeviceRealHeight)
//路径设置
#define DocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define CachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define TempPath NSTemporaryDirectory()
//设备
#define DeviceIsPad UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad
//通知post name
#define kPushNotificeName @"kPushNotificeNameInfo"
//webservice
#define DataWebserviceURL @"http://ibdcloud.com:8083/User_APP.asmx"
#define DataNameSpace @"http://tempuri.org/"

#define DataWebservice1 @"http://www.ibdcloud.com:8083/Pit_APP.asmx"
#define DataNameSpace1 @"http://tempuri.org/"

//字体设置
#define DeviceFontName @"Helvetica-Bold"
#define DeviceFontSize 16.0




