//
//  TodayViewController.swift
//  SmartBillWidget
//
//  Created by Hunter Gregory on 10/1/18.
//  Copyright © 2018 Hunter Gregory. All rights reserved.
//


//REMAINING FIXES
//Blue arrows -> white??
//condense possible tips array to 5 max

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    //index 0 is the number 0, etc., the '.' is 11, delete is 12
    @IBOutlet var buttonCollection: [UIButton]!
    @IBOutlet weak var incrementButton: UIButton!
    @IBOutlet weak var decrementButton: UIButton!
    
    @IBOutlet weak var billLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var tipPercentLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var placeholderLabel1: UILabel!
    @IBOutlet weak var placeholderLabel2: UILabel!
    
    @IBOutlet weak var greenView: UIView!
    @IBOutlet weak var middleStackView: UIStackView!
    @IBOutlet weak var lightBlueView: UIView!
    
    let yellow = UIColor(displayP3Red: 242.0/255.0, green: 208.0/255.0, blue: 59.0/255.0, alpha: 1.0)
    let lightBlue = UIColor(displayP3Red: 0.0/255.0, green: 161.0/255.0, blue: 217.0/255.0, alpha: 1.0)
    let green = UIColor(displayP3Red: 71.0/255.0, green: 217.0/255.0, blue: 191.0/255.0, alpha: 1.0)
    let darkBlue = UIColor(displayP3Red: 4.0/255.0, green: 81.0/255.0, blue: 140.0/255.0, alpha: 1.0)
    let darkestBlue = UIColor(displayP3Red: 0.0/255.0, green: 48.0/255.0, blue: 86.0/255.0, alpha: 1.0)
    let pink = UIColor(displayP3Red: 255.0/255.0, green: 190.0/255.0, blue: 222.0/255.0, alpha: 1.0)
    let placeholderColor = UIColor(displayP3Red: 48.0/255.0, green: 159.0/255.0, blue: 144.0/255.0, alpha: 1.0)
    let almostBlack = UIColor(displayP3Red: 19.0/255.0, green: 42.0/255.0, blue: 59.0/255.0, alpha: 1.0)
    let almostGray = UIColor(displayP3Red: 89.0/255.0, green: 105.0/255.0, blue: 118.0/255.0, alpha: 0.7)
    
    var calculations: [Calculation] = []
    var currentIndex: Int = 0
    var percent: String = ""
    var total: String = ""
    var tip: String = ""
    var errorMessage: String = ""
    
    let minPercent: Double = 10.0
    let maxPercent: Double = 25.0
    let deleteImage = UIImage(named: "white-delete-button")
    let incrementImage = UIImage(named: "blueIncrementPNGSmall")
    let decrementImage = UIImage(named: "blueDecrementPNGSmallFixed")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        billLabel.textColor = darkestBlue
        greenView.backgroundColor = green
        lightBlueView.backgroundColor = lightBlue
        self.view.backgroundColor = almostBlack
        tipLabel.textColor = darkestBlue
        tipPercentLabel.textColor = darkestBlue
        totalLabel.textColor = darkestBlue
        totalAmountLabel.textColor = darkestBlue
        billLabel.textColor = placeholderColor
        placeholderLabel1.textColor = almostBlack
        placeholderLabel2.textColor = almostBlack
        incrementButton.layer.cornerRadius = 0.5 * 45
        decrementButton.layer.cornerRadius = 0.5 * 45
        
        //print(buttonCollection[11])
        
        //Set attributes for calc buttons
        for k in 0 ..< buttonCollection.count {
            //buttonCollection[k].setTitleColor(lightBlue, for: .normal)
            buttonCollection[k].layer.backgroundColor = almostGray.cgColor
            buttonCollection[k].setTitleColor(UIColor.white, for: .normal)
            buttonCollection[k].isEnabled = true
            buttonCollection[k].layer.cornerRadius = 5;
        }
        buttonCollection[11].setImage(deleteImage, for: .normal)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = maxSize
            //disable all buttons, change button text to "", turn delete image into nil
            showTipTotalLabels(false)
            showButtonStack(false)
        }
        else {
            //expanded
            self.preferredContentSize = CGSize(width: maxSize.width, height: 305)
            //enable all buttons, change button text back, place delete image back
            showTipTotalLabels(true)
            showButtonStack(true)
            
            getPossibleTips()
        }
    }
    
    func showTipTotalLabels(_ willShow: Bool) {
        if willShow {
            if total != "" {
                tipLabel.text = "Tip:"
                tipPercentLabel.text = tip + percent
                totalLabel.text = "Total:"
                totalAmountLabel.text = total
            } else {
                tipPercentLabel.text = errorMessage
            }
        } else {
            tipLabel.text = ""
            tipPercentLabel.text = "Press \"Show More\""
            totalLabel.text = ""
            totalAmountLabel.text = ""
        }
    }
    
    func showButtonStack(_ willShow: Bool) {
        if willShow {
            for k in 0 ..< buttonCollection.count {
                var label = String(k)
                if k == 10 {
                    label = "."
                }
                if k == 11 {
                    //insert image
                    buttonCollection[11].setImage(deleteImage, for: .normal)
                    label = ""
                }
                buttonCollection[k].setTitle(label, for: .normal)
                //buttonCollection[k].layer.backgroundColor = darkBlue.cgColor
                buttonCollection[k].isEnabled = true
            }
        } else {
            for k in 0 ..< buttonCollection.count {
                if k == 11 {
                    //set image to nil
                    buttonCollection[11].setImage(nil, for: .normal)
                }
                buttonCollection[k].setTitle("", for: .normal)
                //buttonCollection[k].layer.backgroundColor = darkBlue.cgColor
                buttonCollection[k].isEnabled = false
                
                showIncrementButtons(false)
            }
        }
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        var senderIndex = 0
        for k in 0 ..< buttonCollection.count {
            if buttonCollection[k] == sender {
                senderIndex = k
            }
        }
        buttonCollection[senderIndex].layer.backgroundColor = almostGray.cgColor
        updateBillLabel(withIndex: senderIndex)
        getPossibleTips()
    }
    
    func updateBillLabel(withIndex index: Int) {
        if index == 11 {
            guard billLabel.text != "Bill" else {return}
            let text = billLabel.text!
            billLabel.text!.remove(at: text.index(before: text.endIndex))
            if billLabel.text! == "$" {
                billLabel.text = "Bill"
                billLabel.textColor = placeholderColor
            }
        } else {
            if billLabel.text!.count >= 4 && billLabel.text! != "Bill" && !billLabel.text!.contains(".") && index != 10 {
                return
            } else {
                
                var label = String(index)
                if index == 10 {
                    label = "."
                }
                
                if billLabel.text! == "Bill" {
                    billLabel.text = label == "." ? "$0" : "$"
                    billLabel.textColor = darkestBlue
                }
                billLabel.text = billLabel.text! + label
            }
        }
    }
    
    func getPossibleTips() {
        totalAmountLabel.text = ""
        tipPercentLabel.text = ""
        totalLabel.text = ""
        tipLabel.text = ""
    
        guard let billDouble = getAndCheckBill() else {
            return
        }
    
        calcAndDisplayForNoCents(billDouble)
    }

    //NO CENTS SITUATION - called by getPossibleTips()
    func calcAndDisplayForNoCents(_ billDouble: Double) {
        var roundedTotals: [Int] = []
    
        //CALCULATE TOTALS
        //Calculate min
        let totalsMin: Double = billDouble * (1 + minPercent/100)
        roundedTotals.append(Int(ceil(totalsMin)))
        //Calc max
        let totalsMax: Double = billDouble * (1 + maxPercent/100)
        roundedTotals.append(Int(floor(totalsMax)))
        //Calculate totals in btwn max and min
        let delta: Int = roundedTotals[1] - roundedTotals[0]
        
        //what if delta == 1?????
        if delta > 1 {
            for item in 1..<delta {
                roundedTotals.append(roundedTotals[0] + item)
            }
        } else if delta < 1 {
            roundedTotals.remove(at: 1)
        }
    
        calculateTip(withTotals: roundedTotals, andBill: billDouble)
    }

    //called by above calcAndDisplayForNoCents(_ :)
    //updates the global varibles totals, tips, and percents (all of type string array)
    func calculateTip(withTotals totalInts: [Int], andBill bill: Double) {
        var totalDoubles: [Double] = []
        var tipDoubles: [Double] = []
        var percentDoubles: [Double] = []

        calculations = []
        
        let sortedTotalInts: [Int] = totalInts.sorted(by: <)
        for int in sortedTotalInts {
            totalDoubles.append(Double(int))
        }
        for total in totalDoubles {
            tipDoubles.append(total - bill)
        }
        for tip in tipDoubles {
            percentDoubles.append((tip / bill) * 100)
        }
        
        //watch out for NaN when bill is $0
        if percentDoubles[0].isNaN {
            let percentString = String(format: "%.1f",  percent)
            calculations.append(Calculation("0.00", "0.00", percentString))
        } else {
            for index in 0..<tipDoubles.count {
                let total = String(format: "%.2f", totalDoubles[index])
                let tip = String(format: "%.2f", tipDoubles[index])
                let percent = String(format: "%.1f", percentDoubles[index])
                
                calculations.append(Calculation(total, tip, percent))
            }
        }
        
        updateTipTotalLabel(incrementedBy: 0)
    }
    
    
    
    func updateTipTotalLabel(incrementedBy index: Int) {
        //first condense calculations array into 10 items
        let ITEMS: Int = 10
        
        var condensedCalcs: [Calculation] = []
        if (calculations.count <= ITEMS) {
            condensedCalcs = calculations
        } else {
            condensedCalcs.append(calculations[0])
            var condensedIndex = 1
            var calcsIndex = 1
            while (calcsIndex<calculations.count && condensedIndex < ITEMS-1) {
                let oldTip = Double(condensedCalcs[condensedIndex - 1].percent)
                let newTip = Double(calculations[calcsIndex].percent)
                if (floor(oldTip!) + 1 < floor(newTip!)) {
                    condensedCalcs.append(calculations[calcsIndex])
                    condensedIndex += 1
                }
                
                calcsIndex += 1
            }
            condensedCalcs.append(calculations[calculations.count - 1])
        }
        
        
        if index == 0 {
            currentIndex = condensedCalcs.count / 2
        } else if index > 0 {
            if currentIndex < (condensedCalcs.count - 1) {
                currentIndex += 1
            }
        } else {
            if currentIndex > 0 {
                currentIndex -= 1
            }
        }
        let calc = condensedCalcs[currentIndex]
        total = " $" + calc.total
        tip = "$" + calc.tip
        percent = " (" + calc.percent + "%)"
        
        tipLabel.text = "Tip:"
        totalLabel.text = "Total:"
        tipPercentLabel.text = tip + percent
        totalAmountLabel.text = total
        
        showIncrementButtons(true)
    }
    
    func showIncrementButtons(_ willShow: Bool) {
        if willShow {
            incrementButton.setImage(incrementImage, for: .normal)
            decrementButton.setImage(decrementImage, for: .normal)
            //set attributes for inc/dec buttons
            incrementButton.layer.cornerRadius = 0.5 * 45
            decrementButton.layer.cornerRadius = 0.5 * 45
            incrementButton.layer.backgroundColor = almostGray.cgColor
            decrementButton.layer.backgroundColor = almostGray.cgColor
        } else {
            incrementButton.setImage(nil, for: .normal)
            decrementButton.setImage(nil, for: .normal)
            incrementButton.layer.cornerRadius = 0
            decrementButton.layer.cornerRadius = 0
            incrementButton.layer.backgroundColor = almostBlack.cgColor
            decrementButton.layer.backgroundColor = almostBlack.cgColor
        }
        
        incrementButton.isEnabled = willShow
        decrementButton.isEnabled = willShow
    }
    
    @IBAction func incrementButtonPressed(_ sender: UIButton) {
        updateTipTotalLabel(incrementedBy: 1)
    }
    
    @IBAction func decrementButtonPressed(_ sender: UIButton) {
        updateTipTotalLabel(incrementedBy: -1)
    }
    
    func getAndCheckBill() -> Double? {
        let billText = billLabel.text!
        var betterBillText = ""
        if billText != "Bill" {
            var counter = 0
            for char in billText {
                if counter != 0 {
                    if betterBillText == "0" && char == "0" { // if input is $00
                        return displayError("Invalid bill entry")
                    } else if betterBillText == "0." && char == "." { //if input is $0..
                        return displayError("Invalid bill entry")
                    }
                    betterBillText += String(char)
                }
                counter += 1
            }
            if let billDouble = Double(betterBillText) {
                return billDouble
            } else {
                return displayError("Invalid bill entry")
            }
        } else {
            return displayError("Enter bill amount")
        }
    }

    func displayError(_ text: String) -> Double? {
        calculations = []
        tip = ""
        total = ""
        percent = ""
        tipPercentLabel.text = text
        errorMessage = text
        
        showIncrementButtons(false)
        
        return nil
    }
}
