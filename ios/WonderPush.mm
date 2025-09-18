#import "WonderPush.h"

@implementation WonderPush
RCT_EXPORT_MODULE()

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeWonderPushSpecJSI>(params);
}

- (NSNumber *)multiply:(double)a b:(double)b {
    NSNumber *result = @(a * b);

    return result;
}

- (void)subscribeToNotifications:(NSNumber *)fallbackToSettings {
    [WonderPush subscribeToNotifications];
}

@end
