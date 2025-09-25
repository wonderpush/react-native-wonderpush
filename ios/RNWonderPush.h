#import <WonderPushSpec/WonderPushSpec.h>
#import <React/RCTEventEmitter.h>
#import <WonderPush/WonderPush.h>

@interface RNWonderPush : RCTEventEmitter <NativeWonderPushSpec, WonderPushDelegate>

@end
