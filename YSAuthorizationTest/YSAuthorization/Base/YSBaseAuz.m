//
//  YSBaseAuz.m
//  YSAuthorization
//
//  Created by Wilson_YS on 2017/5/7.
//  Copyright © 2017年 Guangdong Shengdijia Group Co., Ltd. All rights reserved.
//

#import "YSBaseAuz.h"

#define kTitle      @"提示"
#define kCancel     @"暂不"
#define kSetting    @"设置"

#define kDenyInterval 60.0/60.0/24.0
#define kDenyTimeUserDefaultKey [NSString stringWithFormat:@"%@DenyTime",NSStringFromClass([self class])]

#define AbstractMethodNotImplemented() \
@throw [NSException exceptionWithName:NSInternalInconsistencyException \
reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)] \
userInfo:nil]

@interface YSBaseAuz ()
@property (nonatomic, copy) AlertCancelAciton alertCancelAciton;
@end

@implementation YSBaseAuz
@synthesize alertCancelAciton = _alertCancelAciton;

- (void)setAuthorizing:(BOOL)authorizing{
    if (authorizing) {
        YSDLog(@"%@ request Authorization",_moduleName);
    }
    _authorizing = authorizing;
}

- (BOOL)enabled{
    if (self.status==YSAUZStatusAuthorizedAlways || self.status==YSAUZStatusAuthorizedWhenInUse || self.status==YSAUZStatusAuthorized) {
        YSDLog(@"%@ enabled",_moduleName);
        return YES;
    }else{
        YSDLog(@"%@ disabled",_moduleName);
        return NO;
    }
}

#pragma mark - DenyTime & ForceDeny
/** 调用后，不强制要求授权 */
- (Unforce)unforce{
    __weak typeof(self) weakSelf = self;
    return ^() {
        weakSelf.unforced = YES;
        YSDLog(@"%@ unforced Authorization",_moduleName);
        return weakSelf;
    };
}

- (void)denyTimeRecord{
    NSDate *date = [NSDate date];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:date forKey:kDenyTimeUserDefaultKey];
    [ud synchronize];
    YSDLog(@"%@ Record %@ : %@",_moduleName,kDenyTimeUserDefaultKey,date);
}

- (void)denyTimeClear{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:nil forKey:kDenyTimeUserDefaultKey];
    [ud synchronize];
    YSDLog(@"%@ Clear %@ : nil",_moduleName,kDenyTimeUserDefaultKey);
}

- (BOOL)denyOverdueCheck{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDate *date = [ud objectForKey:kDenyTimeUserDefaultKey];
    YSDLog(@"%@ denyTime %@ : %@",_moduleName,kDenyTimeUserDefaultKey,date);
    if (!date) {
        YSDLog(@"%@ denyTime Overdue",_moduleName);
        return YES;
    }
    double interval = [[NSDate date] timeIntervalSinceDate:date];
    BOOL overdue = interval/kDenyInterval >= 1;
    if (overdue) {
        YSDLog(@"%@ denyTime Overdue",_moduleName);
        [self denyTimeClear];
    }else {
        YSDLog(@"%@ unforced Authorization",_moduleName);
    }
    return overdue;
}


/**
 跳转到系统授权界面
 */
+ (void)openSettingsURL{
    YSDLog(@"Open Settings");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    
    /*
    if(iOSv10){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }else{
        NSURL *url ;//= [NSURL URLWithString:[[self class] getPrefsURL]];
        if (url && [[UIApplication sharedApplication] canOpenURL:url])
        {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
     */
}

#pragma mark - Edit Alert

- (NSString *)title{
    return _title ? _title : kTitle;
}

- (NSString *)cancel{
    return _cancel ? _cancel : kCancel;
}

- (NSString *)setting{
    return _setting ? _setting : kSetting;
}

- (UIViewController *)container{
    if (!_container) {
        _container = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    return _container;
}

- (BOOL)containerDidLoad{
    _containerDidLoad =
    [[UIApplication sharedApplication].keyWindow.rootViewController.childViewControllers containsObject:_container] ||
    [UIApplication sharedApplication].keyWindow.rootViewController == _container;
    return _containerDidLoad;
}

- (AlertEditor)alertEditor{
    __weak typeof(self) weakSelf = self;
    return ^(NSString *title, NSString *message, NSString *cancel, NSString *setting) {
        weakSelf.title = title;
        weakSelf.message = message;
        weakSelf.cancel = cancel;
        weakSelf.setting = setting;
        return weakSelf;
    };
}

- (UIAlertController *)generateAlert{
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:self.title
                                        message:self.message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction =
    [UIAlertAction actionWithTitle:self.cancel
                             style:UIAlertActionStyleCancel
                           handler:^(UIAlertAction * _Nonnull action)
    {
        [self denyTimeRecord];
        if (self.alertCancelAciton) {
            self.alertCancelAciton();
        }
        self.authorizing = NO;
    }];
    UIAlertAction *settingAction =
    [UIAlertAction actionWithTitle:self.setting
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * _Nonnull action)
     {
         [YSBaseAuz openSettingsURL];
         self.authorizing = NO;
     }];
    [alert addAction:cancelAction];
    [alert addAction:settingAction];
    return alert;
}

- (StartRequestAuthorization)startRequestAuthorization{
    __weak typeof(self) weakSelf = self;
    return ^(UIViewController *container) {
        weakSelf.container = container;
        weakSelf.alertCancelAciton = nil;
        [weakSelf logicOfRequestAuthorization];
    };
}

- (StartRequestAuthorizationWithAction)startRequestAuthorizationWithAction{
    __weak typeof(self) weakSelf = self;
    return ^(UIViewController *container, AlertCancelAciton alertCancelAciton) {
        weakSelf.container = container;
        weakSelf.alertCancelAciton = alertCancelAciton;
        [weakSelf logicOfRequestAuthorization];
    };
}

#pragma mark - Logic Of Request Authorization
/**
 开始请求授权：直接请求权限 或 引导用户开启权限
 */
- (void)logicOfRequestAuthorization{
    if (self.authorizing) {
        return;
    }else{
        self.authorizing = YES;
    }
    if (self.status == YSAUZStatusNotDetermined) {
        [self requestAuthorization];
    } else if(self.status == YSAUZStatusDenied){
        if (_unforced && ![self denyOverdueCheck]) {
            _unforced = NO;
            return;
        }
        UIAlertController *alert = [self generateAlert];
        if (self.containerDidLoad) {
            // 必须在viewController加载完后，才能正常present。(可以在viewDidload中延迟调用解决)
            [self.container presentViewController:alert animated:YES completion:nil];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.container presentViewController:alert animated:YES completion:nil];
            });
        }
    }else {
        YSDLog(@"%@ Authorized",_moduleName);
        self.authorizing = NO;
    }
}

#pragma mark - Abstract Methods
- (YSAUZStatus)status{
    AbstractMethodNotImplemented();
}
- (NSString *)message{
    return _message ? _message : kAUZMessage(self.moduleName);
}
- (BOOL)requestAuthorization{
    if (!self.requestAuthorizationAlways) {
        return self.requestAuthorizationWhenInUse;
    }else{
        return YES;
    }
}
- (BOOL)requestAuthorizationAlways{
    AbstractMethodNotImplemented();
}
- (BOOL)requestAuthorizationWhenInUse{
    AbstractMethodNotImplemented();
}

@end
