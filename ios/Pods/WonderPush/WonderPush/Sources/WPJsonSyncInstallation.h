#import "WPJsonSync.h"

#import <Foundation/Foundation.h>

@interface WPJsonSyncInstallation : WPJsonSync

+ (void) initialize;

+ (WPJsonSyncInstallation *)forCurrentUser;

+ (WPJsonSyncInstallation *)forUser:(NSString *)userId;

+ (void) flush;
- (void) flush;

@end
