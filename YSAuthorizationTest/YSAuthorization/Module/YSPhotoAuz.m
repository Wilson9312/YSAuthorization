//
//  YSPhotoAuz.m
//  YSAuthorization
//
//  Created by Wilson_YS on 2017/5/9.
//  Copyright © 2017年 Guangdong Shengdijia Group Co., Ltd. All rights reserved.
//

#import "YSPhotoAuz.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation YSPhotoAuz

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.moduleName = @"照片";
    }
    return self;
}

#pragma mark - Abstract Methods

- (YSAUZStatus)status{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    switch (status) {
        case ALAuthorizationStatusNotDetermined:
            return YSAUZStatusNotDetermined;
        case ALAuthorizationStatusRestricted:
            return YSAUZStatusRestricted;
        case ALAuthorizationStatusDenied:
            return YSAUZStatusDenied;
        case ALAuthorizationStatusAuthorized:
            return YSAUZStatusAuthorized;
    }
}

- (BOOL)requestAuthorization{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        *stop = YES;
        YSDLog(@"%@ Authorized",self.moduleName);
    } failureBlock:^(NSError *error) {
        YSDLog(@"%@ Denied",self.moduleName);
    }];
    return YES;
}

@end
