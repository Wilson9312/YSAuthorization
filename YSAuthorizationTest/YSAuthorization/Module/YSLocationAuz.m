//
//  YSLocationAuz.m
//  YSAuthorization
//
//  Created by Wilson_YS on 2017/5/7.
//  Copyright © 2017年 Guangdong Shengdijia Group Co., Ltd. All rights reserved.
//

#import "YSLocationAuz.h"
#import <CoreLocation/CLLocationManager.h>

@interface YSLocationManager : CLLocationManager
+ (CLLocationManager *)locationManager;
@end

@implementation YSLocationManager
static CLLocationManager *_locationManager;
+ (CLLocationManager *)locationManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _locationManager = [[CLLocationManager alloc] init];
    });
    return _locationManager;
}
@end

@interface YSLocationAuz () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation YSLocationAuz

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.moduleName = @"位置";
    }
    return self;
}

#pragma mark - Abstract Methods
- (YSAUZStatus)status{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            return YSAUZStatusNotDetermined;
            break;
        case kCLAuthorizationStatusRestricted:
            return YSAUZStatusRestricted;
            break;
        case kCLAuthorizationStatusDenied:
            return YSAUZStatusDenied;
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            return YSAUZStatusAuthorizedAlways;
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return YSAUZStatusAuthorizedWhenInUse;
            break;
        default:
            return YSAUZStatusAuthorized;
            break;
    }
}

- (BOOL)requestAuthorizationAlways{
    NSString *locationAlwaysUsageDescription = [[NSBundle mainBundle].infoDictionary valueForKey:@"NSLocationAlwaysUsageDescription"];
    if (locationAlwaysUsageDescription) {
        [self.locationManager requestAlwaysAuthorization];
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)requestAuthorizationWhenInUse{
    NSString *locationWhenInUseUsageDescription = [[NSBundle mainBundle].infoDictionary valueForKey:@"NSLocationWhenInUseUsageDescription"];
    if(locationWhenInUseUsageDescription) {
        [self.locationManager requestWhenInUseAuthorization];
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - CLLocationManager
- (CLLocationManager *)locationManager{
    if (!_locationManager) {
        // 注意啦，locationManager若被提前释放，系统默认请求权限的弹框就会出现闪现的情况。
        // 所以这里用单例来保证不被提前释放。
        _locationManager = [YSLocationManager locationManager];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    self.authorizing = NO;
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        YSDLog(@"%@ AuthorizedAlways",self.moduleName);
        [self denyTimeClear];
    }else if (status == kCLAuthorizationStatusAuthorizedWhenInUse){
        YSDLog(@"%@ AuthorizedWhenInUse",self.moduleName);
        [self denyTimeClear];
    }else if (status == kCLAuthorizationStatusDenied){
        YSDLog(@"%@ Denied",self.moduleName);
        [self denyTimeRecord];
    }
}

@end
