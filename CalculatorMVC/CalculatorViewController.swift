//
//  ViewController.swift
//  CalculatorMVC
//
//  Created by Ivan on 25.04.16.
//  Copyright © 2016 Ivan. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet private weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    private let decimalSeparator = NSNumberFormatter().decimalSeparator
    private let numberStyle = NSNumberFormatter()
    
    private var userIsInTheMiddleOfTypingANumber = false
    private var brain = CalculatorBrain()    
    private var displayValue: Double? {
        get{
            return numberStyle.numberFromString(display.text!)?.doubleValue ?? nil
        }
        set{
            let result = newValue ?? 0
            if let report = brain.errorReport {
                display.text = report
                brain.errorReport = nil
            } else {
                display.text = numberStyle.stringFromNumber(result)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberStyle.numberStyle = .DecimalStyle
        numberStyle.maximumFractionDigits = 6
        numberStyle.notANumberSymbol = "Error"
    }
    
    @IBAction func backSpace(sender: AnyObject) {
        if userIsInTheMiddleOfTypingANumber{
            if display.text != nil {
                if display.text!.characters.count > 1 {
                    display.text!.removeAtIndex(display.text!.endIndex.predecessor())
                } else {
                    display.text = "0"
                    userIsInTheMiddleOfTypingANumber = false
                }
            }
        } else {
            brain.undo()
            displayValue = brain.result
            history.text = brain.description + (brain.isPartialResult ? "..." : "=")            
        }
    }
    
    @IBAction private func touchDigit(sender: UIButton) {
        if let digit = sender.currentTitle {
            if userIsInTheMiddleOfTypingANumber{
                if display.text!.rangeOfString(decimalSeparator) == nil || digit != decimalSeparator {
                    display.text = display.text! + digit
                }
            } else {
                display.text = digit
            }
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction private func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber{
            if let operand = displayValue{
                brain.setOperand(operand)
                userIsInTheMiddleOfTypingANumber = false
            }
        }
        if let operation = sender.currentTitle {
            brain.performOperation(operation)
        }
        displayValue = brain.result
        history.text = brain.description + (brain.isPartialResult ? "..." : "=")
    }
    

    @IBAction func setVariable() {
        if let operand = displayValue{
            brain.variableValues["M"] = operand
            displayValue = brain.result
            print("variableValues: \(brain.variableValues)")
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBAction func getVariable(sender: UIButton) {
        if let variableValue = sender.currentTitle{
            brain.setOperand(variableValue)
            history.text = brain.description + (brain.isPartialResult ? "..." : "=")
        }
    }
        
    @IBAction func clear() {
        brain.clear()
        brain.variableValues.removeAll()
        displayValue = nil
        history.text = " "
        userIsInTheMiddleOfTypingANumber = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let graphvc = segue.destinationViewController.contentViewController as? GraphViewController{
            graphvc.graphLabelValue = "New Graph"
            graphvc.navigationItem.title = "Graph View"
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if !brain.isPartialResult{
            return true
        } else {
            return false
        }
    }
}


