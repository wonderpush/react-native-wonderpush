//
//  WPInstallationCoreProperties.m
//  WonderPush
//
//  Created by Stéphane JAIS on 07/02/2019.
//

#import "WPInstallationCoreProperties.h"
#import <CoreGraphics/CGGeometry.h>
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <UserNotifications/UserNotifications.h>
#import <sys/utsname.h>
#import "WonderPush_private.h"
#import "WPUtil.h"

static NSDictionary *deviceNamesByCode = nil;
static NSDictionary* gpsCapabilityByCode = nil;

@implementation WPInstallationCoreProperties
+ (void) initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Source: http://www.enterpriseios.com/wiki/iOS_Devices
        // Source: https://www.theiphonewiki.com/wiki/Models
        deviceNamesByCode = @{
                              @"iPhone1,1"   : @"iPhone 1G",
                              @"iPhone1,2"   : @"iPhone 3G",
                              @"iPhone2,1"   : @"iPhone 3GS",
                              @"iPhone3,1"   : @"iPhone 4",
                              @"iPhone3,2"   : @"iPhone 4",
                              @"iPhone3,3"   : @"Verizon iPhone 4",
                              @"iPhone4,1"   : @"iPhone 4S",
                              @"iPhone5,1"   : @"iPhone 5 (GSM)",
                              @"iPhone5,2"   : @"iPhone 5 (GSM+CDMA)",
                              @"iPhone5,3"   : @"iPhone 5c (GSM)",
                              @"iPhone5,4"   : @"iPhone 5c (Global)",
                              @"iPhone6,1"   : @"iPhone 5s (GSM)",
                              @"iPhone6,2"   : @"iPhone 5s (Global)",
                              @"iPhone7,1"   : @"iPhone 6 Plus",
                              @"iPhone7,2"   : @"iPhone 6",
                              @"iPhone8,1"   : @"iPhone 6S",
                              @"iPhone8,2"   : @"iPhone 6S Plus",
                              @"iPhone8,4"   : @"iPhone SE",
                              @"iPhone9,1"   : @"iPhone 7 (Global)",
                              @"iPhone9,3"   : @"iPhone 7 (GSM)",
                              @"iPhone9,2"   : @"iPhone 7 Plus (Global)",
                              @"iPhone9,4"   : @"iPhone 7 Plus (GSM)",
                              @"iPod1,1"     : @"iPod Touch 1G",
                              @"iPod2,1"     : @"iPod Touch 2G",
                              @"iPod3,1"     : @"iPod Touch 3G",
                              @"iPod4,1"     : @"iPod Touch 4G",
                              @"iPod5,1"     : @"iPod Touch 5G",
                              @"iPod7,1"     : @"iPod Touch 6",
                              @"iPad1,1"     : @"iPad",
                              @"iPad2,1"     : @"iPad 2 (WiFi)",
                              @"iPad2,2"     : @"iPad 2 (GSM)",
                              @"iPad2,3"     : @"iPad 2 (CDMA)",
                              @"iPad2,4"     : @"iPad 2 (WiFi)",
                              @"iPad2,5"     : @"iPad Mini (WiFi)",
                              @"iPad2,6"     : @"iPad Mini (GSM)",
                              @"iPad2,7"     : @"iPad Mini (GSM+CDMA)",
                              @"iPad3,1"     : @"iPad 3 (WiFi)",
                              @"iPad3,2"     : @"iPad 3 (GSM+CDMA)",
                              @"iPad3,3"     : @"iPad 3 (GSM)",
                              @"iPad3,4"     : @"iPad 4 (WiFi)",
                              @"iPad3,5"     : @"iPad 4 (GSM)",
                              @"iPad3,6"     : @"iPad 4 (GSM+CDMA)",
                              @"iPad4,1"     : @"iPad Air (WiFi)",
                              @"iPad4,2"     : @"iPad Air (GSM)",
                              @"iPad4,3"     : @"iPad Air",
                              @"iPad4,4"     : @"iPad Mini Retina (WiFi)",
                              @"iPad4,5"     : @"iPad Mini Retina (GSM)",
                              @"iPad4,6"     : @"iPad Mini 2G",
                              @"iPad4,7"     : @"iPad Mini 3 (WiFi)",
                              @"iPad4,8"     : @"iPad Mini 3 (Cellular)",
                              @"iPad4,9"     : @"iPad Mini 3 (China)",
                              @"iPad5,1"     : @"iPad Mini 4 (WiFi)",
                              @"iPad5,2"     : @"iPad Mini 4 (Cellular)",
                              @"iPad5,3"     : @"iPad Air 2 (WiFi)",
                              @"iPad5,4"     : @"iPad Air 2 (Cellular)",
                              @"iPad6,3"     : @"iPad Pro 9.7-inch (WiFi)",
                              @"iPad6,4"     : @"iPad Pro 9.7-inch (Cellular)",
                              @"iPad6,7"     : @"iPad Pro (WiFi)",
                              @"iPad6,8"     : @"iPad Pro (Cellular)",
                              @"AppleTV2,1"  : @"Apple TV 2G",
                              @"AppleTV3,1"  : @"Apple TV 3",
                              @"AppleTV3,2"  : @"Apple TV 3 (2013)",
                              @"AppleTV5,3"  : @"Apple TV 4G",
                              @"Watch1,1"    : @"Apple Watch 38mm",
                              @"Watch1,2"    : @"Apple Watch 42mm",
                              @"Watch2,3"    : @"Apple Watch Series 1 38mm",
                              @"Watch2,4"    : @"Apple Watch Series 1 42mm",
                              @"Watch2,6"    : @"Apple Watch Series 2 38mm",
                              @"Watch2,7"    : @"Apple Watch Series 2 42mm",
                              @"i386"        : @"Simulator",
                              @"x86_64"      : @"Simulator"
                              };
        gpsCapabilityByCode = @{
                                @"iPhone1,1"   : @NO,
                                @"iPhone1,2"   : @YES,
                                @"iPhone2,1"   : @YES,
                                @"iPhone3,1"   : @YES,
                                @"iPhone3,3"   : @YES,
                                @"iPhone4,1"   : @YES,
                                @"iPhone5,1"   : @YES,
                                @"iPhone5,2"   : @YES,
                                @"iPhone5,3"   : @YES,
                                @"iPhone5,4"   : @YES,
                                @"iPhone6,1"   : @YES,
                                @"iPhone6,2"   : @YES,
                                @"iPhone7,1"   : @YES,
                                @"iPhone7,2"   : @YES,
                                @"iPhone8,1"   : @YES,
                                @"iPhone8,2"   : @YES,
                                @"iPhone8,4"   : @YES,
                                @"iPhone9,1"   : @YES,
                                @"iPhone9,3"   : @YES,
                                @"iPhone9,2"   : @YES,
                                @"iPhone9,4"   : @YES,
                                @"iPod1,1"     : @NO,
                                @"iPod2,1"     : @NO,
                                @"iPod3,1"     : @NO,
                                @"iPod4,1"     : @NO,
                                @"iPod5,1"     : @NO,
                                @"iPod7,1"     : @NO,
                                @"iPad1,1"     : @NO,
                                @"iPad2,1"     : @NO,
                                @"iPad2,2"     : @YES,
                                @"iPad2,3"     : @YES,
                                @"iPad2,4"     : @NO,
                                @"iPad2,5"     : @NO,
                                @"iPad2,6"     : @YES,
                                @"iPad2,7"     : @YES,
                                @"iPad3,1"     : @NO,
                                @"iPad3,2"     : @YES,
                                @"iPad3,3"     : @YES,
                                @"iPad3,4"     : @NO,
                                @"iPad3,5"     : @YES,
                                @"iPad3,6"     : @YES,
                                @"iPad4,1"     : @NO,
                                @"iPad4,2"     : @YES,
                                @"iPad4,3"     : @YES,
                                @"iPad4,4"     : @YES,
                                @"iPad4,5"     : @YES,
                                @"iPad4,6"     : @YES,
                                @"iPad4,7"     : @YES,
                                @"iPad4,8"     : @YES,
                                @"iPad4,9"     : @YES,
                                @"iPad5,3"     : @NO,
                                @"iPad5,4"     : @YES,
                                @"iPad6,3"     : @YES,
                                @"iPad6,4"     : @YES,
                                @"iPad6,6"     : @YES,
                                @"iPad6,7"     : @YES,
                                @"AppleTV2,1"  : @NO,
                                @"AppleTV3,1"  : @NO,
                                @"AppleTV3,2"  : @NO,
                                @"AppleTV5,3"  : @NO,
                                @"Watch1,1"    : @NO,
                                @"Watch1,2"    : @NO,
                                @"Watch2,3"    : @NO,
                                @"Watch2,4"    : @NO,
                                @"Watch2,6"    : @NO,
                                @"Watch2,7"    : @NO,
                                @"i386"        : @NO,
                                @"x86_64"      : @NO
                                };
        
    });
}
+ (NSString *) getSDKVersionNumber
{
    NSString *result;
    result = SDK_VERSION;
    return result;
}

+ (NSString *) getDeviceModel
{
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    
    NSString* deviceName = [WPUtil stringForKey:code inDictionary:deviceNamesByCode];
    
    if (!deviceName) {
        // Just use the code name so we don't lose any information
        deviceName = code;
    }
    
    return deviceName;
}

+ (CGRect) getScreenSize
{
    return [[UIScreen mainScreen] bounds];
}

+ (NSInteger) getScreenDensity
{
    CGFloat density = [[UIScreen mainScreen] scale];
    return density;
}

+ (NSString *) getTimezone
{
    return [WonderPush timeZone];
}

+ (NSString *) getCarrierName
{
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    NSString *carrierName = [carrier carrierName];
    
    if (carrierName == nil) {
        return @"unknown";
    }
    
    return carrierName;
}

+ (NSString *) getVersionString
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *) getLocale
{
    return [WonderPush locale];
}

+ (NSString *) getCountry
{
    return [WonderPush country];
}

+ (NSString *) getCurrency
{
    return [WonderPush currency];
}

+ (NSString *) getOsVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

@end
