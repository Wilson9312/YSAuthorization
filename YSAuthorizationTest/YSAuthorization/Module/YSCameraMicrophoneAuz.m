//
//  YSCameraMicrophoneAuz.m
//  YSAuthorization
//
//  Created by Wilson_YS on 2017/5/8.
//  Copyright © 2017年 Guangdong Shengdijia Group Co., Ltd. All rights reserved.
//

#import "YSCameraMicrophoneAuz.h"
#import <AVFoundation/AVFoundation.h>

@interface YSCameraMicrophoneAuz ()
@property (nonatomic, assign) YSAVAUZType   mediaType;
@property (nonatomic, copy) NSString        *AVMediaType;
@end

@implementation YSCameraMicrophoneAuz

- (instancetype)initWith:(YSAVAUZType)type
{
    self = [super init];
    if (self) {
        _mediaType = type;
        switch (_mediaType) {
            case YSAVAUZTypeCamera:{
                _AVMediaType = AVMediaTypeVideo;
                self.moduleName = @"相机";
                break;
            }
            case YSAVAUZTypeMicrophone:{
                _AVMediaType = AVMediaTypeAudio;
                self.moduleName = @"麦克风";
                break;
            }
        }
    }
    return self;
}

#pragma mark - Abstract Methods

- (YSAUZStatus)status{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:_AVMediaType];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
            return YSAUZStatusNotDetermined;
            break;
        case AVAuthorizationStatusRestricted:
            return YSAUZStatusRestricted;
            break;
        case AVAuthorizationStatusDenied:
            return YSAUZStatusDenied;
            break;
        case AVAuthorizationStatusAuthorized:
            return YSAUZStatusAuthorized;
            break;
    }
}

- (BOOL)requestAuthorization{
    [AVCaptureDevice requestAccessForMediaType:_AVMediaType
                             completionHandler:^(BOOL granted)
    {
        self.authorizing = NO;
        if (!granted) {
            [self denyTimeRecord];
            YSDLog(@"%@ Denied",self.moduleName);
        }else {
            [self denyTimeClear];
            YSDLog(@"%@ Authorized",self.moduleName);
        }
    }];
    return YES;
}

@end
