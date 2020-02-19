//
//  WPNotificationCenterDelegate.h
//  WonderPush
//
//  Created by Olivier Favre on 24/02/17.
//  Copyright © 2017 WonderPush. All rights reserved.
//

#ifndef WPNotificationCenterDelegate_h
#define WPNotificationCenterDelegate_h

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

API_AVAILABLE(ios(10.0))
@interface WPNotificationCenterDelegate : UIResponder <UNUserNotificationCenterDelegate>

@property (strong, nonatomic) id<UNUserNotificationCenterDelegate> nextDelegate;

+ (void) setupDelegateForNotificationCenter:(UNUserNotificationCenter *)center;

+ (BOOL) isAlreadyRunning;

@end

#endif /* WPNotificationCenterDelegate_h */
