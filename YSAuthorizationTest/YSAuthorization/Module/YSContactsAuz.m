//
//  YSContactsAuz.m
//  YSAuthorization
//
//  Created by Wilson_YS on 2017/5/9.
//  Copyright © 2017年 Guangdong Shengdijia Group Co., Ltd. All rights reserved.
//

#import "YSContactsAuz.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>

@implementation YSContactsAuz

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.moduleName = @"通讯录";
    }
    return self;
}

#pragma mark - Abstract Methods

- (YSAUZStatus)status{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    return (YSAUZStatus)status;
#else
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    return (YSAUZStatus)status;
#endif
}
//- (NSString *)message;
/**
 请求授权
 @return 是否执行了请求
 */
- (BOOL)requestAuthorization{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
    CNContactStore *contactsStore = [[CNContactStore alloc] init];
    [contactsStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            YSDLog(@"%@ Authorized",self.moduleName);
        }else{
            YSDLog(@"%@ Denied",self.moduleName);
        }
    }];
#else
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, &error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted) {
            YSDLog(@"%@ Authorized",self.moduleName);
        }else{
            YSDLog(@"%@ Denied",self.moduleName);
        }
    });
#endif
    return YES;
}

@end
