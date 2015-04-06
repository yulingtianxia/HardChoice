//
//  InterfaceController.swift
//  HardChoice WatchKit Extension
//
//  Created by 杨萧玉 on 15/3/27.
//  Copyright (c) 2015年 杨萧玉. All rights reserved.
//

import WatchKit
import Foundation
import DataKit

class QuestionInterfaceController: WKInterfaceController {

    @IBOutlet weak var questionTable: WKInterfaceTable!
    var questions:[String]!
    var wormhole:Wormhole!
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.

        //初始化虫洞
        wormhole = Wormhole(applicationGroupIdentifier: appGroupIdentifier, optionalDirectory: "wormhole")
        wormhole.listenForMessageWithIdentifier("questionData", listener: { [unowned self](data) -> Void in
            self.loadData()

        })
    }
    
    func loadData(){
        questions = DataAccess.sharedInstance.fetchQuestions() ?? []
        questionTable.setNumberOfRows(questions.count, withRowType: "QuestionTableRowController")
        for (index, content) in enumerate(questions) {
            let row = questionTable.rowControllerAtIndex(index) as! QuestionTableRowController
            row.questionName.setText(content)
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        loadData()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        return questions[rowIndex]
    }
    
    //MARK: - DataUpdateDelegate
    func deleteRow(row: Int) {
        questionTable.removeRowsAtIndexes(NSIndexSet(index: row))
    }
}
