//
//  WPHTMLInAppController.h
//  WonderPush
//
//  Created by Stéphane JAIS on 14/02/2019.
//  Copyright © 2019 WonderPush. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WPHTMLInAppAction : NSObject
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) void(^block)(WPHTMLInAppAction *);
+ (instancetype) actionWithTitle:(NSString *)title block:(void(^)(WPHTMLInAppAction *))block;
@end

@interface WPHTMLInAppController : UIViewController
@property (strong, nonatomic) NSArray<WPHTMLInAppAction *> *actions;
@property (strong, nonatomic) NSString *HTMLString;
@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) NSURL *URL;
@end
