//
//  WPDataManager.m
//  WonderPush
//
//  Created by Stéphane JAIS on 13/02/2019.
//  Copyright © 2019 WonderPush. All rights reserved.
//

#import "WPDataManager.h"
#import "WPConfiguration.h"
#import "WPAPIClient.h"
#import "WPJsonSyncInstallation.h"

static WPDataManager *instance = nil;
static dispatch_queue_t dataManagerQueue;

@implementation WPDataManager
+ (void) initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManagerQueue = dispatch_queue_create("com.wonderpush.DataManager", DISPATCH_QUEUE_SERIAL);
        instance = [WPDataManager new];
    });
}
+ (instancetype) sharedInstance
{
    return instance;
}
- (void) downloadAllData:(void (^)(NSData *, NSError *))completion
{
    dispatch_async(dataManagerQueue, ^{
        void(^callCompletion)(NSData *, NSError*) = ^(NSData *data, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(data, error);
            });
        };
        __block NSError *error = nil;
        NSMutableData *buffer = [NSMutableData new];
        WPConfiguration *configuration = [WPConfiguration sharedConfiguration];
        void(^appendString)(NSString *) = ^(NSString *s) {
            [buffer appendData:[s dataUsingEncoding:NSUTF8StringEncoding]];
        };

        // Write WPConfiguration data
        appendString(@"{\"sharedPreferences\":");
        NSData *configurationData = [NSJSONSerialization dataWithJSONObject:[configuration dumpState] options:0 error:&error];
        if (error) return callCompletion(nil, error);
        [buffer appendData:configurationData];
        appendString(@"}\n");
        
        // Iterate on known user Ids
        for (NSString *userId in [configuration listKnownUserIds]) {
            NSString *accessToken = [configuration getAccessTokenForUserId:userId];
            if (accessToken == nil) continue; // That user was cleaned up, don't try to reach the API or it will re-create an accessToken
            
            // Get a new access token
            appendString(@"{\"accessToken\":");
            dispatch_semaphore_t sem = dispatch_semaphore_create(0);
            [[WPAPIClient sharedClient] fetchAccessTokenAndCall:^(NSURLSessionTask *task, id response) {
                NSData *responseData = [NSJSONSerialization dataWithJSONObject:response options:0 error:&error];
                if (responseData) {
                    [buffer appendData:responseData];
                }
                dispatch_semaphore_signal(sem);
            } failure:^(NSURLSessionTask *task, NSError *responseError) {
                appendString(responseError.description);
                dispatch_semaphore_signal(sem);
            } nbRetry:0 forUserId:userId];
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            appendString(@"}\n");
            if (error) return callCompletion(buffer, error);
            
            // Get user and installation objects
            NSMutableArray *resources = [NSMutableArray new];
            if (userId.length) [resources addObject:@"user"];
            [resources addObject:@"installation"];
            
            for (NSString *resource in resources) {
                WPRequest *request = [WPRequest new];
                request.userId = userId;
                request.resource = [NSString stringWithFormat:@"/%@", resource];
                request.method = @"GET";
                request.handler = ^(WPResponse *response, NSError *responseError) {
                    if (responseError) {
                        appendString(responseError.description);
                    } else if (response) {
                        NSData *responseData = [NSJSONSerialization dataWithJSONObject:response.object options:0 error:&error];
                        if (responseData) [buffer appendData:responseData];
                    }
                    dispatch_semaphore_signal(sem);
                };
                appendString([NSString stringWithFormat:@"{\"%@\":", resource]);
                [[WPAPIClient sharedClient] requestAuthenticated:request];
                dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
                appendString(@"}\n");
            }
            
            // Get events
            __block void(^getNextEventPage)(NSDictionary *params);
            WPRequestHandler handler = ^(WPResponse *response, NSError *responseError) {
                if (responseError) {
                    appendString(responseError.description);
                    appendString(@"}\n");
                } else if (response) {
                    NSArray *events = [response.object valueForKey:@"data"];
                    if (events.count) {
                        NSData *responseData = [NSJSONSerialization dataWithJSONObject:events options:0 error:&error];
                        appendString(@"{\"eventsPage\":");
                        if (responseData) [buffer appendData:responseData];
                        appendString(@"}\n");
                    }
                }
                // Extract pagination info from response
                NSDictionary *pagination = [response.object valueForKey:@"pagination"];
                id next = [pagination valueForKey:@"next"];
                // When a 'next' is specified, continue to next page
                if (next && next != [NSNull null] && [next isKindOfClass:[NSString class]]) {
                    // Parse the next URL to extract its parameters
                    NSURL *URL = [NSURL URLWithString:next];
                    NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
                    NSMutableDictionary *parameters = [NSMutableDictionary new];
                    for (NSURLQueryItem *queryItem in URLComponents.queryItems) {
                        if (queryItem.name && queryItem.value) {
                            [parameters setObject:queryItem.value forKey:queryItem.name];
                        }
                    }
                    // Loop as long as there's a next page
                    getNextEventPage(parameters);

                } else {
                    // Finish
                    dispatch_semaphore_signal(sem);
                }
            };
            getNextEventPage = ^(NSDictionary *params) {
                WPRequest *request = [WPRequest new];
                request.userId = userId;
                request.resource = @"/events";
                request.method = @"GET";
                request.params = params;
                request.handler = handler;
                [[WPAPIClient sharedClient] requestAuthenticated:request];
            };
            getNextEventPage(@{@"limit": @1000});
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        }
        
        callCompletion(buffer, nil);
    });
}
- (void) clearEventsHistory
{
    for (NSString *userId in [[WPConfiguration sharedConfiguration] listKnownUserIds]) {
        [self clearEventsHistoryForUserId:userId];
    }
}
- (void)clearEventsHistoryForUserId:(NSString *)userId
{
    WPRequest *request = [WPRequest new];
    request.userId = userId;
    request.resource = @"/events";
    request.method = @"DELETE";
    [[WPAPIClient sharedClient] requestAuthenticated:request];
}

- (void) clearPreferences
{
    for (NSString *userId in [[WPConfiguration sharedConfiguration] listKnownUserIds]) {
        [self clearPreferencesForUserId:userId];
    }
}
- (void) clearPreferencesForUserId:(NSString *)userId
{
    WPJsonSyncInstallation *sync = [WPJsonSyncInstallation forUser:userId];
    [sync put:@{@"custom":[NSNull null]}];
    [sync put:@{@"custom":@{}}];
    [sync flush];
    if (userId.length) {
        WPRequest *request = [WPRequest new];
        request.userId = userId;
        request.resource = @"/user";
        request.method = @"PUT";
        request.params = @{ @"body": @"{\"custom\":null}" };
        [[WPAPIClient sharedClient] requestAuthenticated:request];
    }
}
- (void) clearInstallation:(NSString *)userId
{
    WPJsonSyncInstallation *sync = [WPJsonSyncInstallation forUser:userId];
    [sync receiveState:@{} resetSdkState:YES];
    WPRequest *request = [WPRequest new];
    request.userId = userId;
    request.resource = @"/installation";
    request.method = @"DELETE";
    request.handler = ^(WPResponse *response, NSError *error) {
        NSLog(@"response:%@ error:%@", response, error);
    };
    [[WPAPIClient sharedClient] requestAuthenticated:request];

}
- (void) clearLocalStorage
{
    [[WPConfiguration sharedConfiguration] clearStorageKeepUserConsent:YES keepDeviceId:NO];
}
- (void) clearAllData
{
    for (NSString *userId in [[WPConfiguration sharedConfiguration] listKnownUserIds]) {
        [self clearInstallation:userId];
    }
    [self clearLocalStorage];
}

@end
