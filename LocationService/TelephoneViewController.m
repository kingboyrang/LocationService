//
//  Telephone ViewController.m
//  LocationService
//
//  Created by aJia on 2014/1/6.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import "TelephoneViewController.h"
#import "UIImageView+WebCache.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
@interface TelephoneViewController (){
    UILabel *_labInfo;
    UIWebView *phoneCallWebView;
}
- (void)createLabelWithTitle:(NSString*)title frame:(CGRect)frame;
- (void) callBack;
@end

@implementation TelephoneViewController
- (void)dealloc{
    [super dealloc];
    [_labInfo release];
    if (phoneCallWebView) {
        [phoneCallWebView release], phoneCallWebView = nil;
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navBarView setNavBarTitle:@"通话/监听"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
	
   CGFloat topY=44;
   UIImageView *_preview=[[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-90)/2, topY+108, 90, 104)];
    if (self.Entity&&self.Entity.Photo&&[self.Entity.Photo length]>0) {
        [_preview setImageWithURL:[NSURL URLWithString:self.Entity.Photo] placeholderImage:[UIImage imageNamed:@"bg02.png"]];
    }else{
        [_preview setImage:[UIImage imageNamed:@"bg02.png"]];
    }
    [self.view addSubview:_preview];
    topY+=108+104+20;
    [_preview release];
    
    [self createLabelWithTitle:self.Entity.Name frame:CGRectMake(0,topY, self.view.bounds.size.width, 20)];
    topY+=20;
    [self createLabelWithTitle:self.Phone frame:CGRectMake(0,topY, self.view.bounds.size.width, 20)];
    
   
    _labInfo=[[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    _labInfo.textColor=[UIColor whiteColor];
    _labInfo.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    _labInfo.backgroundColor=[UIColor colorFromHexRGB:@"131313"];
    _labInfo.textAlignment=NSTextAlignmentCenter;
    _labInfo.text=@"通话结束";
    [self.view addSubview:_labInfo];
    
    //拨打电话
    if (self.Phone&&[self.Phone length]>0) {
        [self callBack];
    }
}
- (void) callBack{
    NSLog(@"呼叫");
   
    //实现呼叫之后到app中
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.Phone]];
    if ( !phoneCallWebView ) {
        phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
    
    CTCallCenter *callCenter = [[CTCallCenter alloc] init];
    callCenter.callEventHandler=^(CTCall* call)
    {
        
        if (call.callState == CTCallStateDisconnected)
        {
            NSLog(@"Call has been disconnected");
            _labInfo.text=@"接通中";
        }
        else if (call.callState == CTCallStateConnected)
        {
            NSLog(@"Call has just been connected");
             _labInfo.text=@"通话中";
        }
        
        else if(call.callState == CTCallStateIncoming)
        {
            NSLog(@"Call is incoming");
            _labInfo.text=@"来电中";
            //self.viewController.signalStatus=NO;
        }
        else if (call.callState ==CTCallStateDialing)
        {
            //NSLog(@"call is dialing");
            _labInfo.text=@"拨号中";
        }
        else
        {
             _labInfo.text=@"通话结束";
            NSLog(@"Nothing is done");
        }
    };
    
}
- (void)createLabelWithTitle:(NSString *)title frame:(CGRect)frame{
    UILabel *_labPhone=[[UILabel alloc] initWithFrame:frame];
    _labPhone.textColor=[UIColor blackColor];
    _labPhone.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    _labPhone.backgroundColor=[UIColor clearColor];
    _labPhone.textAlignment=NSTextAlignmentCenter;
    _labPhone.text=title;
    [self.view addSubview:_labPhone];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end