//
//  UserInfoViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/23.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "UserInfoViewController.h"
#import "LoginButtons.h"
#import "TKLabelCell.h"
#import "TKTextFieldCell.h"
#import "Account.h"
@interface UserInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    UITableView *_tableView;
    LoginButtons *_buttons;
    
}
-(void)buttonCancel;
-(void)buttonSubmit;
- (void)replacePhonestring;
@end

@implementation UserInfoViewController

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
    [self.navBarView setNavBarTitle:@"个人信息"];
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
    [self.view addSubview:_tableView];
    
    Account *acc=[Account unarchiverAccount];
    
    TKLabelCell *cell1=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell1.label.text=@"帐号";
    
    TKTextFieldCell *cell2=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell2.textField.layer.borderWidth=2.0;
    cell2.textField.layer.cornerRadius=5.0;
    cell2.textField.layer.borderColor=[UIColor colorFromHexRGB:@"4a7ebb"].CGColor;
    cell2.textField.textColor=[UIColor colorFromHexRGB:@"4a7ebb"];
    cell2.textField.backgroundColor=[UIColor grayColor];
    cell2.textField.enabled=NO;
    cell2.textField.text=acc.UserId;
    
    TKLabelCell *cell3=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell3.label.text=@"手机号码";
    
    TKTextFieldCell *cell4=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell4.textField.layer.borderWidth=2.0;
    cell4.textField.layer.cornerRadius=5.0;
    cell4.textField.layer.borderColor=[UIColor colorFromHexRGB:@"4a7ebb"].CGColor;
    cell4.textField.textColor=[UIColor colorFromHexRGB:@"4a7ebb"];
    cell4.textField.text=acc.Phone;
    cell4.textField.delegate=self;
    
    TKLabelCell *cell5=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell5.label.text=@"妮称";
    
    TKTextFieldCell *cell6=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell6.textField.layer.borderWidth=2.0;
    cell6.textField.layer.cornerRadius=5.0;
    cell6.textField.layer.borderColor=[UIColor colorFromHexRGB:@"4a7ebb"].CGColor;
    cell6.textField.textColor=[UIColor colorFromHexRGB:@"4a7ebb"];
    cell6.textField.text=acc.Name;
    cell6.textField.delegate=self;
    
    self.cells=[NSMutableArray arrayWithObjects:cell1,cell2,cell3,cell4,cell5,cell6, nil];
    
    _buttons=[[LoginButtons alloc] initWithFrame:CGRectMake(0,_tableView.frame.origin.y+_tableView.frame.size.height, self.view.bounds.size.width, 44)];
    [_buttons.submit addTarget:self action:@selector(buttonSubmit) forControlEvents:UIControlEventTouchUpInside];
    [_buttons.cancel addTarget:self action:@selector(buttonCancel) forControlEvents:UIControlEventTouchUpInside];
    _buttons.submit.enabled=NO;
    [_buttons.submit setTitle:@"完成" forState:UIControlStateNormal];
    _buttons.submit.enabled=YES;
    [self.view addSubview:_buttons];
    
    
	
}
- (void)replacePhonestring{
    NSRegularExpression *regular;
    regular = [[NSRegularExpression alloc] initWithPattern:@"[^0-9]+"
                                                   options:NSRegularExpressionCaseInsensitive
                                                     error:nil];
    TKTextFieldCell *cell1=self.cells[3];
    NSString *str=[cell1.textField.text Trim];
    cell1.textField.text = [regular stringByReplacingMatchesInString:str options:NSRegularExpressionCaseInsensitive  range:NSMakeRange(0, [str length]) withTemplate:@""];
}
//取消
- (void)buttonCancel{
    Account *acc=[Account unarchiverAccount];
    TKTextFieldCell *cell1=self.cells[3];
    TKTextFieldCell *cell2=self.cells[5];
    cell1.textField.text=acc.Phone;
    cell2.textField.text=acc.Name;
}
//提交
- (void)buttonSubmit{
    TKTextFieldCell *cell1=self.cells[3];
    TKTextFieldCell *cell2=self.cells[5];
     Account *acc=[Account unarchiverAccount];
    
    NSMutableArray *params=[NSMutableArray arrayWithCapacity:2];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:acc.WorkNo,@"WorkNo", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell2.textField.text Trim],@"LOCALNAME", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:[cell1.textField.text Trim],@"Phone", nil]];
    
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.methodName=@"UpdateUserInfo";
    args.soapParams=params;
    [self showLoadingAnimatedWithTitle:@"正在更新个人信息,请稍后..."];
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        BOOL boo=NO;
        if (result.hasSuccess) {
            XmlNode *node=[result methodNode];
            NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[node.InnerText dataUsingEncoding:NSUTF8StringEncoding] options:1 error:nil];
            if ([[dic objectForKey:@"Result"] isEqualToString:@"1"]) {
                boo=YES;
            }
        }
        if (boo) {
            [self hideLoadingViewAnimated:^(AnimateLoadView *hideView) {
                [Account updateInfo:[cell1.textField.text Trim] nick:[cell2.textField.text Trim]];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }else{
            [self hideLoadingFailedWithTitle:@"个人信息更新失败!" completed:nil];
        }
    } failed:^(NSError *error, NSDictionary *userInfo) {
        [self hideLoadingFailedWithTitle:@"个人信息更新失败!" completed:nil];
    }];
    
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
    TKTextFieldCell *cell1=self.cells[3];
    if (cell1.textField==textField) {
        [self replacePhonestring];
        if(strlen([textField.text UTF8String]) >= 11 && range.length != 1)
            boo=NO;
    }
    TKTextFieldCell *cell2=self.cells[5];
    if ([[cell1.textField.text Trim] length]==0||[[cell2.textField.text Trim] length]==0) {
        _buttons.submit.enabled=NO;
    }else{
        _buttons.submit.enabled=YES;
    }
    return boo;
}
- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    TKTextFieldCell *cell1=self.cells[3];
    TKTextFieldCell *cell2=self.cells[5];
    if ([[cell1.textField.text Trim] length]==0||[[cell2.textField.text Trim] length]==0) {
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