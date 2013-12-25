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
@interface EditSupervisionHead (){
}
@property (nonatomic, strong) CaseCameraImage *cameraImage;
- (void)buttonViewerClick;
- (void)buttonCameraClick;
- (void)buttonCancelClick;
- (void)buttonSubmitClick;
@end

@implementation EditSupervisionHead

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
    
    UIImage *leftImage1=[UIImage imageNamed:@"bgbutton01.png"];
    UIEdgeInsets leftInsets1 = UIEdgeInsetsMake(5,10, 5, 10);
    leftImage1=[leftImage1 resizableImageWithCapInsets:leftInsets1 resizingMode:UIImageResizingModeStretch];
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(170, 320+topY, 114, 40);
    [btn setBackgroundImage:leftImage forState:UIControlStateNormal];
    [btn setTitle:@"照相" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    [btn addTarget:self action:@selector(buttonCameraClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    LoginButtons *buttons=[[LoginButtons alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-40, self.view.bounds.size.width, 44)];
    [buttons.cancel setTitle:@"上一步" forState:UIControlStateNormal];
    [buttons.submit setTitle:@"完成" forState:UIControlStateNormal];
    [buttons.cancel addTarget:self action:@selector(buttonCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [buttons.submit addTarget:self action:@selector(buttonSubmitClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttons];
    [buttons release];
    
}
- (void)finishedImage:(UIImage*)image{
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(10, 44+10, self.view.bounds.size.width-10*2, 300)];
    [imageView setImage:image];
    [self.view addSubview:imageView];
    [imageView release];
    return;
    
    if (!self.imageCropper) {
        self.imageCropper = [[BJImageCropper alloc] initWithFrame:CGRectMake(10, 44+10, self.view.bounds.size.width-10*2, 300)];
        [self.imageCropper setImage:image];
        NSLog(@"frame=%@",NSStringFromCGRect(self.imageCropper.frame));
        [self.view addSubview:self.imageCropper];
        self.imageCropper.center = self.view.center;
        self.imageCropper.imageView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.imageCropper.imageView.layer.shadowRadius = 3.0f;
        self.imageCropper.imageView.layer.shadowOpacity = 0.8f;
        self.imageCropper.imageView.layer.shadowOffset = CGSizeMake(1, 1);
    }else{
        [self.imageCropper.imageView setImage:image];
    }
    
}
//上一步
- (void)buttonCancelClick{
    [self.navigationController popViewControllerAnimated:YES];
}
//完成
- (void)buttonSubmitClick{
    
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
