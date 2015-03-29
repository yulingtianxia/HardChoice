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

class ChoiceInterfaceController: WKInterfaceController, DataUpdateDelegate {

    @IBOutlet weak var choiceTable: WKInterfaceTable!
    var question:String?
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        DataAccess.sharedInstance.dataDelegate = self
        
        // Configure interface objects here.
        
        question = context as? String
        loadData(question)
    }
    
    func loadData(question: AnyObject?){
        if let choices = DataAccess.sharedInstance.fetchChoices(question as? String) {
            choiceTable.setNumberOfRows(choices.count, withRowType: "ChoiceTableRowController")
            for (index, name) in enumerate(choices) {
                let row = choiceTable.rowControllerAtIndex(index) as! ChoiceTableRowController
                row.choiceName.setText(name)
            }
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        loadData(question)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func deleteRow(row: Int) {
        choiceTable.removeRowsAtIndexes(NSIndexSet(index: row))
    }
}
