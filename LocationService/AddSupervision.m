//
//  AddSupervision.m
//  LocationService
//
//  Created by aJia on 2013/12/25.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "AddSupervision.h"
#import "TKLabelCell.h"
#import "TKTextFieldCell.h"
#import "LoginButtons.h"
#import "Account.h"
#import "UIImage+TPCategory.h"
#import "EditSupervisionHead.h"
#import "SupervisionPerson.h"
#import "SupervisionExtend.h"
#import "AlertHelper.h"
@interface AddSupervision ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    UITableView *_tableView;
    UIImageView *_imageHead;
}
- (void)buttonSubmit;
- (void)buttonCancel;
- (void)buttonChooseImage;
- (CGRect)fieldToRect:(UITextField*)field;
- (void)replacePhonestring:(UITextField*)field;
- (void)uploadImageWithId:(NSString*)personId completed:(void(^)(NSString *fileName))completed;
- (void)finishAddTrajectory:(void(^)(NSString *personId,NSString *code))completed;
@end

@implementation AddSupervision
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
    
    TKLabelCell *cell3=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell3.label.text=@"IMEI号码";
    
    TKTextFieldCell *cell4=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell4.textField.placeholder=@"请输入IMEI号码";
    
    TKLabelCell *cell5=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell5.label.text=@"SIM卡号";
    
    TKTextFieldCell *cell6=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell6.textField.placeholder=@"请输入SIM卡号";
    cell6.textField.delegate=self;
    
    TKLabelCell *cell7=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell7.label.text=@"密码";
    
    TKTextFieldCell *cell8=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell8.textField.placeholder=@"请输入密码";
    cell8.textField.secureTextEntry=YES;
    cell8.textField.delegate=self;
    
    self.cells=[NSMutableArray arrayWithObjects:cell1,cell2,cell3,cell4,cell5,cell6,cell7,cell8, nil];
}
- (void)finishAddTrajectory:(void(^)(NSString *personId,NSString *code))completed{
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
    
    [self showLoadingAnimatedWithTitle:@"新增监管目标,请稍后..."];
    [self uploadImageWithId:@"" completed:^(NSString *fileName) {
        NSMutableArray *params=[NSMutableArray arrayWithCapacity:6];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell1.textField.text Trim],@"Name", nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell3.textField.text Trim],@"phoneNum", nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell2.textField.text Trim],@"strIMEI", nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell4.textField.text Trim],@"Password", nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:fileName,@"photo", nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:acc.WorkNo,@"CurWorkNo", nil]];
        
        ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
        args.serviceURL=DataWebservice1;
        args.serviceNameSpace=DataNameSpace1;
        args.methodName=@"InsertPerson";
        args.soapParams=params;
        
        [self.serviceHelper asynService:args success:^(ServiceResult *result) {
            BOOL boo=NO;
            NSString *status=@"0";
            if (result.hasSuccess) {
                XmlNode *node=[result methodNode];
                NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[node.InnerText dataUsingEncoding:NSUTF8StringEncoding] options:1 error:nil];
                if ([dic.allKeys containsObject:@"ID"]) {
                    boo=YES;
                    [self hideLoadingViewAnimated:^(AnimateLoadView *hideView) {
                        if (completed) {
                            completed([dic objectForKey:@"ID"],[dic objectForKey:@"DeviceCode"]);
                        }
                    }];
                    return;
                }else{
                   status=[dic objectForKey:@"Result"];
                }
            }
            if (!boo) {
                NSString *errorMsg=@"新增监管目标失败!";
                if ([status isEqualToString:@"5"]) {
                    errorMsg=@"密码与IMEI的密码不匹配,无法新增!";
                }
                if ([status isEqualToString:@"6"]) {
                    errorMsg=@"SIM卡号与IMEI的SIM卡不匹配,无法新增!";
                }
                [self hideLoadingFailedWithTitle:errorMsg completed:nil];
            }
        } failed:^(NSError *error, NSDictionary *userInfo) {
            [self hideLoadingFailedWithTitle:@"新增监管目标失败!" completed:nil];
        }];
    }];
}
//完成
- (void)buttonSubmit{
    [self finishAddTrajectory:^(NSString *personId,NSString *code) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
//下一步
- (void)buttonCancel{
    [self finishAddTrajectory:^(NSString *personId,NSString *code) {
        SupervisionExtend *extend=[[SupervisionExtend alloc] init];
        extend.PersonId=personId;
        extend.operateType=1;//新增
        extend.DeviceCode=code;
        [self.navigationController pushViewController:extend animated:YES];
        [extend release];
    }];
}
//选照片
- (void)buttonChooseImage{
    SupervisionPerson *entity=[[[SupervisionPerson alloc] init] autorelease];
    entity.ID=@"";
    entity.Name=@"监管目标头像";
    EditSupervisionHead *head=[[EditSupervisionHead alloc] init];
    head.Entity=entity;
    head.operateType=1;//新增
    head.delegate=self;
    [self.navigationController pushViewController:head animated:YES];
    [head release];
}
- (void)finishSelectedImage:(UIImage*)image{
    [_imageHead setImage:image];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
- (void)uploadImageWithId:(NSString*)personId completed:(void(^)(NSString *fileName))completed{
    if (_imageHead.image!=nil) {
        NSString *base64=[_imageHead.image imageBase64String];
        NSMutableArray *params=[NSMutableArray arrayWithCapacity:2];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:base64,@"imgbase64", nil]];
        [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:personId,@"personID", nil]];
        
        ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
        args.serviceURL=DataWebservice1;
        args.serviceNameSpace=DataNameSpace1;
        args.methodName=@"UpImage";
        args.soapParams=params;
        [self.serviceHelper asynService:args success:^(ServiceResult *result) {
            NSString *name=@"";
            if (result.hasSuccess) {
                XmlNode *node=[result methodNode];
                NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[node.InnerText dataUsingEncoding:NSUTF8StringEncoding] options:1 error:nil];
                if (![[dic objectForKey:@"Result"] isEqualToString:@"false"]) {
                    name=[dic objectForKey:@"Result"];
                }
            }
            if (completed) {
                completed(name);
            }
        } failed:^(NSError *error, NSDictionary *userInfo) {
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
    [_imageHead setImage:image];
    [bgView addSubview:_imageHead];
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=_imageHead.frame;
    [btn addTarget:self action:@selector(buttonChooseImage) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btn];
    return bgView;
}
@end
