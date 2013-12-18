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
#define TabHeight 82 //工具栏高度
//路径设置
#define DocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define CachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define TempPath NSTemporaryDirectory()
//设备
#define DeviceIsPad UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad
//通知post name
#define kPushNotificeName @"kPushNotificeNameInfo"
//推播中心WebService的URL地址
#define PushWebserviceURL @"http://60.251.51.217/Pushs.Admin/WebServices/Push.asmx"
#define PushNameSpace @"http://tempuri.org/"
//webservice
//#define DataWebserviceURL @"http://192.168.123.134/MiLe.Web/WebServices/Push.asmx"
#define DataWebserviceURL @"http://ibdcloud.com:8889/WebServices/Push.asmx"
#define DataNameSpace @"http://tempuri.org/"

//字体设置
#define DeviceFontName @"Helvetica-Bold"
#define DeviceFontSize 16.0




