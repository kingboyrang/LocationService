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
#import "TKRegisterCheckCell.h"
#import "UIColor+TPCategory.h"
#import "RegisterCheck.h"
#import "TKLoginButtonCell.h"
#import "TKEmptyCell.h"
#import "RegisterViewController.h"
@interface GeneralLoginViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
}
- (void)buttonRegister;
@end

@implementation GeneralLoginViewController
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
    _tableView.separatorColor=[UIColor clearColor];
    _tableView.bounces=NO;
    //_tableView.backgroundView = [[UIView alloc] init];
    //_tableView.backgroundColor = [UIColor colorFromHexRGB:@"f5f5f5"];
    [self.view addSubview:_tableView];
    
    TKLabelCell *cell1=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell1.label.text=@"帐号";
    
    TKTextFieldCell *cell2=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell2.textField.placeholder=@"请输入帐号/手机号";
    cell2.textField.layer.borderWidth=2.0;
    cell2.textField.layer.cornerRadius=5.0;
    cell2.textField.layer.borderColor=[UIColor colorFromHexRGB:@"4a7ebb"].CGColor;
    cell2.textField.textColor=[UIColor colorFromHexRGB:@"4a7ebb"];
    
    TKLabelCell *cell3=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell3.label.text=@"密码";
    
    TKTextFieldCell *cell4=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell4.textField.placeholder=@"请输入密码";
    cell4.textField.layer.borderWidth=2.0;
    cell4.textField.layer.cornerRadius=5.0;
    cell4.textField.layer.borderColor=[UIColor colorFromHexRGB:@"4a7ebb"].CGColor;
    cell4.textField.textColor=[UIColor colorFromHexRGB:@"4a7ebb"];
    cell4.textField.secureTextEntry=YES;
    
    
    TKLoginButtonCell *cell5=[[[TKLoginButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    
    self.cells=[NSMutableArray arrayWithObjects:cell1,cell2,cell3,cell4,cell5, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//注册
- (void)buttonRegister{
    RegisterViewController *controller=[[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    [self presentViewController:controller animated:YES completion:nil];
    [controller release];
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
}
@end
