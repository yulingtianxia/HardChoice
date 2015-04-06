//
//  HelpMethod.m
//  HardChoice
//
//  Created by 杨萧玉 on 15/4/6.
//  Copyright (c) 2015年 杨萧玉. All rights reserved.
//

#import "HelpMethod.h"
//#include <CoreFoundation/CoreFoundation.h>

static NSString * const WormholeNotificationName = @"WormholeNotificationName";
@implementation HelpMethod
- (instancetype)init
{
    self = [super init];
    if (self) {
        _callback = wormholeNotificationCallback;
    }
    return self;
}
void wormholeNotificationCallback(CFNotificationCenterRef center,
                                  void * observer,
                                  CFStringRef name,
                                  void const * object,
                                  CFDictionaryRef userInfo) {
    NSString *identifier = (__bridge NSString *)name;
    [[NSNotificationCenter defaultCenter] postNotificationName:WormholeNotificationName
                                                        object:nil
                                                      userInfo:@{@"identifier" : identifier}];
}

@end
