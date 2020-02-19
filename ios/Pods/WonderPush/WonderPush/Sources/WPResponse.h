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

/**
 WPResponse represents a response from the WonderPush REST API.
 */
@interface WPResponse : NSObject

///=======================
///@name Response contents
///=======================

/**
 A Key-value coding compliant object that represents the JSON returned by the WonderPush API.
 */
@property (nonatomic, strong) id object;

@end
