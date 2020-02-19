#import "WPJsonSync.h"

#import "WPJsonUtil.h"
#import "WPLog.h"
#import "WPUtil.h"


#define SAVED_STATE_FIELD__SYNC_STATE_VERSION @"_syncStateVersion"
#define SAVED_STATE_STATE_VERSION_1 @1
#define SAVED_STATE_STATE_VERSION_2 @2
#define SAVED_STATE_FIELD_UPGRADE_META @"upgradeMeta"
#define SAVED_STATE_FIELD_SDK_STATE @"sdkState"
#define SAVED_STATE_FIELD_SERVER_STATE @"serverState"
#define SAVED_STATE_FIELD_PUT_ACCUMULATOR @"putAccumulator"
#define SAVED_STATE_FIELD_INFLIGHT_DIFF @"inflightDiff"
#define SAVED_STATE_FIELD_INFLIGHT_PUT_ACCUMULATOR @"inflightPutAccumulator"
#define SAVED_STATE_FIELD_SCHEDULED_PATCH_CALL @"scheduledPatchCall"
#define SAVED_STATE_FIELD_INFLIGHT_PATCH_CALL @"inflightPatchCall"



@interface WPJsonSync ()


@property WPJsonSyncServerPatchCallback serverPatchCallback;
@property WPJsonSyncSaveCallback saveCallback;
@property WPJsonSyncCallback schedulePatchCallCallback;

@property (copy) NSDictionary *upgradeMeta;
@property (copy) NSDictionary *putAccumulator;
@property (copy) NSDictionary *inflightDiff;
@property (copy) NSDictionary *inflightPutAccumulator;

- (void) schedulePatchCallAndSave;
- (void) save;
- (void) callPatch;

- (void) onSuccess;
- (void) onFailure;


@end



@implementation WPJsonSync


- (instancetype) initFromSavedState:(NSDictionary *)savedState saveCallback:(WPJsonSyncSaveCallback)saveCallback serverPatchCallback:(WPJsonSyncServerPatchCallback)serverPatchCallback schedulePatchCallCallback:(WPJsonSyncCallback)schedulePatchCallCallback upgradeCallback:(WPJsonSyncUpgradeCallback _Nullable)upgradeCallback {
    self = [super init];
    if (self) {
        _serverPatchCallback = serverPatchCallback;
        _saveCallback = saveCallback;
        _schedulePatchCallCallback = schedulePatchCallCallback;

        savedState = savedState ?: @{};
        NSNumber *syncStateVersion;
        syncStateVersion        = [WPUtil numberForKey:SAVED_STATE_FIELD__SYNC_STATE_VERSION inDictionary:savedState] ?: @0;
        _upgradeMeta            = [WPUtil dictionaryForKey:SAVED_STATE_FIELD_UPGRADE_META inDictionary:savedState] ?: @{};
        _sdkState               = [WPUtil dictionaryForKey:SAVED_STATE_FIELD_SDK_STATE inDictionary:savedState] ?: @{};
        _serverState            = [WPUtil dictionaryForKey:SAVED_STATE_FIELD_SERVER_STATE inDictionary:savedState] ?: @{};
        _putAccumulator         = [WPUtil dictionaryForKey:SAVED_STATE_FIELD_PUT_ACCUMULATOR inDictionary:savedState] ?: @{};
        _inflightDiff           = [WPUtil dictionaryForKey:SAVED_STATE_FIELD_INFLIGHT_DIFF inDictionary:savedState] ?: @{};
        _inflightPutAccumulator = [WPUtil dictionaryForKey:SAVED_STATE_FIELD_INFLIGHT_PUT_ACCUMULATOR inDictionary:savedState] ?: @{};
        _scheduledPatchCall     = [([WPUtil numberForKey:SAVED_STATE_FIELD_SCHEDULED_PATCH_CALL inDictionary:savedState] ?: @NO) boolValue];
        _inflightPatchCall      = [([WPUtil numberForKey:SAVED_STATE_FIELD_INFLIGHT_PATCH_CALL inDictionary:savedState] ?: @NO) boolValue];
        
        // Handle state version upgrades (syncStateVersion)
        // - 0 -> 1: No-op. 0 means no previous state.
        // - 1 -> 2: No-op. Only the "upgradeMeta" key has been added and it is read with proper default.

        // Handle client upgrades
        [self applyUpgradeCallback:upgradeCallback];

        if (_inflightPatchCall) {
            [self onFailure];
        }
    }
    return self;
}

- (instancetype) initFromSdkState:(NSDictionary *)sdkState andServerState:(NSDictionary *)serverState saveCallback:(WPJsonSyncSaveCallback)saveCallback serverPatchCallback:(WPJsonSyncServerPatchCallback)serverPatchCallback schedulePatchCallCallback:(WPJsonSyncCallback)schedulePatchCallCallback upgradeCallback:(WPJsonSyncUpgradeCallback)upgradeCallback {
    self = [super init];
    if (self) {
        _serverPatchCallback = serverPatchCallback;
        _saveCallback = saveCallback;
        _schedulePatchCallCallback = schedulePatchCallCallback;

        _upgradeMeta = @{};
        _sdkState = [WPJsonUtil stripNulls:sdkState ?: @{}];
        _serverState = [WPJsonUtil stripNulls:serverState ?: @{}];
        _putAccumulator = [WPJsonUtil diff:_serverState with:_sdkState];
        _inflightDiff = @{};
        _inflightPutAccumulator = @{};
        _scheduledPatchCall = true;
        _inflightPatchCall = false;

        [self applyUpgradeCallback:upgradeCallback];
    }
    return self;
}

- (void) applyUpgradeCallback:(WPJsonSyncUpgradeCallback)upgradeCallback {
    if (upgradeCallback != nil) {
        NSMutableDictionary *upgradeMeta            = [NSMutableDictionary dictionaryWithDictionary:_upgradeMeta];
        NSMutableDictionary *sdkState               = [NSMutableDictionary dictionaryWithDictionary:_sdkState];
        NSMutableDictionary *serverState            = [NSMutableDictionary dictionaryWithDictionary:_serverState];
        NSMutableDictionary *putAccumulator         = [NSMutableDictionary dictionaryWithDictionary:_putAccumulator];
        NSMutableDictionary *inflightDiff           = [NSMutableDictionary dictionaryWithDictionary:_inflightDiff];
        NSMutableDictionary *inflightPutAccumulator = [NSMutableDictionary dictionaryWithDictionary:_inflightPutAccumulator];
        upgradeCallback(upgradeMeta, sdkState, serverState, putAccumulator, inflightDiff, inflightPutAccumulator);
        _upgradeMeta            = [NSDictionary dictionaryWithDictionary:upgradeMeta];
        _sdkState               = [NSDictionary dictionaryWithDictionary:sdkState];
        _serverState            = [NSDictionary dictionaryWithDictionary:serverState];
        _putAccumulator         = [NSDictionary dictionaryWithDictionary:putAccumulator];
        _inflightDiff           = [NSDictionary dictionaryWithDictionary:inflightDiff];
        _inflightPutAccumulator = [NSDictionary dictionaryWithDictionary:inflightPutAccumulator];
    }
}

- (void) save {
    @synchronized (self) {
        _saveCallback(@{
                        SAVED_STATE_FIELD__SYNC_STATE_VERSION:      SAVED_STATE_STATE_VERSION_2,
                        SAVED_STATE_FIELD_UPGRADE_META:             _upgradeMeta,
                        SAVED_STATE_FIELD_SDK_STATE:                _sdkState,
                        SAVED_STATE_FIELD_SERVER_STATE:             _serverState,
                        SAVED_STATE_FIELD_PUT_ACCUMULATOR:          _putAccumulator,
                        SAVED_STATE_FIELD_INFLIGHT_DIFF:            _inflightDiff ?: @{},
                        SAVED_STATE_FIELD_INFLIGHT_PUT_ACCUMULATOR: _inflightPutAccumulator,
                        SAVED_STATE_FIELD_SCHEDULED_PATCH_CALL:     [NSNumber numberWithBool:_scheduledPatchCall],
                        SAVED_STATE_FIELD_INFLIGHT_PATCH_CALL:      [NSNumber numberWithBool:_inflightPatchCall],
                        });
    }
}

- (void) put:(NSDictionary *)diff {
    @synchronized (self) {
        diff = diff ?: @{};
        _sdkState = [WPJsonUtil merge:_sdkState with:diff];
        _putAccumulator = [WPJsonUtil merge:_putAccumulator with:diff nullFieldRemoves:NO];
        [self schedulePatchCallAndSave];
    }
}

- (void) receiveState:(NSDictionary *)state resetSdkState:(bool)reset {
    @synchronized (self) {
        state = state ?: @{};
        _serverState = [WPJsonUtil stripNulls:[state copy]];
        _sdkState = [_serverState copy];
        if (reset) {
            _putAccumulator = @{};
        } else {
            _sdkState = [WPJsonUtil merge:[WPJsonUtil merge:_sdkState with:_inflightDiff] with:_putAccumulator];
        }
        [self schedulePatchCallAndSave];
    }
}

- (void) receiveServerState:(NSDictionary *)state {
    @synchronized (self) {
        state = state ?: @{};
        _serverState = [WPJsonUtil stripNulls:[state copy]];
        [self schedulePatchCallAndSave];
    }
}

- (void) receiveDiff:(NSDictionary *)diff {
    @synchronized (self) {
        diff = diff ?: @{};
        // The diff is already server-side, by contract
        _serverState = [WPJsonUtil merge:_serverState with:diff];
        [self put:diff];
    }
}

- (void) schedulePatchCallAndSave {
    @synchronized (self) {
        _scheduledPatchCall = true;
        [self save];
        _schedulePatchCallCallback();
    }
}

- (bool) performScheduledPatchCall {
    @synchronized (self) {
        if (_scheduledPatchCall) {
            [self callPatch];
            return true;
        }
        return false;
    }
}

- (void) callPatch {
    @synchronized (self) {
        if (_inflightPatchCall) {
            if (!_scheduledPatchCall) {
                WPLogDebug(@"Server PATCH call already inflight, scheduling a new one");
                [self schedulePatchCallAndSave];
            } else {
                WPLogDebug(@"Server PATCH call already inflight, and already scheduled");
            }
            [self save];
            return;
        }
        _scheduledPatchCall = false;

        _inflightDiff = [WPJsonUtil diff:_serverState with:_sdkState];
        if (_inflightDiff.count == 0) {
            WPLogDebug(@"No diff to send to server");
            [self save];
            return;
        }
        _inflightPatchCall = true;

        _inflightPutAccumulator = [_putAccumulator copy];
        _putAccumulator = @{};

        [self save];
        _serverPatchCallback(_inflightDiff, ^(){[self onSuccess];}, ^(){[self onFailure];});
    }
}

- (void) onSuccess {
    @synchronized (self) {
        _inflightPatchCall = false;
        _inflightPutAccumulator = @{};
        _serverState = [WPJsonUtil merge:_serverState with:_inflightDiff];
        _inflightDiff = @{};
        [self save];
    }
}

- (void) onFailure {
    @synchronized (self) {
        _inflightPatchCall = false;
        _putAccumulator = [WPJsonUtil merge:_inflightPutAccumulator with:_putAccumulator nullFieldRemoves:NO];
        _inflightPutAccumulator = @{};
        [self schedulePatchCallAndSave];
    }
}



@end
