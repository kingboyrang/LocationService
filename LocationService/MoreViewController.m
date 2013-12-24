//
//  MoreViewController.m
//  LocationService
//
//  Created by aJia on 2013/12/23.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "MoreViewController.h"
#import "MoreCell.h"
#import "EditPwdViewController.h"
#import "AlertHelper.h"
#import "LoginViewController.h"
#import "UserInfoViewController.h"
#import "Account.h"
#import "BasicNavigationController.h"
#import "SupervisionViewController.h"
@interface MoreViewController ()

@end

@implementation MoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   [self.navBarView setNavBarTitle:@"应用中心"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	CGRect rect=self.view.bounds;
    rect.size.height-=TabHeight+44;
    rect.origin.y=44;
    UICollectionViewFlowLayout *flowlayout=[[UICollectionViewFlowLayout alloc] init];
    CGFloat h=120;
    flowlayout.itemSize=CGSizeMake(DeviceWidth/3.0, h);
    flowlayout.scrollDirection=UICollectionViewScrollDirectionVertical;
    flowlayout.sectionInset=UIEdgeInsetsMake(10, 0, 5, 0);
    flowlayout.minimumLineSpacing=0.0;
    flowlayout.minimumInteritemSpacing=0.0;
    _collectionView=[[UICollectionView alloc] initWithFrame:rect collectionViewLayout:flowlayout];
    _collectionView.backgroundColor=[UIColor clearColor];
    _collectionView.dataSource=self;
    _collectionView.delegate=self;
    _collectionView.bounces=NO;
    
    
    _collectionView.showsVerticalScrollIndicator=NO;
    //_collectionView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [_collectionView setUserInteractionEnabled:YES];
    
    [_collectionView registerClass:[MoreCell class] forCellWithReuseIdentifier:@"moreCell"];
    [self.view addSubview:_collectionView];
    [flowlayout release];
    
    NSMutableArray *source1=[NSMutableArray array];
    NSString *n=@"";
    for (int i=6; i<12; i++) {
        n=i<10?[NSString stringWithFormat:@"0%d",i]:[NSString stringWithFormat:@"%d",i];
        [source1 addObject:[NSString stringWithFormat:@"ico%@.png",n]];
    }
    self.sourceData=source1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.sourceData count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *path = [self.sourceData objectAtIndex:indexPath.row];
    static NSString *cellIdentifier = @"moreCell";
    MoreCell *cell = (MoreCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell.imageView setImage:[UIImage imageNamed:path]];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        SupervisionViewController *edit=[[SupervisionViewController alloc] init];
        [self.navigationController pushViewController:edit animated:YES];
        [edit release];
    }
    if (indexPath.row==3) {
        UserInfoViewController *edit=[[UserInfoViewController alloc] init];
        [self.navigationController pushViewController:edit animated:YES];
        [edit release];
    }
    if (indexPath.row==4) {
        EditPwdViewController *edit=[[EditPwdViewController alloc] init];
        [self.navigationController pushViewController:edit animated:YES];
        [edit release];
    }
    if (indexPath.row==5) {
        [AlertHelper initWithTitle:@"提示" message:@"确认注销?" cancelTitle:@"取消" cancelAction:nil confirmTitle:@"确认" confirmAction:^{
            [Account closed];
            LoginViewController *login=[[[LoginViewController alloc] init] autorelease];
            BasicNavigationController *nav=[[[BasicNavigationController alloc] initWithRootViewController:login] autorelease];
            [self presentViewController:nav animated:YES completion:nil];
        }];
    }
}
@end