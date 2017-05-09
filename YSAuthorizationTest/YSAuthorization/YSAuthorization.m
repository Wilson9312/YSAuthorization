//
//  YSAuthorization.m
//  YSAuthorization
//
//  Created by Wilson_YS on 2017/5/7.
//  Copyright © 2017年 Guangdong Shengdijia Group Co., Ltd. All rights reserved.
//

#import "YSAuthorization.h"

@implementation YSAuthorization
static YSAuthorization *_auzManager;
+ (YSAuthorization *)auzManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _auzManager = [[YSAuthorization alloc] init];
    });
    return _auzManager;
}

- (YSLocationAuz *)location{
    if (!_location) {
        YSLocationAuz *lauz = [[YSLocationAuz alloc] init];
        _location = lauz;
    }
    return _location;
}

- (YSCameraMicrophoneAuz *)camera{
    if (!_camera) {
        YSCameraMicrophoneAuz *cAuz = [[YSCameraMicrophoneAuz alloc] initWith:YSAVAUZTypeCamera];
        _camera = cAuz;
    }
    return _camera;
}

- (YSCameraMicrophoneAuz *)microphone{
    if (!_microphone) {
        YSCameraMicrophoneAuz *mAuz = [[YSCameraMicrophoneAuz alloc] initWith:YSAVAUZTypeMicrophone];
        _microphone = mAuz;
    }
    return _microphone;
}

- (YSNotificationAuz *)notification{
    if (!_notification) {
        YSNotificationAuz *nAuz = [[YSNotificationAuz alloc] init];
        _notification = nAuz;
    }
    return _notification;
}

- (YSPhotoAuz *)photo{
    if (!_photo) {
        YSPhotoAuz *pAuz = [[YSPhotoAuz alloc] init];
        _photo = pAuz;
    }
    return _photo;
}

- (YSContactsAuz *)contacts{
    if (!_contacts) {
        YSContactsAuz *cAuz = [[YSContactsAuz alloc] init];
        _contacts = cAuz;
    }
    return _contacts;
}

@end
