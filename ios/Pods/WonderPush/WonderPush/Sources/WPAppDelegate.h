//
//  WPAppDelegate.h
//  WonderPush
//
//  Created by Olivier Favre on 13/01/16.
//  Copyright © 2016 WonderPush. All rights reserved.
//

#ifndef WPAppDelegate_h
#define WPAppDelegate_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) id<UIApplicationDelegate> nextDelegate;

+ (void) setupDelegateForApplication:(UIApplication *)application;

+ (BOOL) isAlreadyRunning;

@end

#endif /* WPAppDelegate_h */
