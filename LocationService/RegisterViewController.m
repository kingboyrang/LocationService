//
//  RegisterViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/17.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "RegisterViewController.h"
#import "TKLabelCell.h"
#import "TKTextFieldCell.h"
#import "NSString+TPCategory.h"
#import "UIButton+TPCategory.h"
#import "AppUI.h"
#import "LoginButtons.h"
#import <QuartzCore/QuartzCore.h>
#import "AlertHelper.h"
#import "Account.h"
#import "RegisterSuccessViewController.h"
@interface RegisterViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    UITableView *_tableView;
    UILabel *_showInfo;
    UILabel *_phoneShowInfo;
    
    UIImageView *_accountImageView;
    UIImageView *_phoneImageView;
}
- (void)backClick;
- (void)updateShowInfo;
- (void)buttonSubmit;
- (void)buttonCancel;
- (void)checkPhone;
@end

@implementation RegisterViewController
- (void)dealloc{
    //[UITableView release];
    [super dealloc];
    [_tableView release];
    [_showInfo release];
    [_phoneShowInfo release];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image=[UIImage imageNamed:@"logintop.jpg"];
    CGRect r=self.view.bounds;
    r.size=image.size;
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:r];
    [imageView setImage:image];
    [self.view addSubview:imageView];
    [imageView release];
    
   
    
    FXLabel *fx=[AppUI showLabelTitle:@"注册" frame:CGRectMake(0, 0, image.size.width, image.size.height)];
    r=fx.frame;
    r.origin.x=(self.view.bounds.size.width-r.size.width)/2.0;
    r.origin.y=(image.size.height-r.size.height)/2.0;
    fx.frame=r;
    [self.view addSubview:fx];
    
    /***
    UIButton *btn=[UIButton backButtonTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    r=btn.frame;
    r.origin.x=5;
    r.origin.y=(image.size.height-r.size.height)/2;
    btn.frame=r;
    [self.view addSubview:btn];
     ***/
    
    
    r=DeviceRealRect;
    r.origin.y=image.size.height;
    r.size.height-=image.size.height+44;
    
    
    _tableView=[[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor=[UIColor clearColor];
    _tableView.bounces=NO;
    //_tableView.autoresizesSubviews=YES;
    //_tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_tableView];
    
    LoginButtons *buttons=[[LoginButtons alloc] initWithFrame:CGRectMake(0,DeviceRealHeight-44, self.view.bounds.size.width, 44)];
    [buttons.submit addTarget:self action:@selector(buttonSubmit) forControlEvents:UIControlEventTouchUpInside];
    [buttons.cancel addTarget:self action:@selector(buttonCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttons];
    [buttons release];
    
    
    TKLabelCell *cell1=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell1.label.text=@"帐号";
    
    TKTextFieldCell *cell2=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell2.textField.placeholder=@"请输入帐号";
    cell2.textField.delegate=self;
    
    TKLabelCell *cell3=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell3.label.text=@"妮称";
    
    TKTextFieldCell *cell4=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell4.textField.placeholder=@"请输入妮称";
    
    TKLabelCell *cell5=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell5.label.text=@"手机号码";
    
    TKTextFieldCell *cell6=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell6.textField.placeholder=@"请输入手机号码";
    cell6.textField.delegate=self;
    
    TKLabelCell *cell7=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell7.label.text=@"密码";
    
    TKTextFieldCell *cell8=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell8.textField.placeholder=@"请输入密码";
    cell8.textField.secureTextEntry=YES;
    cell8.textField.delegate=self;
    
    TKLabelCell *cell9=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell9.label.text=@"确认密码";
    
    TKTextFieldCell *cell10=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell10.textField.placeholder=@"请输入确认密码";
    cell10.textField.secureTextEntry=YES;
    cell10.textField.delegate=self;

    self.cells=[NSMutableArray arrayWithObjects:cell1,cell2,cell3,cell4,cell5,cell6,cell7,cell8,cell9,cell10, nil];
    

    _showInfo=[[UILabel alloc] initWithFrame:CGRectMake(50, 49, self.view.bounds.size.width-50, 20)];
    _showInfo.textColor=[UIColor redColor];
    _showInfo.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    _showInfo.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_showInfo];
    
    _accountImageView=[[UIImageView alloc] initWithFrame:CGRectMake(50, 44.5, 20, 29)];
    [_accountImageView setImage:[UIImage imageNamed:@"ico19.png"]];
    [self.view addSubview:_accountImageView];
    _accountImageView.hidden=YES;
    

    _phoneShowInfo=[[UILabel alloc] initWithFrame:CGRectMake(80, 197, self.view.bounds.size.width-80, 20)];
    _phoneShowInfo.textColor=[UIColor redColor];
    _phoneShowInfo.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    _phoneShowInfo.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_phoneShowInfo];
    
    _phoneImageView=[[UIImageView alloc] initWithFrame:CGRectMake(80, 192.5, 20, 29)];
    [_phoneImageView setImage:[UIImage imageNamed:@"ico19.png"]];
    [self.view addSubview:_phoneImageView];
    _phoneImageView.hidden=YES;

}
//注册
- (void)buttonSubmit{
    TKTextFieldCell *cell1=self.cells[1];
    if (!cell1.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"帐号不为空!"];
        [cell1.textField becomeFirstResponder];
        return;
    }
    TKTextFieldCell *cell2=self.cells[3];
    if (!cell2.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"妮称不为空!"];
        [cell2.textField becomeFirstResponder];
        return;
    }
    TKTextFieldCell *cell3=self.cells[5];
    if (!cell3.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"手机号码不为空!"];
        [cell3.textField becomeFirstResponder];
        return;
    }
    TKTextFieldCell *cell4=self.cells[7];
    if (!cell4.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"密码不为空!"];
        [cell4.textField becomeFirstResponder];
        return;
    }
    TKTextFieldCell *cell5=self.cells[9];
    if (!cell5.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"确认密码不为空!"];
        [cell5.textField becomeFirstResponder];
        return;
    }
    if (![cell4.textField.text isEqualToString:cell5.textField.text]) {
        [AlertHelper initWithTitle:@"提示" message:@"密码与确认密码不一致!"];
        [cell5.textField becomeFirstResponder];
        return;
    }
    if (!self.hasNetWork) {
        [self showErrorNetWorkNotice:nil];
        return;
    }
    NSMutableArray *params=[NSMutableArray arrayWithCapacity:2];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell1.textField.text Trim],@"Account", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell2.textField.text Trim],@"LOCALNAME", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"NOTES", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell3.textField.text Trim],@"MobilePhone", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell4.textField.text Trim],@"Pwd", nil]];
    
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.methodName=@"UserRegister";
    args.soapParams=params;
    [self showLoadingAnimatedWithTitle:@"注册中,请稍后..."];
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        if(result.hasSuccess){
            XmlNode *node=[result methodNode];
            if([node.Value isEqualToString:@"complete"]){
                Account *acc=[[[Account alloc] init] autorelease];
                acc.UserId=[cell1.textField.text Trim];
                acc.Password=[cell4.textField.text Trim];
                acc.Name=[cell2.textField.text Trim];
                acc.Phone=[cell3.textField.text Trim];
                
                RegisterSuccessViewController *registerSuccess=[[RegisterSuccessViewController alloc] init];
                registerSuccess.Entity=acc;
                CATransition *animation = [CATransition animation];
                [animation setDuration:0.5];
                [animation setType:kCATransitionPush];
                [animation setSubtype:kCATransitionFromRight];
                [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                [[registerSuccess.view layer] addAnimation:animation forKey:@"SwitchToView"];
                [self presentViewController:registerSuccess animated:NO completion:nil];
                [registerSuccess release];
            }else{
               [self hideLoadingFailedWithTitle:@"网络不稳定,稍后再试!" completed:nil];
            }
            
        }else{
           [self hideLoadingFailedWithTitle:@"网络不稳定,稍后再试!" completed:nil];
        }
    } failed:^(NSError *error, NSDictionary *userInfo) {
        [self hideLoadingFailedWithTitle:@"网络不稳定,稍后再试!" completed:nil];
    }];
}
//取消 
- (void)buttonCancel{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionReveal];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[self.view layer] addAnimation:animation forKey:@"dissMissToView"];
    //self.modalTransitionStyle=UI;
    [self dismissViewControllerAnimated:YES completion:nil];
}
//判断帐号是否存在 
- (void)updateShowInfo{
    TKTextFieldCell *cell=self.cells[1];
    if ([cell.textField.text length]==0||strlen([cell.textField.text UTF8String])<11) {
        _showInfo.text=@"";
        _accountImageView.hidden=YES;
        return;
    }
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.methodName=@"IsExitsAccounts";
    args.soapParams=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:cell.textField.text,@"account", nil], nil];
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        if (result.hasSuccess) {
            XmlNode *node=[result methodNode];
            if ([node.Value isEqualToString:@"false"]) {
                 _showInfo.text=@"";
                 _accountImageView.hidden=NO;
            }else{
                _accountImageView.hidden=YES;
                _showInfo.text=@"帐号已被注册!";
                _showInfo.textColor=[UIColor redColor];
            }
        }else{
            _accountImageView.hidden=YES;
            _showInfo.text=@"帐号检测异常!";
            _showInfo.textColor=[UIColor redColor];
        }
    } failed:^(NSError *error, NSDictionary *userInfo) {
        _accountImageView.hidden=YES;
        _showInfo.text=@"帐号检测异常!";
        _showInfo.textColor=[UIColor redColor];
    }];
}
- (void)checkPhone{
    TKTextFieldCell *cell=self.cells[5];
    if ([cell.textField.text length]==0) {
        _phoneShowInfo.text=@"";
        _phoneImageView.hidden=YES;
        return;
    }
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.methodName=@"IsExitsMobileNo";
    args.soapParams=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:cell.textField.text,@"mobileNo", nil], nil];
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        if (result.hasSuccess) {
            XmlNode *node=[result methodNode];
            if ([node.Value isEqualToString:@"false"]) {
                _phoneShowInfo.text=@"";
                _phoneImageView.hidden=NO;
            }else{
                 _phoneImageView.hidden=YES;
                _phoneShowInfo.text=@"已注册!";
                _phoneShowInfo.textColor=[UIColor redColor];
            }
        }else{
             _phoneImageView.hidden=YES;
            _phoneShowInfo.text=@"手机号码检测异常!";
            _phoneShowInfo.textColor=[UIColor redColor];
        }
    } failed:^(NSError *error, NSDictionary *userInfo) {
         _phoneImageView.hidden=YES;
        _phoneShowInfo.text=@"手机号码检测异常!";
        _phoneShowInfo.textColor=[UIColor redColor];
    }];

    
}
- (void)backClick{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionReveal];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[self.view layer] addAnimation:animation forKey:@"dissMissToView"];
    //self.modalTransitionStyle=UI;
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark UITextFieldDelegate Methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // return NO to not change text
    BOOL boo=YES;
    TKTextFieldCell *cell=self.cells[1];
    TKTextFieldCell *cell3=self.cells[5];
    if (cell.textField==textField||cell3.textField==textField) {
        if(strlen([textField.text UTF8String]) >= 11 && range.length != 1)
            boo=NO;
    }
    TKTextFieldCell *cell1=self.cells[7];
    TKTextFieldCell *cell2=self.cells[9];
    
    if (cell1.textField==textField||cell2.textField==textField) {
        if(strlen([textField.text UTF8String]) >= 12 && range.length != 1)
            boo=NO;
    }
    return boo;
}
- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    TKTextFieldCell *cell=self.cells[1];
    TKTextFieldCell *cell1=self.cells[5];
    if (cell.textField==textField) {
        [self updateShowInfo];
    }
    if (cell1.textField==textField) {
        [self checkPhone];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.cells.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=self.cells[indexPath.row];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id cell=self.cells[indexPath.row];
    if ([cell isKindOfClass:[TKLabelCell class]]) {
        return 30.0;
    }
    return 44.0;
}
@end
