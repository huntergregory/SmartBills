//
//  ViewController.swift
//  SmartTip
//
//  Created by Hunter Gregory on 9/10/18.
//  Copyright © 2018 Hunter Gregory. All rights reserved.
//

import UIKit

//
//animate green tab sliding in and out when errors occur/go away
//DELETE trailing constraint before animating, and create it upon completion
//
//change round totals to increase by 2 or more depending on difference in max and in? (i.e. number of tips that would occur)

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var uppermostView: UIView!
    @IBOutlet weak var appTitleLabel: UILabel!
    @IBOutlet weak var includeTaxSwitch: UISwitch!
    @IBOutlet weak var taxTextField: UITextField!
    @IBOutlet weak var percentSlider: UISlider!
    @IBOutlet weak var noCentsButton: UIButton!
    @IBOutlet weak var percentDisplayLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet var sliderLabelCollection: [UILabel]!
    
    @IBOutlet weak var billTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var tap = UITapGestureRecognizer()
    var tapTax = UITapGestureRecognizer()
    
    var calculations: [Calculation] = []
    var usingNoCents: Bool = false
    var sliderPercent: Double = 0.175
    var lastTaxEntry: String?
    
    let minPercent: Double = 15.0
    let maxPercent: Double = 20.0
    var justHadError: Bool = true
    
    //color palette
    let yellow = UIColor(displayP3Red: 242.0/255.0, green: 208.0/255.0, blue: 59.0/255.0, alpha: 1.0)
    let lightBlue = UIColor(displayP3Red: 0.0/255.0, green: 161.0/255.0, blue: 217.0/255.0, alpha: 1.0)
    let green = UIColor(displayP3Red: 71.0/255.0, green: 217.0/255.0, blue: 191.0/255.0, alpha: 1.0)
    let darkBlue = UIColor(displayP3Red: 4.0/255.0, green: 81.0/255.0, blue: 140.0/255.0, alpha: 1.0)
    let darkestBlue = UIColor(displayP3Red: 0.0/255.0, green: 48.0/255.0, blue: 86.0/255.0, alpha: 1.0)
    let pink = UIColor(displayP3Red: 255.0/255.0, green: 190.0/255.0, blue: 222.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        
        //configure color for slider, switch, title, upper view, and background
        includeTaxSwitch.onTintColor = green
        percentSlider.minimumTrackTintColor = lightBlue
        view.backgroundColor = darkestBlue
        uppermostView.backgroundColor = darkBlue
        
        appTitleLabel.backgroundColor = darkBlue
        appTitleLabel.textColor = UIColor.white
        appTitleLabel.shadowColor = darkestBlue
        
        //configure no cents button
        noCentsButton.backgroundColor = darkBlue
        if view.traitCollection.horizontalSizeClass == .regular && view.traitCollection.verticalSizeClass == .regular {
            noCentsButton.layer.cornerRadius = 15
        } else {
            noCentsButton.layer.cornerRadius = 10
        }
        //noCentsButton.layer.borderWidth = 1
        //noCentsButton.layer.borderColor = green.cgColor
        noCentsButton.setTitleShadowColor(darkestBlue, for: .normal)
        noCentsButton.setTitleColor(green, for: .normal)
        
        //configure text fields and their keyboard appearance
        billTextField.keyboardAppearance = .dark
        taxTextField.keyboardAppearance = .dark
        billTextField.textColor = darkestBlue
        taxTextField.textColor = darkestBlue
        
        //position total label
        totalLabel.backgroundColor = lightBlue
        
        totalLabel.textColor = darkestBlue
        totalLabel.transform = CGAffineTransform(translationX: totalLabel.frame.width, y: 0)
        
        billTextField.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        taxTextField.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
    }
    
    //maintain status bar color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func animateLabel(toLeft: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            if toLeft {
                self.totalLabel.transform = CGAffineTransform.identity
            } else {
                self.totalLabel.transform = CGAffineTransform(translationX: self.totalLabel.frame.width, y: 0)
            }
        }, completion: nil)
    }
    
    @IBAction func textFieldEditingEnded(_ sender: UITextField) {
        if sender == taxTextField {
            self.view.removeGestureRecognizer(self.tapTax)
            getPossibleTips()
        } else {
            self.view.removeGestureRecognizer(self.tap)
        }
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
    @IBAction func editingDidBeginForTax(_ sender: UITextField) {
        tapTax = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tapTax.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapTax) // resigns first responder for the tax keyboard
        if !includeTaxSwitch.isOn {
            taxTextField.backgroundColor = green
            if let text = lastTaxEntry {
                taxTextField.text = text
            }
            taxTextField.placeholder = "tax"
            includeTaxSwitch.setOn(true, animated: true)
        }
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    @IBAction func editingDidBegin(_ sender: UITextField) {
        tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap) // resigns first responder for the bill keyboard
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if let text = textField.text {
            if text == "$" {
                textField.text = ""
            } else if text.count == 1 {
                if text == "." {//insert dollar sign & 0 to display
                    textField.text = "$0."
                } else {    //insert dollar sign
                    textField.text = "$" + text
                }
            } else if text.count >= 8 { //prevent numbers from being a million or more for round totals' sake
                var newText = ""
                var counter = 0
                for char in text {
                    if !text.contains(".") {
                        if counter == 7 {
                            break
                        }
                    } else if counter == 10 {
                        break
                    }
                    newText += String(char)
                    counter += 1
                }
                textField.text = newText
            }
        }
        
        getPossibleTips()
    }
    
    @IBAction func taxSwitchFlipped(_ sender: UISwitch) {
        if includeTaxSwitch.isOn {
            taxTextField.backgroundColor = green
            if let text = lastTaxEntry {
                taxTextField.text = text
            }
            taxTextField.placeholder = "tax"
        } else {
            if let text = taxTextField.text {
                lastTaxEntry = text
            }
            taxTextField.backgroundColor = UIColor.white
            taxTextField.placeholder = ""
            taxTextField.text = ""
            taxTextField.textColor = UIColor.black
            //taxTextField.isUserInteractionEnabled = false
            taxTextField.resignFirstResponder()
            //taxTextField.isUserInteractionEnabled = true
        }
        getPossibleTips()
    }
    
    @IBAction func findNoCentsPressed(_ sender: UIButton) {
        usingNoCents = true
        //dull the slider stack
        //FIX ^^
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        getPossibleTips()
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        usingNoCents = false
        updateSliderLabelColor()
        //^ unnecessary cuz of touchedSlider
        sliderPercent = Double(percentSlider.value)
        percentDisplayLabel.text = String(format: "%0.1f", sliderPercent * 100.0) + "%"
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        getPossibleTips()
    }
    
    func updateSliderLabelColor() {
        var color: UIColor!
        if usingNoCents {
            color = UIColor.lightGray
            percentSlider.minimumTrackTintColor = UIColor.black
            /////FIX SO MORE LEGIBLE
        } else {
            color = UIColor.white
            percentSlider.minimumTrackTintColor = lightBlue
        }
        
        for k in 0 ..< sliderLabelCollection.count {
            sliderLabelCollection[k].textColor = color
        }
        percentSlider.thumbTintColor = color
    }
    
    func getPossibleTips() {
        totalLabel.text = ""
        updateSliderLabelColor()
        
        guard let billDouble = getAndCheckBill() else {
            return
        }
        
        if includeTaxSwitch.isOn {
            if getAndCheckTax() == nil {
                return
            }
        }
        
        if usingNoCents {
            calcAndDisplayForNoCents(billDouble)
        } else {
            calcAndDisplayUsingSlider(billDouble)
        }
    }
    
    //SLIDER SITUATION - called by getPossibleTips()
    func calcAndDisplayUsingSlider(_ billDouble: Double) {
        
        let singleTip: Double = billDouble * sliderPercent
        var total: Double = singleTip + billDouble
        if includeTaxSwitch.isOn {
            if let tax = getAndCheckTax() {
                total += tax
            }
        }
        
        let totalString = String(format: "%0.2f", total)
        let tipString = String(format: "%0.2f", singleTip)
        let percentString = String(format: "%0.1f", sliderPercent * 100)
        
        calculations = []
        calculations.append(Calculation(totalString, tipString, percentString))
        tableView.reloadData()
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
        totalLabel.text = "   $" + totalString
        if justHadError {
            animateLabel(toLeft: true)
        }
        justHadError = false
    }
    
    //NO CENTS SITUATION - called by getPossibleTips()
    func calcAndDisplayForNoCents(_ billDouble: Double) {
        var roundedTotals: [Int] = []
        
        //CALCULATE TOTALS
        //Calculate min
        var tax = 0.0
        if includeTaxSwitch.isOn {
            if let taxDouble = getAndCheckTax() {
                tax = taxDouble
            }
        }
        let totalsMin: Double = billDouble * (1 + minPercent/100)
        roundedTotals.append(Int(ceil(totalsMin + tax)))
        //Calc max
        let totalsMax: Double = billDouble * (1 + maxPercent/100)
        roundedTotals.append(Int(floor(totalsMax + tax)))
        //Calculate totals in btwn max and min
        let delta: Int = roundedTotals[1] - roundedTotals[0]
        if delta > 1 {
            for item in 1..<delta {
                roundedTotals.append(roundedTotals[0] + item)
            }
        } else if delta < 1 {
            roundedTotals.remove(at: 1)
        }
        
        calculateTip(withTotals: roundedTotals, andBill: billDouble)
        tableView.reloadData()
        var index: Int = calculations.count / 2
        var position: UITableViewScrollPosition!
        if billTextField.isEditing || taxTextField.isEditing {
            position = .top
            if calculations.count <= 5 {
                index = 0
            } else if calculations.count <= 8 {
                index -= 1
            }
        } else {
            position = .middle
        }
        let indexPath = IndexPath(row: index, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: position)
        setSlider(to: calculations[index].percent)
        
        if justHadError {
            animateLabel(toLeft: true)
        }
        justHadError = false
    }
    
    //called by above calcAndDisplayForNoCents(_ :)
    //updates the global varibles totals, tips, and percents (all of type string array)
    func calculateTip(withTotals totalInts: [Int], andBill bill: Double) {
        var totalDoubles: [Double] = []
        var tipDoubles: [Double] = []
        var percentDoubles: [Double] = []
        var tax: Double = 0.0
        
        if includeTaxSwitch.isOn {
            if let taxDouble = getAndCheckTax() {
                tax = taxDouble
            }
        }
        
        calculations = []
        
        let sortedTotalInts: [Int] = totalInts.sorted(by: <)
        for int in sortedTotalInts {
            totalDoubles.append(Double(int))
        }
        for total in totalDoubles {
            tipDoubles.append(total - bill - tax)
        }
        for tip in tipDoubles {
            percentDoubles.append((tip / bill) * 100)
        }
        
        //watch out for NaN when bill is $0
        if percentDoubles[0].isNaN {
            let percent = sliderPercent * 100
            let percentString = String(format: "%.1f",  percent)
            let totalString = String(format: "%.2f", tax)
            calculations.append(Calculation(totalString, "0.00", percentString))
        } else {
            for index in 0..<tipDoubles.count {
                let total = String(format: "%.2f", totalDoubles[index])
                let tip = String(format: "%.2f", tipDoubles[index])
                let percent = String(format: "%.1f", percentDoubles[index])
            
                calculations.append(Calculation(total, tip, percent))
            }
        }
        
        let totalString = calculations[0].total
        totalLabel.text = "   $" + totalString
    }
    
    func setSlider(to percent: String) {
        let floatingPercent: Float = Float(percent)!
        let floatingDecimal: Float = floatingPercent / 100.0
        percentSlider.setValue(floatingDecimal, animated: true)
        sliderPercent = Double(percentSlider.value)
        percentDisplayLabel.text = String(format: "%0.1f", sliderPercent * 100.0) + "%"
    }
    
    func getAndCheckBill() -> Double? {
        let billText = billTextField.text!
        var betterBillText = ""
        if billText != "" {
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
    
    func getAndCheckTax() -> Double? {
        let taxText = taxTextField.text!
        var betterTaxText = ""
        if taxText != "" {
            var counter = 0
            for char in taxText {
                if counter != 0 {
                    if betterTaxText == "0" && char == "0" { // if input is $00
                        return displayError("Invalid tax entry")
                    } else if betterTaxText == "0." && char == "." { //if input is $0..
                        return displayError("Invalid tax entry")
                    }
                    betterTaxText += String(char)
                }
                counter += 1
            }
            if let taxDouble = Double(betterTaxText) {
                return taxDouble
            } else {
                return displayError("Invalid tax entry")
            }
        } else {
            return displayError("Enter tax amount")
        }
    }

    func displayError(_ text: String) -> Double? {
        calculations = []
        //put error message in total (1st argument) so that it's displayed as the cell's title
        calculations.append(Calculation(text, "", ""))
        tableView.reloadData()
        
        if !justHadError {
            animateLabel(toLeft: false)
        }
        
        justHadError = true
        return nil
    }
    
    //////// Table View     //////
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calculations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TipCell", for: indexPath)
        let calculation = calculations[indexPath.row]
        
        //if calc has error message in total spot (all error messages have n at beginning of string)...
        if calculation.total.contains("n") {
            cell.textLabel?.text = calculation.total
            cell.textLabel?.textColor = UIColor.red
            //CHANGE????? ^^
            cell.detailTextLabel?.text = ""
        } else { //normal stuff
            cell.textLabel?.text = "Tip: $\(calculation.tip)"
            cell.detailTextLabel?.text = "\(calculation.percent)%"
            cell.textLabel?.textColor = darkestBlue   //OR    UIColor.black
            cell.detailTextLabel?.textColor = darkestBlue
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let calculation = calculations[indexPath.row]
        guard !calculation.total.contains("n") else {return}  //same test as above, make sure calculation selected is not an error message
        totalLabel.text = "   $" + calculation.total
        setSlider(to: calculation.percent)
    }
}

