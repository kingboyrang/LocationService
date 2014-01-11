//
//  EditSupervisionHead.m
//  LocationService
//
//  Created by aJia on 2013/12/25.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "EditSupervisionHead.h"
#import "UIImageView+WebCache.h"
#import "LoginButtons.h"
#import "CaseCameraImage.h"
#import "UIImage+TPCategory.h"
#import "AlertHelper.h"
@interface EditSupervisionHead (){
}
@property (nonatomic, strong) CaseCameraImage *cameraImage;
- (void)buttonViewerClick;
- (void)buttonCameraClick;
- (void)buttonCancelClick;
- (void)buttonSubmitClick;
- (void)uploadImageWithId:(NSString*)personId completed:(void(^)(NSString *fileName))completed;
@end

@implementation EditSupervisionHead
- (void)dealloc{
    [super dealloc];
    if (_imageCropper) {
        [_imageCropper release];
    }
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navBarView setNavBarTitle:self.Entity.Name];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cameraImage=[[CaseCameraImage alloc] init];
    self.cameraImage.delegate=self;
	
    CGFloat topY=44;
    _preview=[[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-90)/2, topY+108, 90, 104)];
    if (self.Entity&&self.Entity.Photo&&[self.Entity.Photo length]>0) {
        [_preview setImageWithURL:[NSURL URLWithString:self.Entity.Photo] placeholderImage:[UIImage imageNamed:@"bg02.png"]];
    }else{
        [_preview setImage:[UIImage imageNamed:@"bg02.png"]];
    }
    [self.view addSubview:_preview];
    [self.view sendSubviewToBack:_preview];
    
    
    UIImage *leftImage=[UIImage imageNamed:@"bgbutton01.png"];
    UIEdgeInsets leftInsets = UIEdgeInsetsMake(5,10, 5, 10);
    leftImage=[leftImage resizableImageWithCapInsets:leftInsets resizingMode:UIImageResizingModeStretch];
    
    UIButton *_button=[UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame=CGRectMake(36, 320+topY, 114, 40);
    [_button setBackgroundImage:leftImage forState:UIControlStateNormal];
    [_button setTitle:@"浏览" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _button.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    [_button addTarget:self action:@selector(buttonViewerClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
   
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(170, 320+topY, 114, 40);
    [btn setBackgroundImage:leftImage forState:UIControlStateNormal];
    [btn setTitle:@"照相" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    [btn addTarget:self action:@selector(buttonCameraClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    LoginButtons *buttons=[[LoginButtons alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-40, self.view.bounds.size.width, 44)];
    buttons.cancel.hidden=YES;
    buttons.submit.frame=CGRectMake(0, 0, buttons.frame.size.width, buttons.frame.size.height);
    [buttons.submit setTitle:@"完成" forState:UIControlStateNormal];
    [buttons.submit addTarget:self action:@selector(buttonSubmitClick) forControlEvents:UIControlEventTouchUpInside];
    /***
    if (self.operateType==2) {
        buttons.cancel.hidden=YES;
        buttons.submit.frame=CGRectMake(0, 0, buttons.frame.size.width, buttons.frame.size.height);
        [buttons.submit setTitle:@"完成" forState:UIControlStateNormal];
        [buttons.submit addTarget:self action:@selector(buttonSubmitClick) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [buttons.cancel setTitle:@"取消" forState:UIControlStateNormal];
        [buttons.submit setTitle:@"完成" forState:UIControlStateNormal];
        [buttons.cancel addTarget:self action:@selector(buttonCancelClick) forControlEvents:UIControlEventTouchUpInside];
        [buttons.submit addTarget:self action:@selector(buttonSubmitClick) forControlEvents:UIControlEventTouchUpInside];
    }
     ***/
    [self.view addSubview:buttons];
    [buttons release];
    
}
- (void)finishedImage:(UIImage*)image{
    
    if (image.size.width<90||image.size.height<104) {
        [AlertHelper initWithTitle:@"提示" message:@"头像大小必须大于或等于90*104像素!"];
        return;
    }
    if (_imageCropper) {
        [_imageCropper removeFromSuperview];
        [_imageCropper release];
    }
    
    UIImage *realImage=[image scaleToSize:CGSizeMake(300, 300)];
    
    CGRect r=CGRectMake((self.view.bounds.size.width-realImage.size.width)/2,44+(320-realImage.size.height)/2, realImage.size.width, realImage.size.height);
    _imageCropper = [[NLImageCropperView alloc] initWithFrame:r];
    [self.view addSubview:_imageCropper];
    [_imageCropper setImage:realImage];
    [_imageCropper setCropRegionRect:CGRectMake((realImage.size.width-90)*_imageCropper.scaleReal/2, (realImage.size.width-104)*_imageCropper.scaleReal/2, 90*_imageCropper.scaleReal, 104*_imageCropper.scaleReal)];
    
}
- (void)uploadImageWithId:(NSString*)personId completed:(void(^)(NSString *fileName))completed{
    if (_imageCropper) {
        if (!self.hasNetWork) {
            [self showErrorNetWorkNotice:nil];
            return;
        }
        [self showLoadingAnimatedWithTitle:@"正在上传头像,请稍后..."];
        NSString *base64=[[_imageCropper getCroppedImage] imageBase64String];
        NSMutableArray *params=[NSMutableArray arrayWithCapacity:2];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:base64,@"imgbase64", nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:personId,@"personID", nil]];
        
        ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
        args.serviceURL=DataWebservice1;
        args.serviceNameSpace=DataNameSpace1;
        args.methodName=@"UpImage";
        args.soapParams=params;
        //NSLog(@"soap=%@",args.soapMessage);
        [self.serviceHelper asynService:args success:^(ServiceResult *result) {
            BOOL boo=NO;
            NSString *name=@"";
            if (result.hasSuccess) {
                XmlNode *node=[result methodNode];
                NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[node.InnerText dataUsingEncoding:NSUTF8StringEncoding] options:1 error:nil];
                if (![[dic objectForKey:@"Result"] isEqualToString:@"false"]) {
                    name=[dic objectForKey:@"Result"];
                    boo=YES;
                }
            }
            if (!boo) {
                [self hideLoadingFailedWithTitle:@"上传头像失败!" completed:nil];
            }else{
                [self hideLoadingViewAnimated:^(AnimateLoadView *hideView) {
                    if (completed) {
                        completed(name);
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
            
        } failed:^(NSError *error, NSDictionary *userInfo) {
            [self hideLoadingFailedWithTitle:@"上传头像失败!" completed:nil];
            if (completed) {
                completed(@"");
            }
        }];
    }else{
        if (completed) {
            completed(@"");
        }
    }
}
//上一步
- (void)buttonCancelClick{
    [self.navigationController popViewControllerAnimated:YES];
}
//完成
- (void)buttonSubmitClick{
    if (self.operateType==2) {//修改
        if (_imageCropper) {
            [self uploadImageWithId:self.Entity.ID completed:^(NSString *fileName) {
                if (self.delegate&&[self.delegate respondsToSelector:@selector(finishUploadFileName:)]) {
                    [self.delegate performSelector:@selector(finishUploadFileName:) withObject:fileName];
                }
            }];
        }else{
            //[AlertHelper initWithTitle:@"提示" message:@"未选择头像!"];
        }
    }else{
        if (_imageCropper) {
            //[self uploadImageWithId:self.Entity.ID completed:nil];
            if (self.delegate&&[self.delegate respondsToSelector:@selector(finishSelectedImage:)]) {
                [self.delegate performSelector:@selector(finishSelectedImage:) withObject:[_imageCropper getCroppedImage]];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            //[AlertHelper initWithTitle:@"提示" message:@"未选择头像!"];
        }
    }
}
//浏览
- (void)buttonViewerClick{
    [self.cameraImage showAlbumInController:self];
}
//照相
- (void)buttonCameraClick{
    [self.cameraImage showCameraInController:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
