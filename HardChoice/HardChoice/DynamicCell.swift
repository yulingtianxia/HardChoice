//
//  DynamicCell.swift
//  HardChoice
//
//  Created by 杨萧玉 on 14-8-17.
//  Copyright (c) 2014年 杨萧玉. All rights reserved.
//

import UIKit


class DynamicCell: UITableViewCell {

    required init(coder: NSCoder) {
        super.init(coder: coder)
        textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        textLabel?.numberOfLines = 0
        
        if detailTextLabel != nil {
            detailTextLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            detailTextLabel!.numberOfLines = 0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        textLabel?.numberOfLines = 0
        
        if detailTextLabel != nil {
            detailTextLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            detailTextLabel!.numberOfLines = 0
        }
    }
    override func constraints() -> [AnyObject] {
        var constraints = [AnyObject]()
        
        constraints.extend(constraintsForView(textLabel!))
        
        if detailTextLabel != nil {
            constraints.extend(constraintsForView(detailTextLabel!))
        }
        constraints.append(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: contentView, attribute: NSLayoutAttribute.Height, multiplier: 0, constant: 44))
        contentView.addConstraints(constraints)
        return constraints
    }
    
    func constraintsForView(view:UIView) -> [AnyObject]{
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.FirstBaseline, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Top, multiplier: 1.8, constant: 30.0))
        constraints.append(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: view, attribute: NSLayoutAttribute.Baseline, multiplier: 1.3, constant: 8))
        return constraints
    }

}
