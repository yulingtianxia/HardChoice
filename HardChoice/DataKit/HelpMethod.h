//
//  HelpMethod.h
//  HardChoice
//
//  Created by 杨萧玉 on 15/4/6.
//  Copyright (c) 2015年 杨萧玉. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>

@interface HelpMethod : NSObject
@property CFNotificationCallback callback;
//void wormholeNotificationCallback(CFNotificationCenterRef center,
//                                  void * observer,
//                                  CFStringRef name,
//                                  void const * object,
//                                  CFDictionaryRef userInfo);
@end
