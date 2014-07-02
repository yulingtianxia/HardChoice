//
//  ChoiceView.swift
//  HardChoice
//
//  Created by 杨萧玉 on 14-7-2.
//  Copyright (c) 2014年 杨萧玉. All rights reserved.
//

import UIKit

class ChoiceView: UIView {
    let nameTF = UITextField(frame:CGRectMake(0,0,290,50))
    let weightTF = UITextField(frame:CGRectMake(0,50,290,50))
    init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
        
        nameTF.becomeFirstResponder()
        nameTF.placeholder = "choice"
        nameTF.keyboardType = .Default
        nameTF.returnKeyType = .Done
        
        
        weightTF.placeholder = "weight"
        weightTF.keyboardType = .NumberPad
        weightTF.returnKeyType = .Done
        
        self.addSubview(nameTF)
        self.addSubview(weightTF)

    }
    func setDelegate(delegate:UITextFieldDelegate){
        nameTF.delegate = delegate
        weightTF.delegate = delegate
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */

}
