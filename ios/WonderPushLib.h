#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface WonderPushLib : RCTEventEmitter <RCTBridgeModule>
-(void)wonderPushWillOpenURL:(NSURL *)URL;
+ (WonderPushLib *)sharedInstance;
@end
