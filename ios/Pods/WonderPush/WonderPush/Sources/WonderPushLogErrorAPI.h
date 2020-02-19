//
//  WonderPushLogErrorAPI.h
//  WonderPush
//
//  Created by Stéphane JAIS on 08/02/2019.
//  Copyright © 2019 WonderPush. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WonderPushAPI.h"

@interface WonderPushLogErrorAPI : NSObject <WonderPushAPI>
- (void) log: (NSString *) method;
@end

@interface WonderPushNotInitializedAPI : WonderPushLogErrorAPI
@end

@interface WonderPushNoConsentAPI : WonderPushLogErrorAPI
@end
