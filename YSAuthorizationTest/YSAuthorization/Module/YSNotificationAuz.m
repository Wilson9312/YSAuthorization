//
//  YSNotificationAuz.m
//  YSAuthorization
//
//  Created by Wilson_YS on 2017/1/1.
//  Copyright © 2017年 Guangdong Shengdijia Group Co., Ltd. All rights reserved.
//

#import "YSNotificationAuz.h"

#define kDidRequestAuthorization @"DidRequestAuthorization"

@implementation YSNotificationAuz
@synthesize message = _message;
@synthesize requestNotiAUZType = _requestNotiAUZType;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.moduleName = @"通知";
    }
    return self;
}
#pragma mark - Abstract Methods

- (YSNotificationAuzType)requestNotiAUZType{
    if (!_requestNotiAUZType) {
        // 默认全开
        _requestNotiAUZType = YSNotificationAuzTypeAlert|YSNotificationAuzTypeBadge|YSNotificationAuzTypeSound ;
    }
    return _requestNotiAUZType;
}

- (NotiAUZType)notiAUZType{
    __weak typeof(self) weakSelf = self;
    return ^(YSNotificationAuzType notificationAUZType) {
        weakSelf.requestNotiAUZType = notificationAUZType;
        return weakSelf;
    };
}

- (YSAUZStatus)status{
    BOOL didRequestAuthorization = [[NSUserDefaults standardUserDefaults] boolForKey:kDidRequestAuthorization];
    
    if (didRequestAuthorization) {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
            /* ---= iOS8+ =--- */
            if ([UIApplication sharedApplication].isRegisteredForRemoteNotifications) {
                return YSAUZStatusAuthorized;
            } else {
                return YSAUZStatusDenied;
            }
        } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
            /* ---= <iOS8 =--- */
            if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
                return YSAUZStatusDenied;
            } else {
                return YSAUZStatusAuthorized;
            }
#else
            /* ---= iOS8+ =--- */
            return YSAUZStatusDenied;
#endif
        }
    } else {
        return YSAUZStatusNotDetermined;
    }
}

- (NSString *)message{
    return _message ? _message : [NSString stringWithFormat:@"请在iPhone的\"设置-隐私-%@\"选项中，允许\"%@\"发送通知。",self.moduleName,kAUZAppName];
}

- (BOOL)requestAuthorization{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        /* ---= iOS8+ =--- */
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:(UIUserNotificationType)self.requestNotiAUZType
                                          categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationType)self.requestNotiAUZType];
#endif
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:YES forKey:kDidRequestAuthorization];
    [ud synchronize];
    
    return YES;
}

- (void)applicationDidBecomeActive
{
    YSDLog(@"%@ Authorized",self.moduleName);
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                object:nil];
}

@end
