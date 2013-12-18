//
//  DynamicLoginViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/17.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "DynamicLoginViewController.h"
#import "TKLabelCell.h"
#import "TKTextFieldCell.h"
#import "TKDynamicPasswordCell.h"
#import "TKRegisterCheckCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+TPCategory.h"
#import "TKLoginButtonCell.h"
#import "RegisterCheck.h"
#import "AlertHelper.h"
@interface DynamicLoginViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
}
- (void)buttonRegister;
- (void)buttonDynamicPwdClick;
@end

@implementation DynamicLoginViewController
- (void)dealloc{
    [super dealloc];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView=[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.bounces=NO;
    _tableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_tableView];
    
    TKLabelCell *cell1=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell1.label.text=@"手机号码";
    
    TKTextFieldCell *cell2=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell2.textField.placeholder=@"请输入手机号";
    cell2.textField.layer.borderWidth=2.0;
    cell2.textField.layer.cornerRadius=5.0;
    cell2.textField.layer.borderColor=[UIColor colorFromHexRGB:@"4a7ebb"].CGColor;
    cell2.textField.textColor=[UIColor colorFromHexRGB:@"4a7ebb"];
    
    TKLabelCell *cell3=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell3.label.text=@"密      码";
    
    TKDynamicPasswordCell *cell4=[[[TKDynamicPasswordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell4.textField.placeholder=@"动态密码";
    cell4.textField.layer.borderWidth=2.0;
    cell4.textField.layer.cornerRadius=5.0;
    cell4.textField.layer.borderColor=[UIColor colorFromHexRGB:@"4a7ebb"].CGColor;
    cell4.textField.textColor=[UIColor colorFromHexRGB:@"4a7ebb"];
    [cell4.button addTarget:self action:@selector(buttonDynamicPwdClick) forControlEvents:UIControlEventTouchUpInside];
    
    TKLoginButtonCell *cell5=[[[TKLoginButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    
    self.cells=[NSMutableArray arrayWithObjects:cell1,cell2,cell3,cell4,cell5, nil];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//动态密码
- (void)buttonDynamicPwdClick{
    TKDynamicPasswordCell *cell1=self.cells[3];
    
   
    
    
    TKTextFieldCell *cell=self.cells[1];
    if (!cell.hasValue) {
        [AlertHelper initWithTitle:@"提示" message:@"手机号码不为空!"];
        return;
    }else{
        if (![cell.textField.text isNumberString]) {
            [AlertHelper initWithTitle:@"提示" message:@"手机号码只能为数字!"];
            return;
        }
    }
    if (!self.hasNetWork) {
        [self showErrorNetWorkNotice:nil];
        return;
    }
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.methodName=@"GetDynamicCode";
    args.soapParams=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:cell.textField.text,@"mobileNum", nil], nil];
    [self.serviceHelper asynService:args success:^(ServiceResult *result) {
        
        NSString *xml=[result.xmlString stringByReplacingOccurrencesOfString:result.xmlnsAttr withString:@""];
        [result.xmlParse setDataSource:xml];
        XmlNode *node=[result.xmlParse soapXmlSelectSingleNode:@"//GetDynamicCodeResult"];
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[node.InnerXml dataUsingEncoding:NSUTF8StringEncoding] options:1 error:nil];
        if ([dic objectForKey:@"code"]) {//表示成功
            NSString *time1=[dic objectForKey:@"codeTime"];
            [cell1 startTimerWithTime:time1];
        }
        
        
    } failed:^(NSError *error, NSDictionary *userInfo) {
        NSLog(@"error=%@\n",error.description);
    }];
}
//注册
- (void)buttonRegister{
    
}
#pragma mark UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.cells count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=self.cells[indexPath.row];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 45;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *bgView=[[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 45)] autorelease];
    bgView.backgroundColor=[UIColor clearColor];
    RegisterCheck *check=[[[RegisterCheck alloc] initWithFrame:CGRectMake(0, 15, self.view.bounds.size.width-20, 30)] autorelease];
    [check.registerButton addTarget:self action:@selector(buttonRegister) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:check];
    
    return bgView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id cell=self.cells[indexPath.row];
    if ([cell isKindOfClass:[TKLabelCell class]]) {
        return 30.0;
    }
    if ([cell isKindOfClass:[TKLoginButtonCell class]]) {
        return 45.0;
    }
    return 44.0;
}@end
