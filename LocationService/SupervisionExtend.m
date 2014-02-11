//
//  SupervisionExtend.m
//  LocationService
//
//  Created by aJia on 2013/12/25.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "SupervisionExtend.h"
#import "TKLabelCell.h"
#import "TKTextFieldCell.h"
#import "LoginButtons.h"
#import "Account.h"
#import "NSDate+TPCategory.h"
#import "AlertHelper.h"
#import "EditSupervisionViewController.h"
#import "IndexViewController.h"
#import "AddSupervision.h"
#import "SupervisionViewController.h"
#import "AppUI.h"
@interface SupervisionExtend ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    UITableView *_tableView;
    LoginButtons *_toolBar;
    BOOL isKeyBoardShow;
}
- (void)buttonSubmit;
- (void)buttonCancel;
- (CGRect)fieldToRect:(UITextField*)field;
- (void)replacePhonestring:(UITextField*)field;
- (void)loadingEditInfo;
@end

@implementation SupervisionExtend
- (void)dealloc{
    [super dealloc];
    [_toolBar release];
    [_tableView release];
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

    
    if (self.operateType==2) {//修改
        //加载修改信息
        [self loadingEditInfo];
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
    
    self.SysID=@"";
    
    
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
    _toolBar.cancel.frame=CGRectMake(0, 0, self.view.bounds.size.width/3, 44);
     _toolBar.submit.frame=CGRectMake(self.view.bounds.size.width/3, 0, self.view.bounds.size.width/3, 44);
    [_toolBar.submit setTitle:@"完成" forState:UIControlStateNormal];
    [_toolBar.cancel setTitle:@"上一步" forState:UIControlStateNormal];
    [_toolBar.submit addTarget:self action:@selector(buttonSubmit) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar.cancel addTarget:self action:@selector(buttonCancel) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_toolBar];
    
   
    TKLabelCell *cell1=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell1.label.text=@"信号发送频率(秒)";
    
    TKTextFieldCell *cell2=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell2.textField.placeholder=@"请输入信号发送频率";
    cell2.textField.delegate=self;
   
    
    TKLabelCell *cell3=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell3.label.text=@"SOS号";
    
    TKTextFieldCell *cell4=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell4.textField.placeholder=@"请输入SOS号";
    cell4.textField.delegate=self;
    
    
    TKLabelCell *cell5=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell5.label.text=@"监听号";
    
    TKTextFieldCell *cell6=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell6.textField.placeholder=@"请输入监听号";
    cell6.textField.delegate=self;
    
    TKLabelCell *cell7=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell7.label.text=@"亲情号";
    
    TKTextFieldCell *cell8=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell8.textField.placeholder=@"请输入亲情号1";
    cell8.textField.delegate=self;
    
    TKTextFieldCell *cell9=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell9.textField.placeholder=@"请输入亲情号2";
    cell9.textField.delegate=self;
    
    TKTextFieldCell *cell10=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell10.textField.placeholder=@"请输入亲情号3";
    cell10.textField.delegate=self;
    
    self.cells=[NSMutableArray arrayWithObjects:cell1,cell2,cell3,cell4,cell5,cell6,cell7,cell8,cell9,cell10, nil];
    
    
   
}
//获取修改信息
- (void)loadingEditInfo{
    //取得频率
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.methodName=@"getCardFrequence";
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.soapParams=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:self.DeviceCode,@"DeviceCode", nil], nil];
    //NSLog(@"soap=%@",args.soapMessage);
    ASIHTTPRequest *request1=[ServiceHelper commonSharedRequest:args];
    [request1 setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Frequence",@"name", nil]];
    [self.serviceHelper addQueue:request1];
    
    for (int i=1; i<5; i++) {
        ServiceArgs *item=[[[ServiceArgs alloc] init] autorelease];
        item.methodName=@"GetAllTelephoneSet";
        item.serviceURL=DataWebservice1;
        item.serviceNameSpace=DataNameSpace1;
        item.soapParams=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:self.DeviceCode,@"DeviceCode", nil],[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",i],@"type", nil], nil];
        ASIHTTPRequest *request=[ServiceHelper commonSharedRequest:item];
        [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"type%d",i],@"name", nil]];
        [self.serviceHelper addQueue:request];
    }

    [self.serviceHelper startQueue:nil failed:nil complete:^(NSArray *results) {
        for (ServiceResult *result in results) {
            NSString *name=[[result.request userInfo] objectForKey:@"name"];
            if ([name isEqualToString:@"Frequence"]) {
                //NSLog(@"xml=%@",result.request.responseString);
                if (result.hasSuccess) {
                    NSDictionary *dic=[result json];
                    if (dic!=nil) {
                        NSArray *source=[dic objectForKey:@"Person"];
                        if (source&&[source count]>0) {
                            TKTextFieldCell *cell=self.cells[1];
                            cell.textField.text=[[source objectAtIndex:0] objectForKey:@"Frequence"];
                            self.SysID=[[source objectAtIndex:0] objectForKey:@"SysID"];
                        }
                    }
                }
            }
            
            if ([name hasPrefix:@"type"]) {
                if (result.hasSuccess) {
                     NSDictionary *dic=[result json];
                    if (dic!=nil) {
                        NSArray *source=[dic objectForKey:@"Person"];
                        if (source&&[source count]>0&&![name isEqualToString:@"type2"]) {
                            NSDictionary *souceDic=[source objectAtIndex:0];
                            if ([[souceDic objectForKey:@"Type"] isEqualToString:@"1"]) {//1 : SOS 号码
                                TKTextFieldCell *cell=self.cells[3];
                                cell.textField.text=[souceDic objectForKey:@"Phone"];
                            }
                            if ([[souceDic objectForKey:@"Type"] isEqualToString:@"3"]) {//3: 监听号码;
                                TKTextFieldCell *cell=self.cells[5];
                                cell.textField.text=[souceDic objectForKey:@"Phone"];
                            }
                        }
                        if (source&&[source count]>0&&[name isEqualToString:@"type2"]) {
                            NSDictionary *souceDic=[source objectAtIndex:0];
                            if ([[souceDic objectForKey:@"Type"] isEqualToString:@"2"]) {//2 :亲情号码1;
                                TKTextFieldCell *cell=self.cells[7];
                                cell.textField.text=[souceDic objectForKey:@"Phone"];
                            }
                            if (source.count>=2) {
                                if ([[source[1] objectForKey:@"Type"] isEqualToString:@"2"]) {//2 :亲情号码2;
                                    TKTextFieldCell *cell=self.cells[8];
                                    cell.textField.text=[source[1] objectForKey:@"Phone"];
                                }
                            }
                            if (source.count>=3) {
                                if ([[source[2] objectForKey:@"Type"] isEqualToString:@"2"]) {//2 :亲情号码3;
                                    TKTextFieldCell *cell=self.cells[9];
                                    cell.textField.text=[source[2] objectForKey:@"Phone"];
                                }
                            }
                        }
                    }
                }
            }
        }
    }];
    
    /***
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        if (result.hasSuccess) {
            NSDictionary *dic=[result json];
            if (dic!=nil) {
                NSArray *source=[dic objectForKey:@"Person"];
                if (source&&[source count]>0) {
                    TKTextFieldCell *cell=self.cells[1];
                    cell.textField.text=[[source objectAtIndex:0] objectForKey:@"Frequence"];
                    self.SysID=[[source objectAtIndex:0] objectForKey:@"SysID"];
                }
            }
        }
    } failed:nil];
     ***/
    
       
}
//完成
- (void)buttonSubmit{
 
    Account *acc=[Account unarchiverAccount];
  
    TKTextFieldCell *cell1=self.cells[1];
    if (!cell1.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请输入信号发送频率!"];
        [cell1.textField becomeFirstResponder];
        return;
    }
    if (![cell1.textField.text isNumberString]) {
        [AlertHelper initWithTitle:@"提示" message:@"信号发送频率只能为数字!"];
        [cell1.textField becomeFirstResponder];
        return;
    }
    TKTextFieldCell *cell2=self.cells[3];
    if (!cell2.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请输入SOS号!"];
        [cell2.textField becomeFirstResponder];
        return;
    }
    TKTextFieldCell *cell3=self.cells[5];
    if (!cell3.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请输入监听号!"];
        [cell3.textField becomeFirstResponder];
        return;
    }
    if (![cell3.textField.text isNumberString]) {
        [AlertHelper initWithTitle:@"提示" message:@"监听号只能为数字!"];
        [cell3.textField becomeFirstResponder];
        return;
    }
    if(strlen([cell3.textField.text UTF8String])<11)
    {
        [AlertHelper initWithTitle:@"提示" message:@"监听号必须为11位！"];
        [cell3.textField becomeFirstResponder];
        return;
    }
    TKTextFieldCell *cell4=self.cells[7];
    TKTextFieldCell *cell5=self.cells[8];
    TKTextFieldCell *cell6=self.cells[9];
    
    if (!cell4.hasValue&&!cell5.hasValue&&!cell6.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"请至少填写一个亲情号码!"];
        [cell4.textField becomeFirstResponder];
        return;
    }
    if(cell4.hasValue&&![cell4.textField.text isNumberString])
    {
        [AlertHelper initWithTitle:@"提示" message:@"亲情号码1只能为数字!"];
        [cell4.textField becomeFirstResponder];
        return;
    }
    if (cell4.hasValue&&strlen([cell4.textField.text UTF8String])<11) {
        [AlertHelper initWithTitle:@"提示" message:@"亲情号码1必须为11位！"];
        [cell4.textField becomeFirstResponder];
        return;
    }
    if(cell5.hasValue&&![cell5.textField.text isNumberString])
    {
        [AlertHelper initWithTitle:@"提示" message:@"亲情号码2只能为数字!"];
        [cell5.textField becomeFirstResponder];
        return;
    }
    if (cell5.hasValue&&strlen([cell5.textField.text UTF8String])<11) {
        [AlertHelper initWithTitle:@"提示" message:@"亲情号码2必须为11位！"];
        [cell5.textField becomeFirstResponder];
        return;
    }
    if(cell6.hasValue&&![cell6.textField.text isNumberString])
    {
        [AlertHelper initWithTitle:@"提示" message:@"亲情号码3只能为数字!"];
        [cell6.textField becomeFirstResponder];
        return;
    }
    if (cell6.hasValue&&strlen([cell6.textField.text UTF8String])<11) {
        [AlertHelper initWithTitle:@"提示" message:@"亲情号码3必须为11位！"];
        [cell6.textField becomeFirstResponder];
        return;
    }
    [self textFieldShouldReturn:cell1.textField];
    [self textFieldShouldReturn:cell2.textField];
    [self textFieldShouldReturn:cell3.textField];
    [self textFieldShouldReturn:cell4.textField];
    [self textFieldShouldReturn:cell5.textField];
    [self textFieldShouldReturn:cell6.textField];
    //表示网络未连接
    if (![self hasNetWork]) {
        [self showErrorNetWorkNotice:nil];
        return;
    }

    NSString *affection=@"";
    if ([cell4.textField.text length]>0) {
        affection=[NSString stringWithFormat:@"%@,1",cell4.textField.text];
    }
    if ([cell5.textField.text length]>0) {
        affection=[NSString stringWithFormat:@"%@|%@,2",affection,cell5.textField.text];
    }
    if ([cell6.textField.text length]>0) {
        affection=[NSString stringWithFormat:@"%@|%@,3",affection,cell6.textField.text];
    }
    NSMutableArray *params=[NSMutableArray arrayWithCapacity:6];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell1.textField.text Trim],@"OperateValue", nil]];
    //[params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"15",@"OperateValue", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.SysID,@"SysID", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@,1",[cell2.textField.text Trim]],@"SOS_Order", nil]];//sos号码+顺序
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:affection,@"KinShip_Order", nil]];//亲情号码+顺序
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@,1",[cell3.textField.text Trim]],@"Moniter_Order", nil]];//监听号码+顺序
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[[NSDate date] stringWithFormat:@"yyyy-MM-dd HH:mm:ss"],@"CurDateTime", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:acc.WorkNo,@"CurWorkNo", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.DeviceCode,@"DeviceCode", nil]];//终端唯一ID
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",self.operateType],@"operateType", nil]];//操作类型1：新增 2：修改
    
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.serviceURL=DataWebservice1;
    args.serviceNameSpace=DataNameSpace1;
    args.methodName=@"SaveTeleAndFreqIn";
    args.soapParams=params;
    NSLog(@"soap=%@",args.soapMessage);
    NSString *memo=self.operateType==1?@"新增":@"修改";
    [self showLoadingAnimatedWithTitle:[NSString stringWithFormat:@"正在%@,请稍后...",memo]];
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        NSLog(@"xml=%@",result.request.responseString);
        BOOL boo=NO;
        if (result.hasSuccess) {
            NSDictionary *dic=(NSDictionary*)[result json];
            if (dic!=nil&&[[dic objectForKey:@"Result"] isEqualToString:@"1"]) {
                boo=YES;
                [self hideLoadingViewAnimated:^(AnimateLoadView *hideView) {
                    int row=2;
                    if ([self.navigationController.viewControllers[1] isKindOfClass:[AddSupervision class]]) {
                        row=0;
                    }
                    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:row] animated:YES];
                }];
            }
        }
        if (!boo) {
            [self hideLoadingFailedWithTitle:[NSString stringWithFormat:@"%@失败!",memo] completed:nil];
        }
        
    } failed:^(NSError *error, NSDictionary *userInfo) {
        [self hideLoadingFailedWithTitle:[NSString stringWithFormat:@"%@失败!",memo] completed:nil];
    }];
    
    
}
//上一步
- (void)buttonCancel{
    [self.navigationController popViewControllerAnimated:YES];
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
    TKTextFieldCell *cell0=self.cells[1];//信号发送频率
    if (cell0.textField==textField) {
        [self replacePhonestring:textField];
    }
    TKTextFieldCell *cell1=self.cells[3];
    TKTextFieldCell *cell2=self.cells[5];//监听号
    TKTextFieldCell *cell3=self.cells[7];
    TKTextFieldCell *cell4=self.cells[8];
    TKTextFieldCell *cell5=self.cells[9];
    if (cell1.textField==textField||cell2.textField==textField||cell3.textField==textField||cell4.textField==textField||cell5.textField==textField) {
        [self replacePhonestring:textField];
        if (cell2.textField==textField||cell3.textField==textField||cell4.textField==textField||cell5.textField==textField) {
            if(strlen([textField.text UTF8String]) >= 11 && range.length != 1)
                boo=NO;
        }
    }
    return boo;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!isKeyBoardShow) {
        isKeyBoardShow=YES;
        CGRect r=_tableView.frame;
        r.size.height-=216;
        
        CGRect r1=_toolBar.frame;
        r1.origin.y-=216;
        [UIView animateWithDuration:0.3f animations:^{
            _tableView.frame=r;
            _toolBar.frame=r1;
        }];
    }
    /***
    CGRect frame = [self fieldToRect:textField];
    int offset = frame.origin.y + 36 - (self.view.frame.size.height - 216.0);//键盘高度216
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
     ***/
}
- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    //self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (isKeyBoardShow) {
        isKeyBoardShow=NO;
        CGRect r=_tableView.frame;
        r.size.height+=216;
        
        
        CGRect r1=_toolBar.frame;
        r1.origin.y+=216;
        [UIView animateWithDuration:0.3f animations:^{
            _tableView.frame=r;
            _toolBar.frame=r1;
        }];
    }
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark table source & delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.cells count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=self.cells[indexPath.row];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}
@end
