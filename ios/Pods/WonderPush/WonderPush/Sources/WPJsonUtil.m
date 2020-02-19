/*
 Copyright 2015 WonderPush

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

#import "WPJsonUtil.h"
#import "WPLog.h"

@implementation WPJsonUtil

+ (NSDictionary *)merge:(NSDictionary *)base with:(NSDictionary *)diff
{
    return [self merge:base with:diff nullFieldRemoves:YES];
}

+ (NSDictionary *)merge:(NSDictionary *)base with:(NSDictionary *)diff nullFieldRemoves:(BOOL)nullFieldRemoves
{
    if (base == nil) return nil;
    if (diff == nil) diff = @{};

    NSMutableDictionary *rtn = [base mutableCopy];
    NSString *key;

    for (key in diff) {
        id vDiff = [diff objectForKey:key];
        id vBase = [rtn objectForKey:key];
        if (vBase == nil) {
            if (vDiff == [NSNull null] && nullFieldRemoves) {
                // The field already does not exist
            } else {
                [rtn setObject:vDiff forKey:key];
            }
        } else if ([vDiff isKindOfClass:[NSDictionary class]] && [vBase isKindOfClass:[NSDictionary class]]) {
            [rtn setObject:[self merge:vBase with:vDiff] forKey:key];
        } else {
            if (vDiff == [NSNull null] && nullFieldRemoves) {
                // We should remove the field
                [rtn removeObjectForKey:key];
            } else {
                [rtn setObject:vDiff forKey:key];
            }
        }
    }

    return rtn;
}

+ (NSDictionary *)diff:(NSDictionary *)from with:(NSDictionary *)to
{
    if (from == nil) {
        if (to == nil) {
            return nil;
        } else {
            return [[NSDictionary alloc] initWithDictionary:to];
        }
    } else if (to == nil) {
        return nil;
    }

    NSMutableDictionary *rtn = [NSMutableDictionary new];
    NSString *key;

    for (key in from) {
        id vTo = [to objectForKey:key];
        if (vTo == nil) {
            [rtn setObject:[NSNull null] forKey:key];
            continue;
        }
        id vFrom = [from objectForKey:key];
        if (![vTo isEqual:vFrom]) {
            if ([vFrom isKindOfClass:[NSDictionary class]] && [vTo isKindOfClass:[NSDictionary class]]) {
                [rtn setObject:[self diff:(NSDictionary *)vFrom with:(NSDictionary *)vTo] forKey:key];
            } else {
                [rtn setObject:vTo forKey:key];
            }
        }
    }

    for (key in to) {
        id vFrom = [from objectForKey:key];
        if (vFrom != nil) continue;
        id vTo = [to objectForKey:key];
        [rtn setObject:vTo forKey:key];
    }

    return rtn;
}

+ (NSDictionary *)stripNulls:(NSDictionary *)base
{
    return [self merge:base with:base nullFieldRemoves:YES];
}

+ (id) ensureJSONEncodable:(id)data
{
    if (data == nil) {
        return [NSNull null];
    }
    // From [NSJSONSerialization isValidJSONObject:] documentation:
    // - Top level object is an NSArray or NSDictionary
    // - All objects are NSString, NSNumber, NSArray, NSDictionary, or NSNull
    // - All dictionary keys are NSStrings
    // - NSNumbers are not NaN or infinity
    if ([data isKindOfClass:[NSNull class]]) {
        return data;
    } else if ([data isKindOfClass:[NSString class]]) {
        return data;
    } else if ([data isKindOfClass:[NSNumber class]]) {
        if (isfinite([(NSNumber *)data doubleValue])) {
            return data;
        }
    } else if ([data isKindOfClass:[NSDictionary class]]) {

        // Recurse inside dictionaries
        NSMutableDictionary *rtn = [NSMutableDictionary new];
        [(NSDictionary *)data enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (![key isKindOfClass:[NSString class]]) {
                key = [NSString stringWithFormat:@"%@", key];
            }
            rtn[key] = [self ensureJSONEncodable:obj];
        }];
        return [NSDictionary dictionaryWithDictionary:rtn];

    } else if ([data isKindOfClass:[NSArray class]]) {

        // Recurse inside arrays
        NSMutableArray *rtn = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)data count]];
        [(NSArray *)data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [rtn addObject:[self ensureJSONEncodable:obj]];
        }];
        return [NSArray arrayWithArray:rtn];

    } else if ([data isKindOfClass:[NSDate class]]) {

        // Dates as millisecond unix timestamps
        return [NSNumber numberWithLongLong:(long long)([(NSDate *)data timeIntervalSince1970] * 1000)];

    } else if ([data isKindOfClass:[NSData class]]) {

        // Try as JSON first
        @try {
            NSError *error = NULL;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:(NSData *)data options:kNilOptions error:&error];
            if (!error) {
                return dict;
            }
        } @catch (NSException *exception) {}

        // Try as UTF-8 string
        NSString *str = [[NSString alloc] initWithData:(NSData *)data encoding:NSUTF8StringEncoding];
        if (str) {
            return str;
        }

        // Base64 encode binary data
        return [(NSData *)data base64EncodedStringWithOptions:kNilOptions];

    }

    // Generic string representation as last resort
    return [NSString stringWithFormat:@"%@", data];
}


@end
