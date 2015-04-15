//
//  Question.swift
//  HardChoice
//
//  Created by 杨萧玉 on 15/4/15.
//  Copyright (c) 2015年 杨萧玉. All rights reserved.
//

import Foundation
import CoreData

@objc(Question)
public class Question: NSManagedObject {

    @NSManaged public var content: String
    @NSManaged public var choices: NSSet

}
