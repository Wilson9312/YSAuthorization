//
//  YSBaseAuz.h
//  YSAuthorization
//
//  Created by Wilson_YS on 2017/5/7.
//  Copyright © 2017年 Guangdong Shengdijia Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define iOS_V               [[[UIDevice currentDevice] systemVersion] floatValue]
#define iOSv10              (iOS_V >= 10.0)
#define iOSv8                (iOS_V >= 8.0)

#define kAUZAppDisplayName  [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"]
#define kAUZAppName         kAUZAppDisplayName?kAUZAppDisplayName:[[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"]
#define kAUZMessage(event)  [NSString stringWithFormat:@"请在iPhone的\"设置-隐私-%@\"选项中，允许\"%@\"访问您的%@。",event,kAUZAppName,event]

//替换NSLog来使用，debug模式下可以打印
#ifdef DEBUG
#   define YSDLog(FORMAT, ...) fprintf(stderr,"------YSDLog: %s\n",[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#   define YSDLog(...)
#endif

typedef NS_ENUM(NSUInteger, YSAUZStatus) {
    YSAUZStatusNotDetermined = 0,   //未做决定
    YSAUZStatusRestricted,          //决定权被系统收回
    YSAUZStatusDenied,              //拒绝授权
    YSAUZStatusAuthorized,          //已授权
    YSAUZStatusAuthorizedAlways,
    YSAUZStatusAuthorizedWhenInUse,
};

typedef NS_OPTIONS(NSUInteger, YSNotificationAuzType) {
    YSNotificationAuzTypeNone = 0,
    YSNotificationAuzTypeBadge = 1 << 0,    //标记：引用图标
    YSNotificationAuzTypeSound = 1 << 1,    //声音
    YSNotificationAuzTypeAlert = 1 << 2,    //横幅：出入的横幅、一直显示的提醒
};

@class YSBaseAuz;

typedef void(^AlertCancelAciton)();
typedef void(^StartRequestAuthorization)(UIViewController *container);
typedef void(^StartRequestAuthorizationWithAction)(UIViewController *container, AlertCancelAciton cancelAction);
typedef YSBaseAuz *(^Unforce)();
typedef YSBaseAuz *(^AlertEditor)(NSString *title, NSString *message, NSString *cancel, NSString *setting);
typedef YSBaseAuz *(^NotiAUZType)(YSNotificationAuzType notificationAUZType);

@interface YSBaseAuz : NSObject

/** 在系统的settings中的名字 */
@property (nonatomic, copy) NSString *moduleName;
/** 是否处于请求授权中 */
@property (nonatomic, assign) BOOL authorizing;

/** 授权的状态 */
@property (nonatomic, assign) YSAUZStatus           status;
/** 是否授权 */
@property (nonatomic, assign) BOOL                  enabled;
/** 是否不强制授权 */
@property (nonatomic, assign) BOOL                  unforced;
/** 调用后，不强制要求授权 ***每次使用都需要调用 */
@property (nonatomic, copy, readonly) Unforce       unforce;

/** alert标题 */
@property (nonatomic, copy) NSString                *title;
/** alert说明信息 */
@property (nonatomic, copy) NSString                *message;
/** alert取消按钮标题 */
@property (nonatomic, copy) NSString                *cancel;
/** alert设置按钮标题 */
@property (nonatomic, copy) NSString                *setting;
/** alert的容器 */
@property (nonatomic, strong) UIViewController      *container;
/** alert的容器是否加载到window上了 */
@property (nonatomic, assign) BOOL                  containerDidLoad;

/** alert的文案编辑 */
@property (nonatomic, copy, readonly) AlertEditor   alertEditor;
/** alert的配置和展示 */
@property (nonatomic, copy, readonly) StartRequestAuthorization     startRequestAuthorization;
/** alert的配置和展示 */
@property (nonatomic, copy, readonly) StartRequestAuthorizationWithAction startRequestAuthorizationWithAction;
/** alert的取消按钮响应 */
@property (nonatomic, copy, readonly) AlertCancelAciton cancelAciton;

@property (nonatomic, assign) YSNotificationAuzType requestNotiAUZType;
@property (nonatomic, copy, readonly) NotiAUZType notiAUZType;

//- (void)presentAlert;
//+ (void)openSettingsURL;
#pragma mark - Subclass useful Methods
/**
 记录拒绝授权的时间
 */
- (void)denyTimeRecord;
/**
 查询拒绝授权是否失效
 @return YES：拒绝 NO：失效
 */
- (BOOL)denyOverdueCheck;
/**
 清除拒绝授权的时间
 */
- (void)denyTimeClear;

#pragma mark - Abstract Methods

- (YSAUZStatus)status;
- (NSString *)message;
/**
 请求授权
 @return 是否执行了请求
 */
- (BOOL)requestAuthorization;
/**
 请求Always授权
 @return 是否执行了请求
 */
- (BOOL)requestAuthorizationAlways;
/**
 请求WhenInUse授权

 @return 是否执行了请求
 */
- (BOOL)requestAuthorizationWhenInUse;

@end
