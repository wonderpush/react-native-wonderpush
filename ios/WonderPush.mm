#import "WonderPush.h"

@implementation WonderPush
RCT_EXPORT_MODULE()

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeWonderPushSpecJSI>(params);
}

- (void)subscribeToNotifications:(NSNumber *)fallbackToSettings {
    [WonderPush subscribeToNotifications];
}

@end
