//
//  GlanceController.swift
//  HardChoice
//
//  Created by 杨萧玉 on 15/4/8.
//  Copyright (c) 2015年 杨萧玉. All rights reserved.
//

import WatchKit
import Foundation
import DataKit

class GlanceController: WKInterfaceController {

    @IBOutlet weak var question: WKInterfaceLabel!
    @IBOutlet weak var choice: WKInterfaceLabel!
    var wormhole:Wormhole!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        //初始化虫洞
        wormhole = Wormhole(applicationGroupIdentifier: appGroupIdentifier, optionalDirectory: "wormhole")
        let data = wormhole.messageWithIdentifier("shake") as! [String]
        question.setText("Q:"+data[0])
        choice.setText("A:"+data[1])
        wormhole.listenForMessageWithIdentifier("shake", listener: { [unowned self](data) -> Void in
            let questionText = "Q:" + (data as! [String])[0]
            let choiceText = "A:" + (data as! [String])[1]
            self.question.setText(questionText)
            self.choice.setText(choiceText)
            })
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
