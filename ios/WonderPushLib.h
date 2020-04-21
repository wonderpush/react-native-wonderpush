#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface WonderPushLib : RCTEventEmitter <RCTBridgeModule>
-(void)wonderPushWillOpenURL:(NSString *)URL;
+ (WonderPushLib *)sharedInstance;
@end
