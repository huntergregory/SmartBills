//
//  HighlightedButton.swift
//  SmartBillWidget
//
//  Created by Hunter Gregory on 11/24/18.
//  Copyright © 2018 Hunter Gregory. All rights reserved.
//

import UIKit

class HighlightedButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            self.layer.backgroundColor = isHighlighted ?  UIColor(displayP3Red: 19.0/255.0, green: 42.0/255.0, blue: 59.0/255.0, alpha: 0.5).cgColor : UIColor(displayP3Red: 89.0/255.0, green: 105.0/255.0, blue: 118.0/255.0, alpha: 0.7).cgColor
            //first is ???? almost black, second is almost gray
        }
    }
}
