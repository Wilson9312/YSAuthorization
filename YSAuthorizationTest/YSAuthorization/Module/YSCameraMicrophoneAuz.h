//
//  YSCameraMicrophoneAuz.h
//  YSAuthorization
//
//  Created by Wilson_YS on 2017/5/8.
//  Copyright © 2017年 Guangdong Shengdijia Group Co., Ltd. All rights reserved.
//

#import "YSBaseAuz.h"

/**
 * Authorization methods for the usage of AV services.
 */
typedef NS_ENUM(NSInteger, YSAVAUZType) {
    YSAVAUZTypeCamera,      // 相机
    YSAVAUZTypeMicrophone   // 麦克风
};

@interface YSCameraMicrophoneAuz : YSBaseAuz
- (instancetype)initWith:(YSAVAUZType)type;
@end
