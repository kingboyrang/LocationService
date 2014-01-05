//
//  CallTrajectoryViewController.m
//  LocationService
//
//  Created by aJia on 2014/1/5.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import "CallTrajectoryViewController.h"

@interface CallTrajectoryViewController ()
- (void)loadingPhones;
@end

@implementation CallTrajectoryViewController
- (void)dealloc {
    [super dealloc];
    if (_mapView) {
        [_mapView release];
        _mapView = nil;
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
    [self.navBarView setNavBarTitle:[NSString stringWithFormat:@"%@--电话",self.Entity.Name]];
    _mapView.delegate = self; // 不用时，置nil
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect r=self.view.bounds;
    r.origin.y=44;
    r.size.height-=44;
    _mapView= [[BMKMapView alloc]initWithFrame:r];
    [self.view addSubview:_mapView];
    
    _phoneView=[[CallPhoneView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 100)];
    [self.view addSubview:_phoneView];
}
-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    
}
//加载电话
- (void)loadingPhones{
    
    for (int i=2;i<4;i++) {
        NSMutableArray *params=[NSMutableArray array];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.Entity.DeviceCode,@"DeviceCode", nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",i],@"type", nil]];
        
        ServiceArgs *args=[[ServiceArgs alloc] init];
        args.serviceURL=DataWebservice1;
        args.serviceNameSpace=DataNameSpace1;
        args.methodName=@"GetTelephone";
        args.soapParams=params;
        
        ASIHTTPRequest *request=[ServiceHelper commonSharedRequest:args];
        [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"type%d",i],@"name", nil]];
        [self.serviceHelper addQueue:request];
        [args release];
    }
    [self.serviceHelper startQueue:nil failed:nil complete:^(NSArray *results) {
        NSString *phone1=@"",*phone2=@"";
        for (ServiceResult *result in results) {
            NSString *name=[result.userInfo objectForKey:@"name"];//亲情号码
            if ([name isEqualToString:@"type2"]) {
                if (result.hasSuccess) {
                    NSDictionary *dic=[result json];
                    NSArray *arr=[dic objectForKey:@"PhoneNum"];
                    if (arr&&[arr count]>0) {
                        phone1=[[arr objectAtIndex:0] objectForKey:@"Phone"];
                    }
                }
            }else{
                if (result.hasSuccess) {
                    NSDictionary *dic=[result json];
                    NSArray *arr=[dic objectForKey:@"PhoneNum"];
                    if (arr&&[arr count]>0) {
                        phone2=[[arr objectAtIndex:0] objectForKey:@"Phone"];
                    }
                }
            }
        }
        [_phoneView setDataWithShipPhone:phone1 trajectoryTel:phone2];
    }];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
