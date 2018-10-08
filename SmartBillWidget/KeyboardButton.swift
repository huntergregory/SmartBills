//
//  KeyboardButton.swift
//  SmartBillWidget
//
//  Created by Hunter Gregory on 10/2/18.
//  Copyright © 2018 Hunter Gregory. All rights reserved.
//

import UIKit

class KeyboardButton: UIButton {

    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(displayP3Red: 0.0/255.0, green: 48.0/255.0, blue: 86.0/255.0, alpha: 1.0) : UIColor.clear
            //^ big color is darkestBlue
        }
    }
    
}
