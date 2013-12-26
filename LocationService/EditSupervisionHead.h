//
//  EditSupervisionHead.h
//  LocationService
//
//  Created by aJia on 2013/12/25.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SupervisionPerson.h"
#import "NLImageCropperView.h"
@interface EditSupervisionHead : BasicViewController{
     NLImageCropperView* _imageCropper;
}
@property(nonatomic,strong) SupervisionPerson *Entity;
@property (nonatomic, strong) UIImageView *preview;

- (void)finishedImage:(UIImage*)image;
@end
