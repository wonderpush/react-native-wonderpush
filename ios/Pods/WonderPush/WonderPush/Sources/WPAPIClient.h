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

#import <Foundation/Foundation.h>
#import "WPRequest.h"

FOUNDATION_EXPORT NSString * const WPOperationFailingURLResponseDataErrorKey;

/**
 WPAPIClient is an implementation of AFHTTPClient that handles authentication to the API.
 */
@interface WPAPIClient : NSObject


///---------------
///@name Singleton
///---------------

/**
 The default `WPAPIClient`, configured with the values you supplied to [WonderPush setClientId:secret:].
 */
+ (WPAPIClient *)sharedClient;


///-----------------------------
///@name Access Token Management
///-----------------------------

- (void) fetchAccessTokenAndCall:(void (^)(NSURLSessionTask *task, id responseObject))handler failure:(void (^)(NSURLSessionTask *task, NSError *error))failure nbRetry:(NSInteger)nbRetry forUserId:(NSString *)userId;


- (BOOL) fetchAccessTokenIfNeededAndCall:(void (^)(NSURLSessionTask *task, id responseObject))handler failure:(void (^)(NSURLSessionTask *task, NSError *error))failure forUserId:(NSString *)userId;

/**
 Fetch an access token if the user isn't authenticated and none is found in the `NSUserDefaults`.
 */

- (BOOL) fetchAccessTokenIfNeededForUserId:(NSString *)userId;

/**
 Fetches an anonymous access token and runs the given request.
 @param request The request to run once the access token is fetched.
 */

- (void) fetchAccessTokenAndRunRequest:(WPRequest *)request;


///----------------------
/// @name REST API access
///----------------------

/**
 Performs the given request. If no accessToken can be found, requests an anonymous access token before running the given request.
 @param request The request to be run
 @exception InvalidHTTPVerb   Raised when using a verb other than GET, POST or DELETE.
 */
- (void) requestAuthenticated:(WPRequest *)request;

/**
 Performs the given request in an authenticated manner, immediately. Upon network error, save this request and try again later,
 even after application restart.

 The given request is saved in the `NSUserDefaults` and will be tried again upon application restart.

 The request's handler will be called upon success or error (other than network related) unless the application has restarted.

 @param request The request to be run
 @exception InvalidHTTPVerb   Raised when using a verb other than GET, POST or DELETE.
 */
- (void) requestEventually:(WPRequest *)request;


///------------------
/// @name HTTP client
///------------------

@property (assign, atomic) BOOL isFetchingAccessToken;

@end
