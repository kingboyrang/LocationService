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
@interface RegisterViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
}
- (void)backClick;
@end

@implementation RegisterViewController
- (void)dealloc{
    //[UITableView release];
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
    
    
    UIButton *btn=[UIButton backButtonTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    r=btn.frame;
    r.origin.x=5;
    r.origin.y=(image.size.height-r.size.height)/2;
    btn.frame=r;
    [self.view addSubview:btn];
    
    
    r=self.view.bounds;
    r.origin.y=image.size.height;
    r.size.height-=image.size.height;
    
    _tableView=[[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor=[UIColor clearColor];
    _tableView.bounces=NO;
    _tableView.autoresizesSubviews=YES;
    _tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_tableView];
    
    
    TKLabelCell *cell1=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell1.label.text=@"帐号";
    
    TKTextFieldCell *cell2=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell2.textField.placeholder=@"请输入帐号";
    
    TKLabelCell *cell3=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell3.label.text=@"妮称";
    
    TKTextFieldCell *cell4=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell4.textField.placeholder=@"请输入妮称";
    
    TKLabelCell *cell5=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell5.label.text=@"手机号码";
    
    TKTextFieldCell *cell6=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell6.textField.placeholder=@"请输入手机号码";
    
    TKLabelCell *cell7=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell7.label.text=@"密码";
    
    TKTextFieldCell *cell8=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell8.textField.placeholder=@"请输入密码";
    cell8.textField.secureTextEntry=YES;
    
    TKLabelCell *cell9=[[[TKLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell9.label.text=@"确认密码";
    
    TKTextFieldCell *cell10=[[[TKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell10.textField.placeholder=@"请输入确认密码";
    cell10.textField.secureTextEntry=YES;

    self.cells=[NSMutableArray arrayWithObjects:cell1,cell2,cell3,cell4,cell5,cell6,cell7,cell8,cell9,cell10, nil];

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
