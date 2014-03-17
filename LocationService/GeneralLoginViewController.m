//
//  GeneralLoginViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/17.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "GeneralLoginViewController.h"
#import "TKLabelCell.h"
#import "TKTextFieldCell.h"
#import "UIColor+TPCategory.h"
#import "RegisterCheck.h"
#import "TKLoginButtonCell.h"
#import "TKEmptyCell.h"
#import "RegisterViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AlertHelper.h"
#import "MainViewController.h"
#import "Account.h"
#import "LoginButtons.h"
#import "TKRegisterCheckCell.h"
#import "IndexViewController.h"
#import "BasicNavigationController.h"
@interface GeneralLoginViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    UITableView *_tableView;
    LoginButtons *_buttons;
}
- (void)buttonRegister;
- (void)buttonSubmit:(id)sender;
- (void)buttonCancel;
- (BOOL)isUIDString;
- (void)replaceUIDstring;
- (void)pwdDesEncrypWithCompleted:(void(^)(NSString *pwd))completed;
@property (nonatomic,assign) CGRect tableRect;
@end

@implementation GeneralLoginViewController
- (void)dealloc{
    [super dealloc];
    [_tableView release];
    [_buttons release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.showBarView=NO;
       
    
    CGRect r=self.view.bounds;
    r.size.height-=44*2;
    _tableView=[[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor=[UIColor clearColor];
    _tableView.bounces=NO;
    //_tableView.backgroundView = [[UIView alloc] init];
    //_tableView.backgroundColor = [UIColor colorFromHexRGB:@"f5f5f5"];
    self.tableRect=r;
    [self.view addSubview:_tableView];
    
    TKLabelCell *cell1=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell1.label.text=@"帐号";
    
    TKTextFieldCell *cell2=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell2.textField.placeholder=@"请输入帐号/手机号";
    cell2.textField.layer.borderWidth=2.0;
    cell2.textField.layer.cornerRadius=5.0;
    cell2.textField.layer.borderColor=[UIColor colorFromHexRGB:@"4a7ebb"].CGColor;
    cell2.textField.delegate=self;
    
    TKLabelCell *cell3=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell3.label.text=@"密码";
    
    TKTextFieldCell *cell4=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell4.textField.placeholder=@"请输入密码";
    cell4.textField.layer.borderWidth=2.0;
    cell4.textField.layer.cornerRadius=5.0;
    cell4.textField.layer.borderColor=[UIColor colorFromHexRGB:@"4a7ebb"].CGColor;
    cell4.textField.secureTextEntry=YES;
    cell4.textField.delegate=self;
    
    TKRegisterCheckCell *cell5=[[[TKRegisterCheckCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    [cell5.check.registerButton addTarget:self action:@selector(buttonRegister) forControlEvents:UIControlEventTouchUpInside];
    
    self.cells=[NSMutableArray arrayWithObjects:cell1,cell2,cell3,cell4,cell5, nil];
    
    _buttons=[[LoginButtons alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height-44*2, self.view.bounds.size.width, 44)];
    [_buttons.submit addTarget:self action:@selector(buttonSubmit:) forControlEvents:UIControlEventTouchUpInside];
    [_buttons.cancel addTarget:self action:@selector(buttonCancel) forControlEvents:UIControlEventTouchUpInside];
    _buttons.submit.enabled=NO;
    [self.view addSubview:_buttons];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardWillShowHideNotification:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardWillShowHideNotification:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];

    
}
#pragma mark - Notifications
- (void)handleKeyboardWillShowHideNotification:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    //取得键盘的大小
    CGRect kbFrame = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if ([notification.name isEqualToString:UIKeyboardDidShowNotification]) {//显示键盘
        CGRect r=_tableView.frame;
        CGRect r1=_buttons.frame;
        r.size.height=self.tableRect.size.height-kbFrame.size.height;
        
       
        r1.origin.y=r.origin.y+r.size.height;
        //_tableView.frame=r;
        // _buttons.frame=r1;
        
        NSNumber *curve = [info objectForKey:UIKeyboardAnimationCurveUserInfoKey];
        NSNumber *duration = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        // 添加移动动画，使视图跟随键盘移动
        [UIView animateWithDuration:duration.doubleValue animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationCurve:[curve intValue]];
            
            _tableView.frame=r;
            _buttons.frame=r1;
        }];
        
        
    }
    else if ([notification.name isEqualToString:UIKeyboardDidHideNotification]) {//隐藏键盘
        CGRect r=_tableView.frame;
        CGRect r1=_buttons.frame;
        r.size.height=self.tableRect.size.height;
        
        r1.origin.y=self.tableRect.origin.y+r.size.height;
        
        [UIView animateWithDuration:[[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
            _tableView.frame=r;
            _buttons.frame=r1;
        }];
    }
}
-(void) showLoadingAnimated:(void (^)(AnimateLoadView *errorView))process{
    AnimateLoadView *loadingView = [self loadingView];
    if (process) {
        process(loadingView);
    }
    [self.view addSubview:loadingView];
    CGRect r=loadingView.frame;
    r.origin.y=2;
    [loadingView.activityIndicatorView startAnimating];
    [UIView animateWithDuration:0.5f animations:^{
        loadingView.frame=r;
    }];
}
-(void) showErrorViewAnimated:(void (^)(AnimateErrorView *errorView))process{
    AnimateErrorView *errorView = [self errorView];
    if (process) {
        process(errorView);
    }
    [self.view addSubview:errorView];
    CGRect r=errorView.frame;
    r.origin.y=2;
    [UIView animateWithDuration:0.5f animations:^{
        errorView.frame=r;
    }];
}
-(void) showSuccessViewAnimated:(void (^)(AnimateErrorView *errorView))process{
    AnimateErrorView *errorView = [self successView];
    if (process) {
        process(errorView);
    }
    [self.view addSubview:errorView];
    CGRect r=errorView.frame;
    r.origin.y=2;
    [UIView animateWithDuration:0.5f animations:^{
        errorView.frame=r;
    }];
}
- (void)pwdDesEncrypWithCompleted:(void(^)(NSString *pwd))completed{
    TKTextFieldCell *cell=self.cells[3];
    NSMutableArray *params=[NSMutableArray arrayWithCapacity:2];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell.textField.text Trim],@"text", nil]];
    
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.methodName=@"DesEncrypt";
    args.soapParams=params;
    
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        NSString *memo=@"";
        if (result.hasSuccess) {
            XmlNode *node=[result methodNode];
            NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[node.InnerText dataUsingEncoding:NSUTF8StringEncoding] options:1 error:nil];
            memo=[dic objectForKey:@"Result"];
        }
        if (completed) {
            completed(memo);
        }
        
    } failed:^(NSError *error, NSDictionary *userInfo) {
        if (completed) {
            completed(@"");
        }
    }];
}
- (BOOL) isUIDString{
    TKTextFieldCell *cell1=self.cells[1];
    NSString *emailRegEx =@"^[a-zA-Z0-9_\\.]+$";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [regExPredicate evaluateWithObject:cell1.textField.text];
}
- (void)replaceUIDstring{
    NSRegularExpression *regular;
    regular = [[NSRegularExpression alloc] initWithPattern:@"[^a-zA-Z0-9_\\.]+"
                                                   options:NSRegularExpressionCaseInsensitive
                                                     error:nil];
    TKTextFieldCell *cell1=self.cells[1];
    NSString *str=[cell1.textField.text Trim];
    cell1.textField.text = [regular stringByReplacingMatchesInString:str options:NSRegularExpressionCaseInsensitive  range:NSMakeRange(0, [str length]) withTemplate:@""];  
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//取消 
-(void)buttonCancel{
    TKTextFieldCell *cell1=self.cells[1];
    cell1.textField.text=@"";
    [cell1.textField resignFirstResponder];
    TKTextFieldCell *cell2=self.cells[3];
    cell2.textField.text=@"";
    [cell2.textField resignFirstResponder];
    TKRegisterCheckCell *cell3=self.cells[4];
    [cell3.check setSelectItemSwitch:1];
    _buttons.submit.enabled=NO;
    
    //[self textFieldShouldReturn:cell1.textField];
    //[self textFieldShouldReturn:cell2.textField];
}
//登录
- (void)buttonSubmit:(id)sender{
    UIButton *submit=(UIButton*)sender;
    
    TKTextFieldCell *cell1=self.cells[1];
    if (!cell1.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请输入帐号/手机号!"];
        [cell1.textField becomeFirstResponder];
        return;
    }
    if (![self isUIDString]) {
        [AlertHelper initWithTitle:@"提示" message:@"帐号只能输入字母、数字、下划线!"];
        [cell1.textField becomeFirstResponder];
        return;
    }
    TKTextFieldCell *cell2=self.cells[3];
    if (!cell2.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请输入密码!"];
        [cell2.textField becomeFirstResponder];
        return;
    }
    if(strlen([cell2.textField.text UTF8String])<6)
    {
        [AlertHelper initWithTitle:@"提示" message:@"密码不能少于6位大于12位！"];
        [cell2.textField becomeFirstResponder];
        return;
    }
    [cell1.textField resignFirstResponder];
    [cell2.textField resignFirstResponder];
    if (!self.hasNetWork) {
        [self showErrorNetWorkNotice:nil];
        return;
    }
    submit.enabled=NO;
    [self showLoadingAnimatedWithTitle:@"正在登录,请稍后..."];
    //登录
    TKRegisterCheckCell *cell3=self.cells[4];
    NSMutableArray *params=[NSMutableArray arrayWithCapacity:2];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell1.textField.text Trim],@"userName", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell2.textField.text Trim],@"password", nil]];
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.methodName=@"UIDLogin";
    args.soapParams=params;
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        BOOL boo=NO;
        if ([result.xmlString length]>0) {
            NSString *xml=[result.xmlString stringByReplacingOccurrencesOfString:result.xmlnsAttr withString:@""];
            [result.xmlParse setDataSource:xml];
            XmlNode *node=[result.xmlParse soapXmlSelectSingleNode:@"//UIDLoginResult"];
            NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[node.InnerText dataUsingEncoding:NSUTF8StringEncoding] options:1 error:nil];
            if ([dic objectForKey:@"Account"]) {
                boo=YES;
                [self hideLoadingViewAnimated:^(AnimateLoadView *hideView) {
                    submit.enabled=YES;
                    //登录
                    [Account    loginGeneralWithUserId:[cell1.textField.text Trim] password:[cell2.textField.text Trim] encrypt:[cell2.textField.text Trim] rememberPassword:cell3.check.hasRemember withData:dic];
                   
                    IndexViewController *indexController=[[[IndexViewController alloc] init] autorelease];
                    BasicNavigationController *nav=[[[BasicNavigationController alloc] initWithRootViewController:indexController] autorelease];
                    
#ifdef __IPHONE_7_0
                    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
                        UIWindow *window=[[UIApplication sharedApplication] keyWindow];
                        window.rootViewController=nav;
                        return;
                    }
#endif
                    [self presentViewController:nav animated:YES completion:nil];
                    //MainViewController *main=[[MainViewController alloc] init];
                    //[self presentViewController:main animated:YES completion:nil];
                    //[main release];
                }];
            }
        }
        if (!boo) {
            [self hideLoadingFailedWithTitle:@"输入的帐号或密码错误,请重新输入!" completed:^(AnimateErrorView *failedView) {
                submit.enabled=YES;
            }];
        }
        
    } failed:^(NSError *error, NSDictionary *userInfo) {
        [self hideLoadingFailedWithTitle:@"输入的帐号或密码错误,请重新输入!" completed:^(AnimateErrorView *failedView) {
            submit.enabled=YES;
        }];
    }];
    /***
    [self pwdDesEncrypWithCompleted:^(NSString *pwd) {
        
    }];
     ***/
}
//注册
- (void)buttonRegister{
    /***
    RegisterViewController *controller=[[[RegisterViewController alloc] init] autorelease];
    CATransition *animation=[self getAnimation:2 subtype:2];
    [self presentViewController:controller animated:NO completion:nil];
    [controller.view.layer addAnimation:animation forKey:nil];
    ***/
    
    RegisterViewController *controller=[[[RegisterViewController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
    
}
#pragma mark UITextFieldDelegate Methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // return NO to not change text
    BOOL boo=YES;
    TKTextFieldCell *cell=self.cells[1];
    if (cell.textField==textField) {
        [self replaceUIDstring];
        if(strlen([textField.text UTF8String]) >= 12 && range.length != 1)
            boo=NO;
    }else{
        if(strlen([textField.text UTF8String]) >= 12 && range.length != 1)
             boo=NO;
    }
    TKTextFieldCell *cell1=self.cells[3];
    //TKLoginButtonCell *btn=self.cells[4];
    if ([[cell.textField.text Trim] length]>0&&[[cell1.textField.text Trim] length]>0) {
        _buttons.submit.enabled=YES;
    }else{
        _buttons.submit.enabled=NO;
    }
    return boo;
}
- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    TKTextFieldCell *cell=self.cells[1];
    TKTextFieldCell *cell1=self.cells[3];
    //TKLoginButtonCell *btn=self.cells[4];
    if ([[cell.textField.text Trim] length]>0&&[[cell1.textField.text Trim] length]>0) {
        _buttons.submit.enabled=YES;
    }else{
        _buttons.submit.enabled=NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
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
    if ([cell isKindOfClass:[TKRegisterCheckCell class]]) {
        return 90;
    }
    return 44.0;
}
@end
