//
//  ChoiceInterfaceController.swift
//  HardChoice
//
//  Created by 杨萧玉 on 15/3/28.
//  Copyright (c) 2015年 杨萧玉. All rights reserved.
//

import WatchKit
import Foundation
import DataKit

class ChoiceInterfaceController: WKInterfaceController {

    @IBOutlet weak var choiceTable: WKInterfaceTable!
//    let question:String?
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let choices = DataAccess.sharedInstance.fetchChoices(context as? String) {
            choiceTable.setNumberOfRows(choices.count, withRowType: "ChoiceTableRowController")
            for (index, name) in enumerate(choices) {
                let row = choiceTable.rowControllerAtIndex(index) as! ChoiceTableRowController
                row.choiceName.setText(name)
            }
        }
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
