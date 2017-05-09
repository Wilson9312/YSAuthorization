//
//  ViewController.m
//  YSAuthorizationTest
//
//  Created by chenyuansheng on 2017/5/9.
//  Copyright © 2017年 Guangdong Shengdijia Group Co., Ltd. All rights reserved.
//

#import "ViewController.h"
#import "YSAuthorization.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)camera:(id)sender {
    AUZManager.camera.startRequestAuthorizationWithAction(self, ^{
        NSLog(@"拒绝授权");
    });
}
- (IBAction)microphone:(id)sender {
    AUZManager.microphone.alertEditor(@"Titleeee", @"Messageeee", @"Cancellll", @"GoSettinggg").startRequestAuthorization(self);
}
- (IBAction)contacts:(id)sender {
    AUZManager.contacts.startRequestAuthorization(self);
}
- (IBAction)location:(id)sender {
    AUZManager.location.startRequestAuthorization(self);
}
- (IBAction)notification:(id)sender {
    AUZManager.notification.unforce().startRequestAuthorization(self);
}
- (IBAction)photo:(id)sender {
    AUZManager.photo.startRequestAuthorization(self);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
