//
//  RangeWeekView.m
//  LocationService
//
//  Created by aJia on 2014/1/6.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import "RangeWeekView.h"
#import "TKAreaRangeCell.h"
@implementation RangeWeekView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.bounces=NO;
        [self addSubview:_tableView];
        
        TKAreaRangeCell *cell1=[[TKAreaRangeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell1.deleteButton.hidden=YES;
        [cell1.button addTarget:self action:@selector(buttonAddRowClick:) forControlEvents:UIControlEventTouchUpInside];
        self.cells=[NSMutableArray arrayWithObjects:cell1, nil];
    }
    return self;
}
//新增行
- (void)buttonAddRowClick:(id)sender{
    TKAreaRangeCell *cell1=[[TKAreaRangeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell1.button.hidden=YES;
    [cell1.deleteButton addTarget:self action:@selector(buttonDeleteRowClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cells addObject:cell1];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:self.cells.count-1 inSection:0];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    [_tableView endUpdates];
    
    CGRect r=self.frame;
    r.size.height+=44;
    self.frame=r;
}
//删除行
- (void)buttonDeleteRowClick:(id)sender{
    UIButton *button=(UIButton*)sender;
    id v=[button superview];
    while (![v isKindOfClass:[UITableViewCell class]]) {
        v=[v superview];
    }
    UITableViewCell *cell=(UITableViewCell*)v;
    NSIndexPath *indexPath=[_tableView indexPathForCell:cell];
    [self.cells removeObjectAtIndex:indexPath.row];
    [_tableView beginUpdates];
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    [_tableView endUpdates];
    
    CGRect r=self.frame;
    r.size.height-=44;
    self.frame=r;
}
#pragma mark table source & delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.cells count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=self.cells[indexPath.row];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}
@end
