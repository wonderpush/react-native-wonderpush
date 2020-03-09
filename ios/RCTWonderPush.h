//
//  RCTWonderPush.h
//  WonderPushLib
//
//  Created by Apple on 08/03/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCTWonderPush : NSObject
 + (RCTWonderPush *) sharedInstance;
 - (void)setClientId:(NSString *)clientId secret:(NSString *)clientSecret;
-(void)helloWorld1;
-(void)helloWorld3:(NSString *)param;

+(void)helloWorld2;
-(void)helloWorld4:(NSString *)param1 second:(NSString *)param2;

@end

NS_ASSUME_NONNULL_END
