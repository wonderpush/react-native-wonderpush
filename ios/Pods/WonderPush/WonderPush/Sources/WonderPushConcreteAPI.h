//
//  WonderPushConcreteAPI.h
//  WonderPush
//
//  Created by Stéphane JAIS on 07/02/2019.
//

#import <Foundation/Foundation.h>
#import "WonderPushAPI.h"

@interface WonderPushConcreteAPI : NSObject <WonderPushAPI>
@property (nonatomic, strong) CLLocationManager *locationManager;
@end
