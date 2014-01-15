//
//  EditSupervisionViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/27.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "EditSupervisionViewController.h"
#import "LoginButtons.h"
#import "TKLabelCell.h"
#import "TKTextFieldCell.h"
#import "UIImageView+WebCache.h"
#import "EditSupervisionHead.h"
#import "Account.h"
#import "AlertHelper.h"
#import "SupervisionExtend.h"
#import "AppUI.h"
@interface EditSupervisionViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    UITableView *_tableView;
    UIImageView *_imageHead;
}
- (void)buttonSubmit;
- (void)buttonCancel;
- (void)buttonChooseImage;
- (void)finishEditTrajectory:(void(^)(NSString *personId))completed;
@end

@implementation EditSupervisionViewController
- (void)dealloc{
    //[UITableView release];
    [super dealloc];
    [_tableView release];
    [_imageHead release];
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
    [self.navBarView setNavBarTitle:@"监管目标"];
    if (![self.navBarView viewWithTag:301]) {
        UIButton *btn=[AppUI createhighlightButtonWithTitle:@"列表" frame:CGRectMake(self.view.bounds.size.width-50, (44-35)/2, 50, 35)];
        btn.tag=301;
        [btn addTarget:self action:@selector(buttonListClick) forControlEvents:UIControlEventTouchUpInside];
        [self.navBarView addSubview:btn];
    }
}
//回列表
- (void)buttonListClick{
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	CGRect r=self.view.bounds;
    r.origin.y=44;
    r.size.height-=44*2;
    
    
    _tableView=[[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor=[UIColor clearColor];
    _tableView.bounces=NO;
    //_tableView.autoresizesSubviews=YES;
    //_tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_tableView];
    
    LoginButtons *buttons=[[LoginButtons alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    buttons.cancel.frame=CGRectMake(self.view.bounds.size.width*2/3, 0, self.view.bounds.size.width/3, 44);
    buttons.submit.frame=CGRectMake(self.view.bounds.size.width/3, 0, self.view.bounds.size.width/3, 44);
    [buttons.cancel setTitle:@"下一步" forState:UIControlStateNormal];
    [buttons.submit setTitle:@"完成" forState:UIControlStateNormal];
    [buttons.submit addTarget:self action:@selector(buttonSubmit) forControlEvents:UIControlEventTouchUpInside];
    [buttons.cancel addTarget:self action:@selector(buttonCancel) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:buttons];
    [buttons release];
    
    TKLabelCell *cell1=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell1.label.text=@"名称";
    
    TKTextFieldCell *cell2=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell2.textField.placeholder=@"请输入名称";
    cell2.textField.delegate=self;
    cell2.textField.text=self.Entity.Name;
    
    TKLabelCell *cell3=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell3.label.text=@"IMEI号码";
    
    TKTextFieldCell *cell4=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell4.textField.placeholder=@"请输入IMEI号码";
    cell4.textField.text=self.Entity.IMEI;
    cell4.textField.delegate=self;
    
    TKLabelCell *cell5=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell5.label.text=@"SIM卡号";
    
    TKTextFieldCell *cell6=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell6.textField.placeholder=@"请输入SIM卡号";
    cell6.textField.delegate=self;
    cell6.textField.text=self.Entity.SimNo;
    
    TKLabelCell *cell7=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell7.label.text=@"密码";
    
    TKTextFieldCell *cell8=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell8.textField.placeholder=@"请输入密码";
    cell8.textField.secureTextEntry=YES;
    cell8.textField.delegate=self;
    cell8.textField.text=self.Entity.Password;
    
    self.cells=[NSMutableArray arrayWithObjects:cell1,cell2,cell3,cell4,cell5,cell6,cell7,cell8, nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//修改
- (void)finishEditTrajectory:(void(^)(NSString *personId))completed{
    if (!self.hasNetWork) {
        [self showErrorNetWorkNotice:nil];
        return;
    }
    Account *acc=[Account unarchiverAccount];
    TKTextFieldCell *cell1=self.cells[1];
    
    if (!cell1.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请输入名称!"];
        [cell1.textField becomeFirstResponder];
        return;
    }
    
    TKTextFieldCell *cell2=self.cells[3];
    if (!cell2.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请输入IMEI号码!"];
        [cell2.textField becomeFirstResponder];
        return;
    }
    TKTextFieldCell *cell3=self.cells[5];
    if (!cell3.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请输入SIM卡号!"];
        [cell3.textField becomeFirstResponder];
        return;
    }
    TKTextFieldCell *cell4=self.cells[7];
    if (!cell4.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请输入密码!"];
        [cell4.textField becomeFirstResponder];
        return;
    }
    
    [self showLoadingAnimatedWithTitle:@"修改监管目标,请稍后..."];
    
        NSMutableArray *params=[NSMutableArray arrayWithCapacity:6];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.Entity.ID,@"personID", nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell1.textField.text Trim],@"Name", nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell3.textField.text Trim],@"phoneNum", nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell2.textField.text Trim],@"strIMEI", nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell4.textField.text Trim],@"Password", nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.Entity.fileName,@"photo", nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:acc.WorkNo,@"CurWorkNo", nil]];
        
        ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
        args.serviceURL=DataWebservice1;
        args.serviceNameSpace=DataNameSpace1;
        args.methodName=@"UpdatePerson";
        args.soapParams=params;
        [self.serviceHelper asynService:args success:^(ServiceResult *result) {
            BOOL boo=NO;
            if (result.hasSuccess) {
                XmlNode *node=[result methodNode];
                NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[node.InnerText dataUsingEncoding:NSUTF8StringEncoding] options:1 error:nil];
                if ([[dic objectForKey:@"Result"] isEqualToString:@"1"]) {
                    boo=YES;
                    [self hideLoadingViewAnimated:^(AnimateLoadView *hideView) {
                        if (completed) {
                            completed(self.Entity.ID);
                        }
                    }];
                    return;
                }
            }
            if (!boo) {
                [self hideLoadingFailedWithTitle:@"修改监管目标失败!" completed:nil];
            }
        } failed:^(NSError *error, NSDictionary *userInfo) {
            [self hideLoadingFailedWithTitle:@"修改监管目标失败!" completed:nil];
        }];
    
}
//完成
- (void)buttonSubmit{
    [self finishEditTrajectory:^(NSString *personId) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
//下一步
- (void)buttonCancel{
    [self finishEditTrajectory:^(NSString *personId) {
        SupervisionExtend *extend=[[SupervisionExtend alloc] init];
        extend.operateType=2;//修改
        extend.PersonId=personId;
        extend.DeviceCode=self.Entity.DeviceCode;
        [self.navigationController pushViewController:extend animated:YES];
        [extend release];
    }];
}
//选照片
- (void)buttonChooseImage{
    EditSupervisionHead *head=[[EditSupervisionHead alloc] init];
    head.Entity=self.Entity;
    head.operateType=2;//新增
    head.delegate=self;
    [self.navigationController pushViewController:head animated:YES];
    [head release];
}
- (void)finishSelectedImage:(UIImage*)image{
    [_imageHead setImage:image];
}
- (void)finishUploadFileName:(NSString*)fileName{
    self.Entity.Photo=fileName;
}
- (void)replacePhonestring:(UITextField*)field{
    NSRegularExpression *regular;
    regular = [[NSRegularExpression alloc] initWithPattern:@"[^0-9]+"
                                                   options:NSRegularExpressionCaseInsensitive
                                                     error:nil];
    NSString *str=[field.text Trim];
    field.text = [regular stringByReplacingMatchesInString:str options:NSRegularExpressionCaseInsensitive  range:NSMakeRange(0, [str length]) withTemplate:@""];
}
- (CGRect)fieldToRect:(UITextField*)field{
    id v=[field superview];
    while (![v isKindOfClass:[UITableViewCell class]]) {
        v=[v superview];
    }
    UITableViewCell *cell=(UITableViewCell*)v;
    CGRect r=[_tableView convertRect:cell.frame fromView:_tableView];
    CGRect r1=[cell convertRect:field.frame fromView:cell];
    r.origin.y+=44+r1.origin.y;
    r.origin.x=r1.origin.x;
    
    return r;
}
#pragma mark UITextFieldDelegate Methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // return NO to not change text
    BOOL boo=YES;
    TKTextFieldCell *cell1=self.cells[7];
    if (cell1.textField==textField) {
        if(strlen([textField.text UTF8String]) >= 12 && range.length != 1)
            boo=NO;
    }
    TKTextFieldCell *cell2=self.cells[3];
    TKTextFieldCell *cell3=self.cells[5];
    if (cell2.textField==textField||cell3.textField==textField) {
        [self replacePhonestring:textField];
        if(strlen([textField.text UTF8String]) >= 11 && range.length != 1)
            boo=NO;
    }
    return boo;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    CGRect frame = [self fieldToRect:textField];
    int offset = frame.origin.y + 36 - (self.view.frame.size.height - 216.0);//键盘高度216
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}
- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
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
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 110;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *bgView=[[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 110)] autorelease];
    bgView.backgroundColor=[UIColor clearColor];
    UIImage *image=[UIImage imageNamed:@"bg03.png"];
    _imageHead=[[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-image.size.width)/2,bgView.frame.size.height-image.size.height, image.size.width, image.size.height)];
    [_imageHead setImageWithURL:[NSURL URLWithString:self.Entity.Photo] placeholderImage:image];
    [bgView addSubview:_imageHead];
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=_imageHead.frame;
    [btn addTarget:self action:@selector(buttonChooseImage) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btn];
    return bgView;
}
@end
