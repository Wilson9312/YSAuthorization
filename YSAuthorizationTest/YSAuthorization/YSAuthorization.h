//
//  YSAuthorization.h
//  YSAuthorization
//
//  Created by Wilson_YS on 2017/5/7.
//  Copyright © 2017年 Guangdong Shengdijia Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSLocationAuz.h"
#import "YSCameraMicrophoneAuz.h"
#import "YSNotificationAuz.h"
#import "YSPhotoAuz.h"
#import "YSContactsAuz.h"

#define AUZManager [YSAuthorization auzManager]

@interface YSAuthorization : NSObject

/** 定位授权 */
@property (nonatomic, strong) YSLocationAuz *location;
/** 相机授权 */
@property (nonatomic, strong) YSCameraMicrophoneAuz *camera;
/** 麦克风授权 */
@property (nonatomic, strong) YSCameraMicrophoneAuz *microphone;
/** 通知授权 */
@property (nonatomic, strong) YSNotificationAuz *notification;
/** 照片授权 */
@property (nonatomic, strong) YSPhotoAuz *photo;
/** 通讯录授权 */
@property (nonatomic, strong) YSContactsAuz *contacts;
+ (YSAuthorization *)auzManager;

@end
