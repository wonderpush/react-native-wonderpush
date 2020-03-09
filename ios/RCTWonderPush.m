//
//  RCTWonderPush.m
//  WonderPushLib
//
//  Created by Apple on 08/03/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "RCTWonderPush.h"
#import <WonderPush/WonderPush.h>

@implementation RCTWonderPush
 + (RCTWonderPush *) sharedInstance{
    static dispatch_once_t token = 0;
       static id _sharedInstance = nil;
       dispatch_once(&token, ^{
           _sharedInstance = [[RCTWonderPush alloc] init];
       });
       return _sharedInstance;
 }
 - (void)setClientId:(NSString *)clientId secret:(NSString *)clientSecret{
     [WonderPush setClientId:clientId secret:clientSecret];
     [WonderPush setupDelegateForApplication:[UIApplication sharedApplication]];
     if (@available(iOS 10.0, *)) {
         [WonderPush setupDelegateForUserNotificationCenter];
     }
 }

@end
