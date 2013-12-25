//
//  SupervisionPerson.m
//  LocationService
//
//  Created by aJia on 2013/12/24.
//  Copyright (c) 2013年 lz. All rights reserved.
//

#import "SupervisionPerson.h"

@implementation SupervisionPerson
-(id)copyWithZone:(NSZone *)zone
{
    SupervisionPerson *copy = [[[self class] allocWithZone: zone] init];
    copy.ID = [self.ID copyWithZone:zone];
    copy.Name = [self.Name copyWithZone:zone];
    copy.isOnline = [self.isOnline copyWithZone:zone];
    copy.GPSStatus = [self.GPSStatus copyWithZone:zone];
    copy.Power = [self.Power copyWithZone:zone];
    copy.Photo = [self.Photo copyWithZone:zone];
    copy.Password = [self.Password copyWithZone:zone];
    copy.IMEI = [self.IMEI copyWithZone:zone];
    copy.DeviceCode = [self.DeviceCode copyWithZone:zone];
    copy.Latitude = [self.Latitude copyWithZone:zone];
    copy.Longitude = [self.Longitude copyWithZone:zone];
    copy.Address = [self.Address copyWithZone:zone];
    copy.angle = [self.angle copyWithZone:zone];
    copy.speed = [self.speed copyWithZone:zone];
    copy.extend = [self.extend copyWithZone:zone];
    copy.oil = [self.oil copyWithZone:zone];
    copy.temper = [self.temper copyWithZone:zone];
    copy.DoorStatus = [self.DoorStatus copyWithZone:zone];
    copy.Phone = [self.Phone copyWithZone:zone];
    copy.OperatingMode = [self.OperatingMode copyWithZone:zone];
    //[newFract setTo:a over:b];
    
    return copy;
}
@end
