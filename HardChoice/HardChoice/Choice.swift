//
//  Choice.swift
//  HardChoice
//
//  Created by 杨萧玉 on 15/4/15.
//  Copyright (c) 2015年 杨萧玉. All rights reserved.
//

import Foundation
import CoreData

@objc(Choice)
public class Choice: NSManagedObject {

    @NSManaged public var name: String
    @NSManaged public var weight: NSNumber
    @NSManaged public var question: Question

}
