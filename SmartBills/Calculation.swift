//
//  Calculation.swift
//  SmartBills
//
//  Created by Hunter Gregory on 9/19/18.
//  Copyright © 2018 Hunter Gregory. All rights reserved.
//

import Foundation

class Calculation {
    var total: String
    var tip: String
    var percent: String
    
    init(_ total: String, _ tip: String, _ percent: String) {
        self.total = total; self.tip = tip; self.percent = percent
    }
}
