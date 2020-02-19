//
//  WPRequestSerializer.m
//  WonderPush
//
//  Created by Stéphane JAIS on 14/02/2019.
//  Copyright © 2019 WonderPush. All rights reserved.
//

#import "WPRequestSerializer.h"
#import <CommonCrypto/CommonCrypto.h>
#import "WonderPush_private.h"
#import "WPConfiguration.h"
#import "WPUtil.h"
#import "WPJsonUtil.h"
#import "WPLog.h"

@interface WPQueryStringPair : NSObject
@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (instancetype)initWithField:(id)field value:(id)value;

- (NSString *)URLEncodedStringValue;
@end

@implementation WPQueryStringPair

- (instancetype)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.field = field;
    self.value = value;
    
    return self;
}

- (NSString *)URLEncodedStringValue {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return [WPRequestSerializer percentEscapedStringFromString:[self.field description]];
    } else {
        return [NSString stringWithFormat:@"%@=%@", [WPRequestSerializer percentEscapedStringFromString:[self.field description]], [WPRequestSerializer percentEscapedStringFromString:[self.value description]]];
    }
}

@end

@implementation WPRequestSerializer
- (instancetype) init
{
    if (self = [super init]) {
        self.stringEncoding = NSUTF8StringEncoding;
        self.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", @"DELETE", nil];
    }
    return self;
}
+ (NSString *) percentEscapedStringFromString:(NSString *)string
{
    static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
    
    // FIXME: https://github.com/AFNetworking/AFNetworking/pull/3028
    // return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    
    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;
    
    while (index < string.length) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"
        NSUInteger length = MIN(string.length - index, batchSize);
#pragma GCC diagnostic pop
        NSRange range = NSMakeRange(index, length);
        
        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [string rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];
        
        index += range.length;
    }
    
    return escaped;
}
+ (NSString *) wonderPushAuthorizationHeaderValueForRequest:(NSURLRequest *)request
{
    NSString *method = request.HTTPMethod.uppercaseString;
    
    // GET requests do not need signing
    if ([@"GET" isEqualToString:method])
        return nil;
    
    if (![WonderPush isInitialized]) {
        WPLog(@"Authorization header cannot be calculated because the SDK is not initialized");
        return nil;
    }
    
    // Step 1: add HTTP method uppercase
    NSMutableString *buffer = [[NSMutableString alloc] initWithString:method];
    [buffer appendString:@"&"];
    
    // Step 2: add scheme://host/path
    [buffer appendString:[WPUtil percentEncodedString:[NSString stringWithFormat:@"%@://%@%@", request.URL.scheme, request.URL.host, request.URL.path]]];
    
    // Gather GET params
    NSDictionary *getParams = [WPUtil dictionaryWithFormEncodedString:request.URL.query];
    
    // Gather POST params
    NSData *dBody = nil;
    NSDictionary *postParams = nil;
    if ([@"application/x-www-form-urlencoded" isEqualToString:[request valueForHTTPHeaderField:@"Content-Type"]]) {
        postParams = [WPUtil dictionaryWithFormEncodedString:[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]];
    } else {
        postParams = @{};
        dBody = request.HTTPBody;
    }
    
    // Step 3: add params
    [buffer appendString:@"&"];
    NSArray *paramNames = [[[NSSet setWithArray:getParams.allKeys] setByAddingObjectsFromArray:postParams.allKeys].allObjects sortedArrayUsingSelector:@selector(compare:)];
    
    if (paramNames.count) {
        NSString *last = paramNames.lastObject;
        for (NSString *paramName in paramNames) {
            NSString *val = [WPUtil stringForKey:paramName inDictionary:postParams];
            if (!val)
                val = [WPUtil stringForKey:paramName inDictionary:getParams];
            
            [buffer appendString:[WPUtil percentEncodedString:[NSString stringWithFormat:@"%@=%@", [WPUtil percentEncodedString:paramName], [WPUtil percentEncodedString:val]]]];
            
            if (![last isEqualToString:paramName]) {
                [buffer appendString:@"%26"];
            }
        }
    }
    
    // Add body if Content-Type is not application/x-www-form-urlencoded
    [buffer appendString:@"&"];
    //WPLogDebug(@"%@", buffer);
    // body will be hmac-ed directly after buffer
    
    // Sign the buffer with the client secret using HMacSha1
    const char *cKey  = [[WPConfiguration sharedConfiguration].clientSecret cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [buffer cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmacContext hmacCtx;
    CCHmacInit(&hmacCtx, kCCHmacAlgSHA1, cKey, strlen(cKey));
    CCHmacUpdate(&hmacCtx, cData, strlen(cData));
    if (dBody) {
        //WPLogDebug(@"%@", [[NSString alloc] initWithData:dBody encoding:NSUTF8StringEncoding]);
        CCHmacUpdate(&hmacCtx, dBody.bytes, dBody.length);
    }
    CCHmacFinal(&hmacCtx, cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *hash = [WPUtil base64forData:HMAC];
    
    return [NSString stringWithFormat:@"WonderPush sig=\"%@\", meth=\"0\"", [WPUtil percentEncodedString:hash]];
}

+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters
{
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (WPQueryStringPair *pair in [self queryStringPairsFromKey:nil andValue:parameters]) {
        [mutablePairs addObject:[pair URLEncodedStringValue]];
    }
    
    return [mutablePairs componentsJoinedByString:@"&"];
}

+ (NSArray *) queryStringPairsFromKey:(NSString *)key andValue:(id)value {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue = dictionary[nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:[self queryStringPairsFromKey:(key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey) andValue:nestedValue]];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:[self queryStringPairsFromKey:[NSString stringWithFormat:@"%@[]", key] andValue:nestedValue]];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray:[self queryStringPairsFromKey:key andValue:obj]];
        }
    } else {
        [mutableQueryStringComponents addObject:[[WPQueryStringPair alloc] initWithField:key value:value]];
    }
    
    return mutableQueryStringComponents;
}


- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request withParameters:(id)parameters error:(NSError *__autoreleasing  _Nullable *)error
{
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    NSMutableDictionary *mutableParameters = [parameters mutableCopy];

    // Turn dictionary and array values into a JSON string
    for (NSString *key in parameters) {
        id value = [WPJsonUtil ensureJSONEncodable:parameters[key]];
        if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]) {
            @try {
                NSError *err;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:0 error:&err];
                if (err != nil) {
                    WPLog(@"Failed to serialize parameter %@=%@: %@", key, value, err);
                } else {
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    mutableParameters[key] = jsonString;
                }
            } @catch (NSException *exception) {
                WPLog(@"Failed to serialize parameter %@=%@: %@", key, value, exception);
            }
        }
    }
    
    // Build a query string
    NSString *query = nil;
    if (mutableParameters) {
        query = [[self class] queryStringFromParameters:mutableParameters];
    }

    // Add the query string in the URL or the request body
    if ([self.HTTPMethodsEncodingParametersInURI containsObject:[[request HTTPMethod] uppercaseString]]) {
        if (query && query.length > 0) {
            mutableRequest.URL = [NSURL URLWithString:[[mutableRequest.URL absoluteString] stringByAppendingFormat:mutableRequest.URL.query ? @"&%@" : @"?%@", query]];
        }
    } else {
        // #2864: an empty string is a valid x-www-form-urlencoded payload
        if (!query) {
            query = @"";
        }
        if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
            [mutableRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        }
        [mutableRequest setHTTPBody:[query dataUsingEncoding:self.stringEncoding]];
    }

    // Add the authorization header after JSON serialization
    NSString *authorizationHeader = [[self class] wonderPushAuthorizationHeaderValueForRequest:mutableRequest];
    if (authorizationHeader) {
        [mutableRequest addValue:authorizationHeader forHTTPHeaderField:@"X-WonderPush-Authorization"];
    }
    
    return mutableRequest;
}

@end

