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
#import "AppUI.h"
#import "SupervisionViewController.h"
#import "TKEmptyCell.h"
@interface AddSupervision ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    UITableView *_tableView;
    UIImageView *_imageHead;
    LoginButtons *_toolBar;
}
@property (nonatomic,assign) CGRect tableRect;
- (void)buttonSubmit;
- (void)buttonCancel;
- (void)buttonChooseImage;
- (CGRect)fieldToRect:(UITextField*)field;
- (void)replacePhonestring:(UITextField*)field;
- (void)uploadImageWithId:(NSString*)personId completed:(void(^)(NSString *fileName))completed;
- (void)finishAddTrajectory:(void(^)(NSString *personId,NSString *code))completed;
- (void)loadingPersonInfo;
- (void)finishEditTrajectory:(void(^)(NSString *personId))completed;
- (NSString*)getUploadFileName;
@end

@implementation AddSupervision
- (void)dealloc{
    //[UITableView release];
    [super dealloc];
    [_tableView release];
    [_imageHead release];
    [_toolBar release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    if (self.navigationController.viewControllers.count>=3) {
        if ([self.navigationController.viewControllers[2] isKindOfClass:[SupervisionViewController class]]) {
            if (![self.navBarView viewWithTag:301]) {
                UIButton *btn=[AppUI createhighlightButtonWithTitle:@"列表" frame:CGRectMake(self.view.bounds.size.width-50, (44-35)/2, 50, 35)];
                btn.tag=301;
                [btn addTarget:self action:@selector(buttonListClick) forControlEvents:UIControlEventTouchUpInside];
                [self.navBarView addSubview:btn];
            }
        }
    }
   

    
    [self loadingPersonInfo];//修改时，加载信息
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
    
    self.tableRect=r;
    _tableView=[[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor=[UIColor clearColor];
    _tableView.bounces=NO;
    //_tableView.autoresizesSubviews=YES;
    //_tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_tableView];
    
    _toolBar=[[LoginButtons alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    _toolBar.cancel.frame=CGRectMake(self.view.bounds.size.width*2/3, 0, self.view.bounds.size.width/3, 44);
    _toolBar.submit.frame=CGRectMake(self.view.bounds.size.width/3, 0, self.view.bounds.size.width/3, 44);
    [_toolBar.cancel setTitle:@"下一步" forState:UIControlStateNormal];
    [_toolBar.submit setTitle:@"完成" forState:UIControlStateNormal];
    [_toolBar.submit addTarget:self action:@selector(buttonSubmit) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar.cancel addTarget:self action:@selector(buttonCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_toolBar];
    
    //头像
    TKEmptyCell *cell9=[[[TKEmptyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
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
    [cell9.contentView addSubview:bgView];
    

    
    TKLabelCell *cell1=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell1.label.text=@"名称";
    
    TKTextFieldCell *cell2=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell2.textField.placeholder=@"请输入名称";
    cell2.textField.delegate=self;
    
    TKLabelCell *cell3=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell3.label.text=@"IMEI号码";
    
    TKTextFieldCell *cell4=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell4.textField.placeholder=@"请输入IMEI号码";
    cell4.textField.delegate=self;
    cell4.textField.keyboardType=UIKeyboardTypeAlphabet;
    
    TKLabelCell *cell5=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell5.label.text=@"SIM卡号";
    
    TKTextFieldCell *cell6=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell6.textField.placeholder=@"请输入SIM卡号";
    cell6.textField.delegate=self;
    cell6.textField.keyboardType=UIKeyboardTypeAlphabet;
    
    TKLabelCell *cell7=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell7.label.text=@"密码";
    
    TKTextFieldCell *cell8=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell8.textField.placeholder=@"请输入密码";
    cell8.textField.secureTextEntry=YES;
    cell8.textField.delegate=self;
    
    self.cells=[NSMutableArray arrayWithObjects:cell9,cell1,cell2,cell3,cell4,cell5,cell6,cell7,cell8, nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardWillShowHideNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardWillShowHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
#pragma mark - Notifications
- (void)handleKeyboardWillShowHideNotification:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    //取得键盘的大小
    CGRect kbFrame = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {//显示键盘
        CGRect r=_tableView.frame;
        CGRect r1=_toolBar.frame;
        r.size.height=self.tableRect.size.height-kbFrame.size.height;
        
        r1.origin.y=r.origin.y+r.size.height;
        [UIView animateWithDuration:[[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
            _tableView.frame=r;
            _toolBar.frame=r1;
        }];
        
    }
    else {//隐藏键盘
        CGRect r=_tableView.frame;
        CGRect r1=_toolBar.frame;
        r.size.height=self.tableRect.size.height;
        r1.origin.y=self.tableRect.origin.y+r.size.height;
        [UIView animateWithDuration:[[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
            _tableView.frame=r;
            _toolBar.frame=r1;
        }];
    }
}

//修改时，加载信息
- (void)loadingPersonInfo{
    if (self.operateType==2&&self.PersonID&&[self.PersonID length]>0) {
        
        ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
        args.methodName=@"GetPersonByID";
        args.serviceURL=DataWebservice1;
        args.serviceNameSpace=DataNameSpace1;
        args.soapParams=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:self.PersonID,@"personID", nil], nil];
        
        [self.serviceHelper asynService:args success:^(ServiceResult *result) {
            NSDictionary *dic=[result json];
            if(dic!=nil)
            {
                NSArray *source=[dic objectForKey:@"Person"];
                if ([source count]>0) {
                    NSDictionary *item=[source objectAtIndex:0];
                    self.PhoneName=[item objectForKey:@"Photo"];
                    
                    TKTextFieldCell *cell1=self.cells[2];
                    cell1.textField.text=[item objectForKey:@"Name"];
                    
                    TKTextFieldCell *cell2=self.cells[4];
                    cell2.textField.text=[item objectForKey:@"DeviceID"];
                    
                    TKTextFieldCell *cell3=self.cells[6];
                    cell3.textField.text=[item objectForKey:@"SimNo"];
                    
                    TKTextFieldCell *cell4=self.cells[8];
                    cell4.textField.text=[item objectForKey:@"Password"];
                    
                }
            }
        } failed:nil];
    }
}
//新增
- (void)finishAddTrajectory:(void(^)(NSString *personId,NSString *code))completed{
   
    Account *acc=[Account unarchiverAccount];
    TKTextFieldCell *cell1=self.cells[2];
    
    if (!cell1.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请输入名称!"];
        [cell1.textField becomeFirstResponder];
        return;
    }
    
    TKTextFieldCell *cell2=self.cells[4];
    if (!cell2.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请输入IMEI号码!"];
        [cell2.textField becomeFirstResponder];
        return;
    }
    TKTextFieldCell *cell3=self.cells[6];
    if (!cell3.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请输入SIM卡号!"];
        [cell3.textField becomeFirstResponder];
        return;
    }
    if (![cell3.textField.text isNumberString]) {
        [AlertHelper initWithTitle:@"提示" message:@"SIM卡号只能为数字!"];
        [cell3.textField becomeFirstResponder];
        return;
    }
    if(strlen([cell3.textField.text UTF8String])<11)
    {
        [AlertHelper initWithTitle:@"提示" message:@"SIM卡号必须为11位！"];
        [cell3.textField becomeFirstResponder];
        return;
    }

    TKTextFieldCell *cell4=self.cells[8];
    if (!cell4.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请输入密码!"];
        [cell4.textField becomeFirstResponder];
        return;
    }
     [self textFieldShouldReturn:cell1.textField];
     [self textFieldShouldReturn:cell2.textField];
     [self textFieldShouldReturn:cell3.textField];
     [self textFieldShouldReturn:cell4.textField];
    if (!self.hasNetWork) {
        [self showErrorNetWorkNotice:nil];
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
        //NSLog(@"soap=%@",args.soapMessage);
        [self.serviceHelper asynService:args success:^(ServiceResult *result) {
             //NSLog(@"xml=%@",result.request.responseString);
            BOOL boo=NO;
            NSString *status=@"0";
            if (result.hasSuccess) {
                XmlNode *node=[result methodNode];
                NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[node.InnerText dataUsingEncoding:NSUTF8StringEncoding] options:1 error:nil];
                if ([dic.allKeys containsObject:@"ID"]) {
                    boo=YES;
                    [self hideLoadingViewAnimated:^(AnimateLoadView *hideView) {
                        if (completed) {
                            self.PhoneName=fileName;
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
                if ([status isEqualToString:@"2"]) {
                    errorMsg=@"输入的手机号码已绑定终端,无法新增!";
                }
                if ([status isEqualToString:@"5"]) {
                    errorMsg=@"输入的密码与IMEI的密码不匹配,无法新增!";
                }
                if ([status isEqualToString:@"6"]) {
                    errorMsg=@"输入的SIM卡号与IMEI的SIM卡不匹配,无法新增!";
                }
                if ([status isEqualToString:@"7"]) {
                    errorMsg=@"已存在该终端的目标,无法新增!";
                }
                if ([status isEqualToString:@"Exists"]) {
                    errorMsg=@"名称已存在!";
                }
                [self hideLoadingFailedWithTitle:errorMsg completed:nil];
            }
        } failed:^(NSError *error, NSDictionary *userInfo) {
            [self hideLoadingFailedWithTitle:@"新增监管目标失败!" completed:nil];
        }];
    }];
}
//修改
- (void)finishEditTrajectory:(void(^)(NSString *personId))completed{
    
    Account *acc=[Account unarchiverAccount];
    TKTextFieldCell *cell1=self.cells[2];
    if (!cell1.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请输入名称!"];
        [cell1.textField becomeFirstResponder];
        return;
    }
    
    TKTextFieldCell *cell2=self.cells[4];
    if (!cell2.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请输入IMEI号码!"];
        [cell2.textField becomeFirstResponder];
        return;
    }
    TKTextFieldCell *cell3=self.cells[6];
    if (!cell3.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请输入SIM卡号!"];
        [cell3.textField becomeFirstResponder];
        return;
    }
    if (![cell3.textField.text isNumberString]) {
        [AlertHelper initWithTitle:@"提示" message:@"SIM卡号只能为数字!"];
        [cell3.textField becomeFirstResponder];
        return;
    }
    if(strlen([cell3.textField.text UTF8String])<11)
    {
        [AlertHelper initWithTitle:@"提示" message:@"SIM卡号必须为11位！"];
        [cell3.textField becomeFirstResponder];
        return;
    }
    
    TKTextFieldCell *cell4=self.cells[8];
    if (!cell4.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请输入密码!"];
        [cell4.textField becomeFirstResponder];
        return;
    }
    [self textFieldShouldReturn:cell1.textField];
    [self textFieldShouldReturn:cell2.textField];
    [self textFieldShouldReturn:cell3.textField];
    [self textFieldShouldReturn:cell4.textField];
    if (!self.hasNetWork) {
        [self showErrorNetWorkNotice:nil];
        return;
    }
    [self showLoadingAnimatedWithTitle:@"修改监管目标,请稍后..."];
    
    NSMutableArray *params=[NSMutableArray arrayWithCapacity:6];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.PersonID,@"personID", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell1.textField.text Trim],@"Name", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell3.textField.text Trim],@"phoneNum", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell2.textField.text Trim],@"strIMEI", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell4.textField.text Trim],@"Password", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[self getUploadFileName],@"photo", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:acc.WorkNo,@"CurWorkNo", nil]];
    
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.methodName=@"UpdatePerson";
    args.soapParams=params;
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        BOOL boo=NO;
         NSString *status=@"";
        if (result.hasSuccess) {
            XmlNode *node=[result methodNode];
            NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[node.InnerText dataUsingEncoding:NSUTF8StringEncoding] options:1 error:nil];
            if ([[dic objectForKey:@"Result"] isEqualToString:@"1"]) {
                boo=YES;
                [self hideLoadingViewAnimated:^(AnimateLoadView *hideView) {
                    if (completed) {
                        completed(self.PersonID);
                    }
                }];
                return;
            }
            
            if ([dic.allKeys containsObject:@"Result"]) {
                status=[dic objectForKey:@"Result"];
            }
            
        }
        if (!boo) {
            NSString *errorMsg=@"修改监管目标失败!";
            if ([status isEqualToString:@"Exists"]) {
                errorMsg=@"名称重复!";
            }
            if ([status isEqualToString:@"2"]) {
                errorMsg=@"输入的手机号码已绑定终端,无法修改!";
            }
            if ([status isEqualToString:@"5"]) {
                errorMsg=@"输入的密码与IMEI的密码不匹配,无法修改!";
            }
            if ([status isEqualToString:@"6"]) {
                errorMsg=@"输入的SIM卡号与IMEI的SIM卡不匹配,无法修改!";
            }
            if ([status isEqualToString:@"7"]) {
                errorMsg=@"已存在该终端的目标,无法修改!";
            }

            [self hideLoadingFailedWithTitle:errorMsg completed:nil];
        }
    } failed:^(NSError *error, NSDictionary *userInfo) {
        [self hideLoadingFailedWithTitle:@"修改监管目标失败!" completed:nil];
    }];
    
}
- (NSString*)getUploadFileName{
    if (self.PhoneName&&[self.PhoneName length]>0) {
        int pos=[self.PhoneName lastIndexOf:@"/"];
        if (pos!=-1) {
            return [self.PhoneName substringFromIndex:pos+1];
        }
    }
    return @"";
}
//完成
- (void)buttonSubmit{
    [self finishAddTrajectory:^(NSString *personId,NSString *code) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
//下一步
- (void)buttonCancel{
    if (self.operateType==1) {//新增
        [self finishAddTrajectory:^(NSString *personId,NSString *code) {
            self.operateType=2;//修改
            self.PersonID=personId;//修改
            self.DeviceCode=code;
            
            SupervisionExtend *extend=[[SupervisionExtend alloc] init];
            extend.PersonId=personId;
            extend.operateType=1;//新增
            extend.DeviceCode=code;
            [self.navigationController pushViewController:extend animated:YES];
            [extend release];
        }];
    }else{//修改
        [self finishEditTrajectory:^(NSString *personId) {
            self.operateType=2;//修改
            self.PersonID=personId;//修改
            
            SupervisionExtend *extend=[[SupervisionExtend alloc] init];
            extend.PersonId=personId;
            extend.operateType=1;//新增
            extend.DeviceCode=self.DeviceCode;
            [self.navigationController pushViewController:extend animated:YES];
            [extend release];
            
        }];
    }
}
//选照片
- (void)buttonChooseImage{
    SupervisionPerson *entity=[[[SupervisionPerson alloc] init] autorelease];
    entity.ID=self.operateType==1?@"":self.PersonID;
    entity.Name=@"监管目标头像";
    EditSupervisionHead *head=[[EditSupervisionHead alloc] init];
    head.Entity=entity;
    head.operateType=self.operateType;//新增
    head.delegate=self;
    [self.navigationController pushViewController:head animated:YES];
    [head release];
}
- (void)finishSelectedImage:(UIImage*)image{
    [_imageHead setImage:image];
}
//获取修改的图片名称
- (void)finishUploadFileName:(NSString*)fileName{
    self.PhoneName=fileName;
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
                    int pos=[name lastIndexOf:@"/"];
                    if (pos!=-1) {
                        name=[name substringFromIndex:pos+1];
                    }
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
    CGRect r=[self.view convertRect:cell.frame fromView:_tableView];
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
    TKTextFieldCell *cell1=self.cells[8];
    if (cell1.textField==textField) {
        if(strlen([textField.text UTF8String]) >= 12 && range.length != 1)
            boo=NO;
    }
    //TKTextFieldCell *cell2=self.cells[3];
    TKTextFieldCell *cell3=self.cells[6];
    if (cell3.textField==textField) {
        [self replacePhonestring:textField];
        if(strlen([textField.text UTF8String]) >= 11 && range.length != 1)
            boo=NO;
    }
    return boo;
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
    if ([cell isKindOfClass:[TKEmptyCell class]]) {
        return 110.0;
    }
    if ([cell isKindOfClass:[TKLabelCell class]]) {
        return 30.0;
    }
    return 44.0;
}
/***
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
 ***/
@end
