//
//  EditPwdViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/19.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "EditPwdViewController.h"
#import "LoginButtons.h"
#import "TKLabelCell.h"
#import "TKTextFieldCell.h"
#import "AlertHelper.h"
#import "Account.h"
@interface EditPwdViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    UITableView *_tableView;
    LoginButtons *_buttons;
    
}
-(void)buttonCancel;
-(void)buttonSubmit;
- (void)pwdDesEncrypWithCompleted:(void(^)(NSString *pwd))completed;
@end

@implementation EditPwdViewController

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
    [self.navBarView setNavBarTitle:@"修改密码"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    CGRect r=self.view.bounds;
    r.size.height-=44*2;
    r.origin.y=44;
    _tableView=[[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor=[UIColor clearColor];
    _tableView.bounces=NO;
    //_tableView.backgroundView = [[UIView alloc] init];
    //_tableView.backgroundColor = [UIColor colorFromHexRGB:@"f5f5f5"];
    [self.view addSubview:_tableView];
    
    TKLabelCell *cell1=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell1.label.text=@"原密码";
    
    TKTextFieldCell *cell2=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell2.textField.placeholder=@"请输入原密码";
    cell2.textField.layer.borderWidth=2.0;
    cell2.textField.layer.cornerRadius=5.0;
    cell2.textField.layer.borderColor=[UIColor colorFromHexRGB:@"4a7ebb"].CGColor;
    cell2.textField.textColor=[UIColor colorFromHexRGB:@"4a7ebb"];
    cell2.textField.delegate=self;
    cell2.textField.secureTextEntry=YES;
    
    TKLabelCell *cell3=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell3.label.text=@"新密码";
    
    TKTextFieldCell *cell4=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell4.textField.placeholder=@"请输入新密码";
    cell4.textField.layer.borderWidth=2.0;
    cell4.textField.layer.cornerRadius=5.0;
    cell4.textField.layer.borderColor=[UIColor colorFromHexRGB:@"4a7ebb"].CGColor;
    cell4.textField.textColor=[UIColor colorFromHexRGB:@"4a7ebb"];
    cell4.textField.secureTextEntry=YES;
    cell4.textField.delegate=self;
    
    TKLabelCell *cell5=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell5.label.text=@"确认新密码";
    
    TKTextFieldCell *cell6=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell6.textField.placeholder=@"请输入确认新密码";
    cell6.textField.layer.borderWidth=2.0;
    cell6.textField.layer.cornerRadius=5.0;
    cell6.textField.layer.borderColor=[UIColor colorFromHexRGB:@"4a7ebb"].CGColor;
    cell6.textField.textColor=[UIColor colorFromHexRGB:@"4a7ebb"];
    cell6.textField.secureTextEntry=YES;
    cell6.textField.delegate=self;
    
   
    
    self.cells=[NSMutableArray arrayWithObjects:cell1,cell2,cell3,cell4,cell5,cell6, nil];
    
    _buttons=[[LoginButtons alloc] initWithFrame:CGRectMake(0,_tableView.frame.origin.y+_tableView.frame.size.height, self.view.bounds.size.width, 44)];
    [_buttons.submit addTarget:self action:@selector(buttonSubmit) forControlEvents:UIControlEventTouchUpInside];
    [_buttons.cancel addTarget:self action:@selector(buttonCancel) forControlEvents:UIControlEventTouchUpInside];
    _buttons.submit.enabled=NO;
    [_buttons.submit setTitle:@"完成" forState:UIControlStateNormal];
    [self.view addSubview:_buttons];

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

//完成
-(void)buttonSubmit{
    Account *acc=[Account unarchiverAccount];
    TKTextFieldCell *cell1=self.cells[1];
    if (!cell1.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请输入原密码"];
        [cell1.textField becomeFirstResponder];
        return;
    }
    if(strlen([cell1.textField.text UTF8String])<6)
    {
        [AlertHelper initWithTitle:@"提示" message:@"原密码不能少于6位大于12位！"];
        [cell1.textField becomeFirstResponder];
        return;
    }
    if ([acc.Password isEqualToString:[cell1.textField.text Trim]]) {
        [AlertHelper initWithTitle:@"提示" message:@"原密码错误,请重新输入！"];
        [cell1.textField becomeFirstResponder];
        return;
    }
    TKTextFieldCell *cell2=self.cells[3];
    if (!cell2.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请输入新密码!"];
        [cell2.textField becomeFirstResponder];
        return;
    }
    if(strlen([cell2.textField.text UTF8String])<6)
    {
        [AlertHelper initWithTitle:@"提示" message:@"新密码不能少于6位大于12位！"];
        [cell2.textField becomeFirstResponder];
        return;
    }
    NSString *emailRegEx =@"^[a-zA-Z0-9_]+$";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    if ([regExPredicate evaluateWithObject:cell2.textField.text]) {
        [AlertHelper initWithTitle:@"提示" message:@"新密码格式错误,只能由字母、数字、下划线组成!"];
        [cell2.textField becomeFirstResponder];
        return;
    }
    
    TKTextFieldCell *cell3=self.cells[5];
    if (!cell3.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请输入确认密码!"];
        [cell3.textField becomeFirstResponder];
        return;
    }
    if (![cell2.textField.text isEqualToString:cell3.textField.text]) {
        [AlertHelper initWithTitle:@"提示" message:@"新密码与确认密码不一致!"];
        [cell3.textField becomeFirstResponder];
        return;
    }
    if (!self.hasNetWork) {
        [self showErrorNetWorkNotice:nil];
        return;
    }
    [self showLoadingAnimatedWithTitle:@"正在修改密码,请稍后..."];
    [self pwdDesEncrypWithCompleted:^(NSString *pwd) {
        Account *acc=[Account unarchiverAccount];
        NSMutableArray *params=[NSMutableArray arrayWithCapacity:2];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:acc.UserId,@"userId", nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:acc.encryptPwd,@"oldpwd", nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:pwd,@"newpwd", nil]];
        
        ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
        args.serviceURL=DataWebservice1;
        args.serviceNameSpace=DataWebservice1;
        args.methodName=@"ModifyPassword";
        args.soapParams=params;
        //NSLog(@"soap=%@",args.soapMessage);
        [self.serviceHelper asynService:args success:^(ServiceResult *result) {
            BOOL boo=NO;
            if (result.hasSuccess) {
                XmlNode *node=[result methodNode];
                NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[node.InnerText dataUsingEncoding:NSUTF8StringEncoding] options:1 error:nil];
                if ([[dic objectForKey:@"Result"] isEqualToString:@"2"]) {
                    boo=YES;
                }
            }
            if (boo) {
                [self hideLoadingViewAnimated:^(AnimateLoadView *hideView) {
                    [Account editPwd:[cell1.textField.text Trim] encrypt:@""];
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }else{
                [self hideLoadingFailedWithTitle:@"输入的密码错误,请重新输入!" completed:nil];
            }
        } failed:^(NSError *error, NSDictionary *userInfo) {
            [self hideLoadingFailedWithTitle:@"输入的密码错误,请重新输入!" completed:nil];
        }];

    }];
}
//取消
-(void)buttonCancel{
    TKTextFieldCell *cell=self.cells[1];
    cell.textField.text=@"";
    [cell.textField resignFirstResponder];
    TKTextFieldCell *cell1=self.cells[3];
    cell1.textField.text=@"";
    [cell1.textField resignFirstResponder];
    TKTextFieldCell *cell2=self.cells[5];
    cell2.textField.text=@"";
    [cell2.textField resignFirstResponder];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UITextFieldDelegate Methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // return NO to not change text
    BOOL boo=YES;
    if(strlen([textField.text UTF8String]) >= 12 && range.length != 1)
        boo=NO;
    
    TKTextFieldCell *cell=self.cells[1];
    TKTextFieldCell *cell1=self.cells[3];
    TKTextFieldCell *cell2=self.cells[5];
    if ([[cell.textField.text Trim] length]==0||[[cell1.textField.text Trim] length]==0||[[cell2.textField.text Trim] length]==0) {
        _buttons.submit.enabled=NO;
    }else{
        _buttons.submit.enabled=YES;
    }
    return boo;
}
- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    TKTextFieldCell *cell=self.cells[1];
    TKTextFieldCell *cell1=self.cells[3];
    TKTextFieldCell *cell2=self.cells[5];
    if ([[cell.textField.text Trim] length]==0||[[cell1.textField.text Trim] length]==0||[[cell2.textField.text Trim] length]==0) {
        _buttons.submit.enabled=NO;
    }else{
        _buttons.submit.enabled=YES;
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
    return 44.0;
}
@end
