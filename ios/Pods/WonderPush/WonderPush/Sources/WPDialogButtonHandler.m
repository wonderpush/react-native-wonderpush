/*
 Copyright 2014 WonderPush

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "WPDialogButtonHandler.h"
#import "WonderPush_private.h"
#import "WPUtil.h"

@implementation WPDialogButtonHandler

@synthesize buttonConfiguration, notificationConfiguration, showTime;

- (id)init
{
    self.showTime = [[NSProcessInfo processInfo] systemUptime];
    return self;
}

- (void)executeButtonActions:(NSArray *)actions
{
    if (![actions isKindOfClass:[NSArray class]]) return;
    for (NSDictionary *action in actions) {
        if (![action isKindOfClass:[NSDictionary class]]) continue;
        [WonderPush executeAction:action onNotification:notificationConfiguration];
    }
}

- (void)clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDictionary *clickedButton = nil;
    if (buttonConfiguration && buttonIndex >= 0 && buttonIndex < buttonConfiguration.count) {
        clickedButton = [buttonConfiguration objectAtIndex:buttonIndex];
        if (![clickedButton isKindOfClass:[NSDictionary class]]) clickedButton = nil;
    }

    NSNumber *shownTime = [[NSNumber alloc] initWithLong:(long)(([[NSProcessInfo processInfo] systemUptime] - self.showTime) * 1000)];
    [WonderPush trackInternalEvent:@"@NOTIFICATION_ACTION"
                         eventData:@{@"buttonLabel":[WPUtil stringForKey:@"label" inDictionary:clickedButton] ?: [NSNull null],
                                     @"reactionTime":shownTime,
                                     @"campaignId": [WPUtil stringForKey:@"c" inDictionary:notificationConfiguration] ?: [NSNull null],
                                     @"notificationId": [WPUtil stringForKey:@"n" inDictionary:notificationConfiguration] ?: [NSNull null],
                                     }
                        customData:nil];

    NSArray *clickedButtonAction = [WPUtil arrayForKey:@"actions" inDictionary:clickedButton];
    [self executeButtonActions:clickedButtonAction];
}

@end
