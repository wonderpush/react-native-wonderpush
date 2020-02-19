//
//  WPInstallationCoreProperties.h
//  WonderPush
//
//  Created by Stéphane JAIS on 07/02/2019.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WPInstallationCoreProperties : NSObject
+ (NSString *) getSDKVersionNumber;
+ (NSString *) getDeviceModel;
+ (CGRect) getScreenSize;
+ (NSInteger) getScreenDensity;
+ (NSString *) getTimezone;
+ (NSString *) getCarrierName;
+ (NSString *) getVersionString;
+ (NSString *) getLocale;
+ (NSString *) getCountry;
+ (NSString *) getCurrency;
+ (NSString *) getOsVersion;
@end
