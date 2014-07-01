//
//  Choice.h
//  HardChoice
//
//  Created by 杨萧玉 on 14-7-1.
//  Copyright (c) 2014年 杨萧玉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Question;

@interface Choice : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Question *question;

@end
