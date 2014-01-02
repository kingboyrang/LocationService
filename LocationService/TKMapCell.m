//
//  TKMapCell.m
//  LocationService
//
//  Created by aJia on 2013/12/30.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "TKMapCell.h"
#import "UIDevice+TPCategory.h"
@interface TKMapCell (){
    BOOL isFinished;
}
-(NSString *)getDataSizeString:(int) nSize;
@end

@implementation TKMapCell
- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if(!(self=[super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    _labTitle=[[UILabel alloc] initWithFrame:CGRectZero];
    _labTitle.textColor=[UIColor blackColor];
    _labTitle.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    _labTitle.backgroundColor=[UIColor clearColor];
    [self.contentView addSubview:_labTitle];
    
    _labprocess=[[UILabel alloc] initWithFrame:CGRectZero];
    _labprocess.textColor=[UIColor blackColor];
    _labprocess.font=[UIFont fontWithName:DeviceFontName size:DeviceFontSize];
    _labprocess.backgroundColor=[UIColor clearColor];
    _labprocess.textAlignment=NSTextAlignmentRight;
    [self.contentView addSubview:_labprocess];
    
    _progressView=[[UIProgressView alloc] initWithFrame:CGRectZero];
    _progressView.progressViewStyle=UIProgressViewStyleDefault;
    [self.contentView addSubview:_progressView];
    

    
    
    isFinished=NO;
    
	return self;
}

- (id) initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	return [self initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:reuseIdentifier];
}

- (void)setDataSource:(BMKOLSearchRecord*)entity{
    self.Entity=entity;
    NSString *title=entity.cityName;
    //转换包大小
    NSString*packSize = [self getDataSizeString:entity.size];
    _labTitle.text=[NSString stringWithFormat:@"%@(%@)",title,packSize];
    
    if ([_labprocess.text length]==0) {
        _labprocess.text=@"等待下载 0%";
    }
}
- (void)updateProgressInfo:(BMKOLUpdateElement*)updateInfo{
    if (self.isPause) {
        self.isPause=NO;
    }
    
    _labprocess.text=[NSString stringWithFormat:@"正在下载 %d%%",updateInfo.ratio];
    [_progressView setProgress:updateInfo.ratio animated:YES];
    if (updateInfo.status==4) {//表示下载完成
        isFinished=YES;
        if (self.controlers&&[self.controlers respondsToSelector:@selector(finishedDownloadWithRow:element:)]) {
            [self.controlers performSelector:@selector(finishedDownloadWithRow:element:) withObject:self withObject:updateInfo];
        }
    }
}
#pragma mark 包大小转换工具类（将包大小转换成合适单位）
-(NSString *)getDataSizeString:(int) nSize
{
	NSString *string = nil;
	if (nSize<1024)
	{
		string = [NSString stringWithFormat:@"%dB", nSize];
	}
	else if (nSize<1048576)
	{
		string = [NSString stringWithFormat:@"%dK", (nSize/1024)];
	}
	else if (nSize<1073741824)
	{
		if ((nSize%1048576)== 0 )
        {
			string = [NSString stringWithFormat:@"%dM", nSize/1048576];
        }
		else
        {
            int decimal = 0; //小数
            NSString* decimalStr = nil;
            decimal = (nSize%1048576);
            decimal /= 1024;
            
            if (decimal < 10)
            {
                decimalStr = [NSString stringWithFormat:@"%d", 0];
            }
            else if (decimal >= 10 && decimal < 100)
            {
                int i = decimal / 10;
                if (i >= 5)
                {
                    decimalStr = [NSString stringWithFormat:@"%d", 1];
                }
                else
                {
                    decimalStr = [NSString stringWithFormat:@"%d", 0];
                }
                
            }
            else if (decimal >= 100 && decimal < 1024)
            {
                int i = decimal / 100;
                if (i >= 5)
                {
                    decimal = i + 1;
                    
                    if (decimal >= 10)
                    {
                        decimal = 9;
                    }
                    
                    decimalStr = [NSString stringWithFormat:@"%d", decimal];
                }
                else
                {
                    decimalStr = [NSString stringWithFormat:@"%d", i];
                }
            }
            
            if (decimalStr == nil || [decimalStr isEqualToString:@""])
            {
                string = [NSString stringWithFormat:@"%dMss", nSize/1048576];
            }
            else
            {
                string = [NSString stringWithFormat:@"%d.%@M", nSize/1048576, decimalStr];
            }
        }
	}
	else	// >1G
	{
		string = [NSString stringWithFormat:@"%dG", nSize/1073741824];
	}
	
	return string;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    CGRect r = CGRectInset(self.contentView.bounds, 10, 5);
    r.size.width=r.size.width/2+10;
    r.size.height=20;
    _labTitle.frame=r;
    
    r.size.width=100;
    r.origin.x=self.frame.size.width-10-100;
    _labprocess.frame=r;
    
    
    r=CGRectInset(self.contentView.bounds, 10, 5);
    r.origin.y=_labTitle.frame.origin.y+_labTitle.frame.size.height+2;
    r.size.height=5;
    _progressView.frame=r;
}
@end
