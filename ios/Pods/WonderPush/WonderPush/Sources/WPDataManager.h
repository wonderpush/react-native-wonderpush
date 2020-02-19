//
//  WPDataManager.h
//  WonderPush
//
//  Created by Stéphane JAIS on 13/02/2019.
//  Copyright © 2019 WonderPush. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WPDataManager : NSObject
+ (instancetype) sharedInstance;
- (void)downloadAllData:(void (^)(NSData *, NSError *))completion;
- (void)clearEventsHistory;
- (void)clearEventsHistoryForUserId:(NSString *)userId;
- (void) clearPreferences;
- (void) clearPreferencesForUserId:(NSString *)userId;
- (void) clearAllData;
- (void) clearLocalStorage;
- (void) clearInstallation:(NSString *)userId;
@end
